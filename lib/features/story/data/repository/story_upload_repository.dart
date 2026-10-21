import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../../../shared/content/data/datasource/pending_content_datasource.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/pending_content_state.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../datasource/stories_datasource.dart';
import '../enums/story_media_type.dart';
import '../model/new_story_model.dart';

/// Posts a story through the shared background sender (`ContentPublishRepository`, kind story), which
/// tells Home how it goes on the `EventBus`. This side sends the files (`ContentMediaRepository`) and
/// inserts the row. A story with a post sticker goes through the server's `share_content` and
/// `publish_content` instead, which check the post can be shared (`PendingContentDatasource`).
abstract interface class StoryUploadRepository {
  /// Starts posting [story]; returns false (and does nothing) when another story is still going out. A
  /// story that failed is dropped for this one.
  bool enqueue(NewStoryModel story);
}

@LazySingleton(as: StoryUploadRepository)
final class StoryUploadRepositoryImpl implements StoryUploadRepository {
  StoryUploadRepositoryImpl(
    this._stories,
    this._media,
    this._publish,
    this._pending,
  );

  final StoriesDatasource _stories;
  final ContentMediaRepository _media;
  final ContentPublishRepository _publish;
  final PendingContentDatasource _pending;

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
    final item = MediaToSend(
      filePath: story.filePath,
      isVideo: story.type == StoryMediaType.video,
      thumbFilePath: story.thumbFilePath,
      width: story.width,
      height: story.height,
      durationMs: story.durationMs,
      edit: story.edit,
    );
    final media = await _media.send(
      ContentKind.story,
      item,
      folder: folder,
      stem: stem,
      existing: sent,
      onProgress: report,
    );
    if (story.sticker != null) {
      final target = await _media.target(
        ContentKind.story,
        item,
        folder: folder,
        stem: stem,
      );
      await _shareWithPost(story, stem, target);
      return;
    }
    await _stories.insertStory(
      story,
      mediaPath: media.path,
      thumbPath: media.thumbPath,
    );
  }

  /// The server posts a story with a sticker itself: it is shared under the id the files are named by, then
  /// posted once its file is there. Both calls are safe to repeat, so Retry runs them again.
  Future<void> _shareWithPost(
    NewStoryModel story,
    String id,
    MediaTarget target,
  ) async {
    final state = await _pending.share(
      id,
      ContentKind.story,
      _request(story, target),
    );
    if (state == PendingContentState.published) return;
    final published = await _pending.publish(id);
    if (published == PendingContentState.published) return;
    throw published == PendingContentState.rejected
        ? const RejectedFailure()
        : const ServerFailure();
  }

  /// What `share_content` saves for a story: the row's columns and the file's path, type and size.
  static Map<String, dynamic> _request(
    NewStoryModel story,
    MediaTarget target,
  ) => {
    'type': story.type.wire,
    'path': target.path,
    'size': target.sizeBytes,
    'mime': target.mimeType,
    'width': story.width,
    'height': story.height,
    'blurhash': story.blurhash,
    'overlays': story.overlays.map((o) => o.toJson()).toList(),
    'audience': ContentAudience.followers.wire,
    'shared_post_id': story.sharedPostId,
    'sticker': story.sticker?.toJson(),
  };
}
