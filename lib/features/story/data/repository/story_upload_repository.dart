import 'package:injectable/injectable.dart';

import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../datasource/stories_datasource.dart';
import '../enums/story_media_type.dart';
import '../model/new_story_model.dart';

/// Posts a story through the shared background sender (`ContentPublishRepository`, kind story), which
/// tells Home how it goes on the `EventBus`. This side sends the files (`ContentMediaRepository`) and
/// inserts the row.
abstract interface class StoryUploadRepository {
  /// Starts posting [story]; returns false (and does nothing) when another story is still going out. A
  /// story that failed is dropped for this one.
  bool enqueue(NewStoryModel story);
}

@LazySingleton(as: StoryUploadRepository)
final class StoryUploadRepositoryImpl implements StoryUploadRepository {
  StoryUploadRepositoryImpl(this._stories, this._media, this._publish);

  final StoriesDatasource _stories;
  final ContentMediaRepository _media;
  final ContentPublishRepository _publish;

  @override
  bool enqueue(NewStoryModel story) {
    // Fixed up front, so a retry sends only the files still missing, under the same names.
    final folder = '${_stories.currentUserId}/stories';
    final stem = uuidV4();
    final sent = <String>{};
    return _publish.enqueue(
      kind: ContentKind.story,
      send: (report) => _post(story, folder, stem, sent, report),
      replacesFailed: true,
    );
  }

  Future<void> _post(
    NewStoryModel story,
    String folder,
    String stem,
    Set<String> sent,
    void Function(double) report,
  ) async {
    final isVideo = story.type == StoryMediaType.video;
    final media = await _media.send(
      ContentKind.story,
      MediaToSend(
        filePath: story.filePath,
        isVideo: isVideo,
        thumbFilePath: story.thumbFilePath,
        width: story.width,
        height: story.height,
        durationMs: story.durationMs,
      ),
      folder: folder,
      stem: stem,
      existing: sent,
      onProgress: report,
    );
    await _stories.insertStory(
      story,
      mediaPath: media.path,
      thumbPath: media.thumbPath,
    );
  }
}
