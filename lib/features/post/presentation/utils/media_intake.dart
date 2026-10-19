import 'dart:async';

import '../../../../core/error/failures.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import '../../domain/entity/new_post_media_entity.dart';
import 'enums/new_post_notice.dart';
import 'new_post_limits.dart';

/// A picked file once it was read: [media] with its size, a frame for a video, and why it cannot go in a
/// post, if it cannot.
class DescribedMedia {
  const DescribedMedia(this.media, {this.poster, this.rejection});

  final PickedMedia media;

  /// A frame of a video; null for a photo or when it could not be made.
  final String? poster;
  final NewPostNotice? rejection;
}

/// Lets the person pick photos and videos for a post (New post and Edit post): [pick] returns the files at
/// once so they can be shown, and [describe] reads each one afterwards and applies [NewPostLimits].
class MediaIntake {
  MediaIntake(this._picker, this._thumbnails);

  final MediaPickerService _picker;
  final VideoThumbnailService _thumbnails;

  /// A photo whose size is unknown is shared as this square.
  static const _fallbackSide = 1080;

  /// Each picked file being read, by path; the sender waits for them.
  final _details = <String, Future<DescribedMedia>>{};

  // TODO(post-plan T4): camera capture is not in the post picker yet (gallery only).
  Future<List<PickedMedia>> pick({required int room}) =>
      _picker.pickMany(limit: room);

  /// Starts reading each of [picked] in the background and calls [onDescribed] as each one is done.
  void startReading(
    List<PickedMedia> picked,
    void Function(DescribedMedia described) onDescribed,
  ) {
    for (final item in picked) {
      final details = describe(item);
      _details[item.path] = details;
      unawaited(details.then(onDescribed));
    }
  }

  /// The files for the sender: each one once it is fully read, without the ones that cannot go in a post.
  Future<List<NewPostMediaEntity>> readAll(List<PickedMedia> picked) async {
    final described = await Future.wait(
      picked.map(
        (item) => _details[item.path] ?? Future.value(DescribedMedia(item)),
      ),
    );
    return described
        .where((item) => item.rejection == null)
        .map((item) => _newMedia(item.media))
        .toList();
  }

  NewPostMediaEntity _newMedia(PickedMedia media) => NewPostMediaEntity(
    filePath: media.path,
    isVideo: media.isVideo,
    width: media.width ?? _fallbackSide,
    height: media.height ?? _fallbackSide,
    durationMs: media.isVideo ? (media.durationMs ?? 0) : null,
    blurhash: media.blurhash,
  );

  /// Never throws: a file that cannot be read is kept as it is.
  Future<DescribedMedia> describe(PickedMedia picked) async {
    final media = await _picker.describe(picked);
    final rejection = NewPostLimits.rejection(media);
    if (rejection != null) return DescribedMedia(media, rejection: rejection);
    return DescribedMedia(
      media,
      poster: media.isVideo ? await _poster(media.path) : null,
    );
  }

  Future<String?> _poster(String video) async {
    try {
      return await _thumbnails.thumbnail(video);
    } on Failure {
      return null; // the thumbnail strip draws a plain tile for it
    }
  }
}
