import '../../../../core/error/failures.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
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

  Future<List<PickedMedia>> pick({required int room}) =>
      _picker.pickMany(limit: room);

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
