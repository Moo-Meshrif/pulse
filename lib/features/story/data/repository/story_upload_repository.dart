import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../../domain/entity/story_upload_status.dart';
import '../datasource/stories_datasource.dart';
import '../datasource/story_media_uploader.dart';
import '../model/new_story_model.dart';

/// Posts one story at a time in the background and tells how it is going. It is a repository because it
/// holds state across screens: Home's rail shows how it goes while the camera flow has already closed. Each
/// status (idle, uploading with progress, failed or done) is sent on the `EventBus` as `StoryUploadStatus`; a
/// screen that starts later reads `latest<StoryUploadStatus>()`.
abstract interface class StoryUploadRepository {
  /// Starts posting [story]; returns false (and does nothing) when another story is still going out.
  bool enqueue(NewStoryModel story);

  /// Sends the failed story again; does nothing in any other state.
  void retry();
}

@LazySingleton(as: StoryUploadRepository)
final class StoryUploadRepositoryImpl implements StoryUploadRepository {
  StoryUploadRepositoryImpl(this._stories, this._uploader, this._events);

  final StoriesDatasource _stories;
  final StoryMediaUploader _uploader;
  final EventBus _events;

  StoryUploadStatus _current = const StoryUploadIdle();
  _Attempt? _attempt;

  @override
  bool enqueue(NewStoryModel story) {
    if (_current is StoryUploading) return false;
    _attempt = _Attempt(story, _stories.currentUserId);
    _start();
    return true;
  }

  @override
  void retry() {
    if (_current is StoryUploadFailed && _attempt != null) _start();
  }

  void _emit(StoryUploadStatus status) {
    _current = status;
    _events.fireLatest<StoryUploadStatus>(status);
  }

  void _start() {
    _emit(const StoryUploading(0));
    unawaited(_run(_attempt!));
  }

  Future<void> _run(_Attempt attempt) async {
    try {
      await _post(attempt);
    } on Failure catch (failure) {
      _emit(StoryUploadFailed(failure));
      return;
    } catch (error, stackTrace) {
      _emit(StoryUploadFailed(Guard.toFailure(error, stackTrace)));
      return;
    }
    _attempt = null;
    _emit(const StoryUploadDone());
    _emit(const StoryUploadIdle());
  }

  Future<void> _post(_Attempt attempt) async {
    final story = attempt.story;
    final media = File(story.filePath);
    final thumb = story.thumbFilePath == null
        ? null
        : File(story.thumbFilePath!);
    final mediaLength = await media.length();
    final thumbLength = thumb == null ? 0 : await thumb.length();
    final total = mediaLength + thumbLength;

    void report(int sent) =>
        _emit(StoryUploading(total == 0 ? 0 : (sent / total).clamp(0.0, 1.0)));

    await _uploader.upload(
      path: attempt.mediaPath,
      file: media,
      contentType: story.type.contentType,
      onBytes: report,
    );
    if (thumb != null) {
      await _uploader.upload(
        path: attempt.thumbPath,
        file: thumb,
        contentType: 'image/jpeg',
        onBytes: (sent) => report(mediaLength + sent),
      );
    }
    await _stories.insertStory(
      story,
      mediaPath: attempt.mediaPath,
      thumbPath: thumb == null ? null : attempt.thumbPath,
    );
  }
}

/// A story being posted with the object names fixed up front, so a retry replaces the same files.
class _Attempt {
  _Attempt(this.story, String userId) : _name = uuidV4(), _userId = userId;

  final NewStoryModel story;
  final String _name;
  final String _userId;

  String get mediaPath => '$_userId/stories/$_name.${story.type.extension}';
  String get thumbPath => '$_userId/stories/${_name}_thumb.jpg';
}
