import 'package:injectable/injectable.dart';

import '../../data/repository/story_upload_repository.dart';
import '../entity/story_upload_status.dart';

/// How posting your story is going: idle, uploading with progress, failed, done. Home's rail listens.
@injectable
class WatchStoryUploadUseCase {
  WatchStoryUploadUseCase(this._uploads);

  final StoryUploadRepository _uploads;

  Stream<StoryUploadStatus> call() => _uploads.status;
}
