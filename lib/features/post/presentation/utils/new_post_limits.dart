import '../../../../core/services/media_picker_service.dart';
import 'enums/new_post_notice.dart';

/// What a post may hold (docs/specs/post/01-design-tokens.md > Behavior tokens).
abstract final class NewPostLimits {
  static const maxMedia = 10;
  static const maxCaption = 2000;
  static const maxVideoMinutes = 10;
  static const maxVideoMegabytes = 50;

  static const _bytesPerMegabyte = 1024 * 1024;
  static const _maxVideoDuration = Duration(minutes: maxVideoMinutes);

  /// Why [media] cannot go in a post, or null when it can. A photo always can.
  static NewPostNotice? rejection(PickedMedia media) {
    if (!media.isVideo) return null;
    final durationMs = media.durationMs ?? 0;
    if (Duration(milliseconds: durationMs) > _maxVideoDuration) {
      return NewPostNotice.videoTooLong;
    }
    if ((media.sizeBytes ?? 0) > maxVideoMegabytes * _bytesPerMegabyte) {
      return NewPostNotice.videoTooBig;
    }
    return null;
  }
}
