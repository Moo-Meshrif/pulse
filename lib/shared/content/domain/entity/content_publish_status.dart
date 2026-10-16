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
  });

  final double progress;
  final bool isEdit;
  final String? previewPath;

  @override
  List<Object?> get props => [kind, progress, isEdit, previewPath];
}

/// Sending failed; retrying sends it again, discarding drops it.
final class ContentPublishFailed extends ContentPublishStatus {
  const ContentPublishFailed(
    super.kind, {
    required this.failure,
    this.isEdit = false,
    this.previewPath,
  });

  final Failure failure;
  final bool isEdit;
  final String? previewPath;

  @override
  List<Object?> get props => [kind, failure, isEdit, previewPath];
}

/// The content is sent. Announced once, then the status goes back to [ContentPublishIdle].
final class ContentPublishDone extends ContentPublishStatus {
  const ContentPublishDone(super.kind, {this.isEdit = false});

  final bool isEdit;

  @override
  List<Object?> get props => [kind, isEdit];
}
