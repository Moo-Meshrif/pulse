import '../../../../core/error/failures.dart';
import '../../../../core/utils/equatable.dart';

/// Where posting a story stands. Public: Home's rail shows it on the "Your story" tile.
sealed class StoryUploadStatus extends Equatable {
  const StoryUploadStatus();

  @override
  List<Object?> get props => const [];
}

/// Nothing is being posted.
final class StoryUploadIdle extends StoryUploadStatus {
  const StoryUploadIdle();
}

/// The files are going out; [progress] is 0..1 by bytes sent.
final class StoryUploading extends StoryUploadStatus {
  const StoryUploading(this.progress);

  final double progress;

  @override
  List<Object?> get props => [progress];
}

/// Posting failed; retrying sends it again.
final class StoryUploadFailed extends StoryUploadStatus {
  const StoryUploadFailed(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// The story is posted. Announced once, then the status goes back to [StoryUploadIdle].
final class StoryUploadDone extends StoryUploadStatus {
  const StoryUploadDone();
}
