import 'package:injectable/injectable.dart';

import '../../data/repository/story_upload_repository.dart';

/// Sends the story whose upload failed again.
@injectable
class RetryStoryUploadUseCase {
  RetryStoryUploadUseCase(this._uploads);

  final StoryUploadRepository _uploads;

  void call() => _uploads.retry();
}
