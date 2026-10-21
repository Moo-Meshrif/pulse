import '../../../../core/error/failures.dart';
import '../../../../core/utils/equatable.dart';
import '../../data/enums/content_kind.dart';

/// Where sending a post, short or story stands; each [kind] has its own. Public: Home shows the post's
/// above the feed and the story's on the rail.
sealed class ContentPublishStatus extends Equatable {
  const ContentPublishStatus(this.kind);

  final ContentKind kind;

  @override
  List<Object?> get props => [kind];
}

/// Nothing of [kind] is being sent.
final class ContentPublishIdle extends ContentPublishStatus {
  const ContentPublishIdle(super.kind);
}

/// The content is going out. [progress] is 0..1 and never goes back within one try; [previewPath] is a
/// picked file on this device to show meanwhile.
final class ContentPublishing extends ContentPublishStatus {
  const ContentPublishing(
    super.kind, {
    this.progress = 0,
    this.isEdit = false,
    this.previewPath,
    this.previewUrl,
    this.previewCacheKey,
  });

  final double progress;
  final bool isEdit;
  final String? previewPath;

  /// A signed link to a picture already online (an edited post's own media), cached under
  /// [previewCacheKey]; used when there is no [previewPath].
  final String? previewUrl;
  final String? previewCacheKey;

  @override
  List<Object?> get props => [
    kind,
    progress,
    isEdit,
    previewPath,
    previewUrl,
    previewCacheKey,
  ];
}

/// Sending failed; retrying sends it again, discarding drops it. A [RejectedFailure] cannot be retried.
final class ContentPublishFailed extends ContentPublishStatus {
  const ContentPublishFailed(
    super.kind, {
    required this.failure,
    this.isEdit = false,
    this.previewPath,
    this.previewUrl,
    this.previewCacheKey,
  });

  final Failure failure;
  final bool isEdit;

  bool get canRetry => failure is! RejectedFailure;

  final String? previewPath;
  final String? previewUrl;
  final String? previewCacheKey;

  @override
  List<Object?> get props => [
    kind,
    failure,
    isEdit,
    previewPath,
    previewUrl,
    previewCacheKey,
  ];
}

/// The content is sent. Announced once, then the status goes back to [ContentPublishIdle].
final class ContentPublishDone extends ContentPublishStatus {
  const ContentPublishDone(super.kind, {this.isEdit = false});

  final bool isEdit;

  @override
  List<Object?> get props => [kind, isEdit];
}

/// A discard came too late: the content had already gone out, so nothing was deleted. Announced once,
/// then the status goes back to what it was.
final class ContentDiscardRefused extends ContentPublishStatus {
  const ContentDiscardRefused(super.kind);
}
