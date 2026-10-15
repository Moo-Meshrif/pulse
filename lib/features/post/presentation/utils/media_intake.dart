import '../../../../core/error/failures.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/services/video_thumbnail_service.dart';
import 'enums/new_post_notice.dart';
import 'new_post_limits.dart';

/// What the person added from the library: the files a post can hold, a frame for each video, and the
/// first reason a file was left out.
class PickedBatch {
  const PickedBatch({
    this.accepted = const [],
    this.posters = const {},
    this.notice,
  });

  final List<PickedMedia> accepted;

  /// A frame of each accepted video, by video path.
  final Map<String, String> posters;
  final NewPostNotice? notice;

  bool get isEmpty => accepted.isEmpty && notice == null;
}

/// Lets the person pick photos and videos for a post (New post and Edit post) and keeps the ones
/// [NewPostLimits] allows.
class MediaIntake {
  MediaIntake(this._picker, this._thumbnails);

  final MediaPickerService _picker;
  final VideoThumbnailService _thumbnails;

  Future<PickedBatch> pick({required int room}) async {
    final picked = await _picker.pickMany(limit: room);
    final accepted = <PickedMedia>[];
    NewPostNotice? notice;
    for (final item in picked) {
      final rejection = NewPostLimits.rejection(item);
      if (rejection == null) {
        accepted.add(item);
      } else {
        notice ??= rejection;
      }
    }
    return PickedBatch(
      accepted: accepted,
      posters: await _posters(accepted),
      notice: notice,
    );
  }

  Future<Map<String, String>> _posters(List<PickedMedia> picked) async {
    final posters = <String, String>{};
    await Future.wait([
      for (final item in picked)
        if (item.isVideo) _addPoster(posters, item.path),
    ]);
    return posters;
  }

  Future<void> _addPoster(Map<String, String> posters, String video) async {
    try {
      posters[video] = await _thumbnails.thumbnail(video);
    } on Failure {
      // The thumbnail strip draws a plain tile for it.
    }
  }
}
