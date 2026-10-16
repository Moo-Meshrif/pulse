import '../../../../core/services/media_picker_service.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/domain/policy/media_policy.dart';
import 'enums/new_post_notice.dart';

/// What a post may hold (docs/specs/post/01-design-tokens.md > Behavior tokens). Video rules come from
/// [MediaPolicy].
abstract final class NewPostLimits {
  static const maxMedia = 10;
  static const maxCaption = 2000;

  static int get maxVideoMinutes =>
      MediaPolicy.videoLimits(ContentKind.post).maxDuration.inMinutes;

  static int get maxVideoMegabytes => MediaPolicy.maxBytes ~/ _bytesPerMegabyte;

  static const _bytesPerMegabyte = 1024 * 1024;

  /// Why [media] cannot go in a post, or null when it can (a video over the limits is shrunk when it is
  /// sent). A photo always can.
  static NewPostNotice? rejection(PickedMedia media) {
    if (!media.isVideo) return null;
    final decision = MediaPolicy.decide(
      ContentKind.post,
      isVideo: true,
      durationMs: media.durationMs,
      width: media.width,
      height: media.height,
      sizeBytes: media.sizeBytes,
    );
    return switch (decision) {
      MediaRejected(reason: MediaRejection.tooLong) =>
        NewPostNotice.videoTooLong,
      MediaRejected(reason: MediaRejection.tooBig) => NewPostNotice.videoTooBig,
      _ => null,
    };
  }
}

/// What tagging allows (docs/specs/post/screens/s6-tag-people.md).
abstract final class TagLimits {
  static const maxPeople = 20;
  static const searchDelay = Duration(milliseconds: 300);
}
