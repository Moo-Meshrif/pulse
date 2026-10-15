import '../../../../core/error/failures.dart';
import '../../../../core/utils/equatable.dart';

/// Where sharing or saving a post stands. Public: Home shows it above the feed.
sealed class PostPublishStatus extends Equatable {
  const PostPublishStatus();

  @override
  List<Object?> get props => const [];
}

/// Nothing is being sent.
final class PostPublishIdle extends PostPublishStatus {
  const PostPublishIdle();
}

/// The post is going out. [previewPath] is the first picked file on this device, if any.
final class PostPublishing extends PostPublishStatus {
  const PostPublishing({required this.isEdit, this.previewPath});

  final bool isEdit;
  final String? previewPath;

  @override
  List<Object?> get props => [isEdit, previewPath];
}

/// Sending failed; retrying sends it again, discarding drops it.
final class PostPublishFailed extends PostPublishStatus {
  const PostPublishFailed({
    required this.failure,
    required this.isEdit,
    this.previewPath,
  });

  final Failure failure;
  final bool isEdit;
  final String? previewPath;

  @override
  List<Object?> get props => [failure, isEdit, previewPath];
}

/// The post is sent. Announced once, then the status goes back to [PostPublishIdle].
final class PostPublishDone extends PostPublishStatus {
  const PostPublishDone({required this.isEdit});

  final bool isEdit;

  @override
  List<Object?> get props => [isEdit];
}
