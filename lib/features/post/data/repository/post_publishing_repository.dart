import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../shared/content/data/datasource/pending_content_datasource.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/pending_content_state.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_media_entity.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../../domain/event/post_saved.dart';
import '../datasource/post_draft_datasource.dart';
import '../datasource/posts_datasource.dart';
import '../enums/mood_kind.dart';
import '../model/post_draft_media_model.dart';
import '../model/post_draft_model.dart';
import '../model/post_draft_tag_model.dart';
import '../model/post_share_media_model.dart';
import '../model/post_share_request_model.dart';

/// Posts shared from New post: saved on the device, sent in the background until they are out, and
/// sent again after a restart.
abstract class PostPublishingRepository {
  /// Hands [draft] to the background sender and returns at once; false (nothing done) while another
  /// post goes out. [build] makes the post once its files are read, on every try. [beforeUpload]
  /// completes when the draft's own uploads are done; [onStop] stops them.
  bool send(
    PostDraftModel draft, {
    required Future<NewPostEntity> Function() build,
    Future<void> Function()? beforeUpload,
    void Function()? onStop,
    String? previewPath,
  });

  /// At start: finished posts (and a finished draft) are forgotten with their files, the others are sent
  /// again, and unused folders are deleted. Never throws.
  Future<void> resume();
}

/// Sending saves the post (`share_content`), uploads the missing files, then asks the server to publish
/// it (`publish_content`); the server's minute job publishes it too once the files are there. Every step
/// is safe to repeat. When an answer is lost, the server's state for the post is checked first, so a post
/// that went out is never sent again. A post the server will never publish throws a [RejectedFailure].
@LazySingleton(as: PostPublishingRepository)
class PostPublishingRepositoryImpl implements PostPublishingRepository {
  PostPublishingRepositoryImpl(
    this._local,
    this._server,
    this._media,
    this._posts,
    this._publish,
    this._events,
  );

  /// A photo whose size is unknown is shared as this square (as New post does).
  static const _fallbackSide = 1080;

  /// The server will never post an item in these states.
  static const _finished = {
    PendingContentState.published,
    PendingContentState.discarded,
    PendingContentState.abandoned,
  };

  /// The server will never publish an item in these states.
  static const _refused = {
    PendingContentState.rejected,
    PendingContentState.discarded,
    PendingContentState.abandoned,
  };

  final PostDraftDatasource _local;
  final PendingContentDatasource _server;
  final ContentMediaRepository _media;
  final PostsDatasource _posts;
  final ContentPublishRepository _publish;
  final EventBus _events;

  @override
  bool send(
    PostDraftModel draft, {
    required Future<NewPostEntity> Function() build,
    Future<void> Function()? beforeUpload,
    void Function()? onStop,
    String? previewPath,
  }) {
    var isFirstTry = true;
    return _enqueue(
      draft,
      previewPath: previewPath,
      onStop: onStop,
      send: (report) async {
        if (isFirstTry) {
          isFirstTry = false;
          await _handOver(draft);
        }
        final post = await build();
        await _saveQuietly(_record(post, isOnServer: draft.isOnServer));
        await _share(post, beforeUpload, onStop, report);
      },
    );
  }

  @override
  Future<void> resume() async {
    final shared = _local.readShared();
    final draft = _local.read();
    final states = await _statesOrNull(
      shared == null ? null : [...shared.map(_idOf), ?draft?.id],
    );
    final kept = <String>{};
    for (final post in shared ?? const <PostDraftModel>[]) {
      if (await _resumeOne(post, states?[_idOf(post)])) kept.add(_idOf(post));
    }
    if (draft != null) {
      if (_finished.contains(states?[draft.id])) {
        await _forgetDraft(draft.id!);
      } else {
        kept.add(draft.id!);
      }
    }
    if (shared == null) {
      if (states == null) return; // nothing known: every folder stays
      kept.addAll(await _unfinishedOnServer(states));
    }
    await _local.deleteFoldersExcept(kept);
  }

  /// Returns the post as the feed shows it, or null when the author is unknown. [beforeUpload] completes
  /// when files already on their way are uploaded, so nothing is sent twice. Throws a `Failure` when the
  /// post did not go out.
  @visibleForTesting
  Future<PostEntity?> share(
    NewPostEntity post, {
    Future<void> Function()? beforeUpload,
    void Function(double progress)? onProgress,
  }) async {
    final folder = _media.folderOf(post.id);
    final targets = await _targets(post, folder);
    final shared = await _answer(
      post.id,
      () => _server.share(
        post.id,
        ContentKind.post,
        _request(post, targets).toJson(),
      ),
      done: const {PendingContentState.waiting, PendingContentState.published},
    );
    if (shared != PendingContentState.published) {
      await beforeUpload?.call();
      await _sendMissing(post, folder, onProgress);
      final published = await _answer(
        post.id,
        () => _server.publish(post.id),
        done: const {PendingContentState.published},
      );
      if (_refused.contains(published)) throw const RejectedFailure();
      // Waiting: a file is missing on the server, or an older shared post goes first.
      if (published != PendingContentState.published) {
        throw const ServerFailure();
      }
    }
    return _toFeed(post, targets);
  }

  /// False when [post] is finished and was forgotten.
  Future<bool> _resumeOne(
    PostDraftModel post,
    PendingContentState? state,
  ) async {
    final id = _idOf(post);
    if (_finished.contains(state)) {
      await _done(id);
      return false;
    }
    if (!_publish.hasJob(id)) {
      _enqueue(
        post,
        previewPath: _previewOf(post),
        send: (report) => _share(_toPost(post), null, null, report),
      );
    }
    return true;
  }

  bool _enqueue(
    PostDraftModel post, {
    required PublishWork send,
    String? previewPath,
    void Function()? onStop,
  }) => _publish.enqueue(
    kind: ContentKind.post,
    pendingId: post.id,
    previewPath: previewPath,
    onDiscard: () async {
      onStop?.call();
      await _done(_idOf(post));
    },
    send: send,
  );

  Future<void> _share(
    NewPostEntity post,
    Future<void> Function()? beforeUpload,
    void Function()? onStop,
    void Function(double) report,
  ) async {
    final created = await share(
      post,
      beforeUpload: beforeUpload,
      onProgress: report,
    );
    onStop?.call();
    await _done(post.id);
    // The feed shows the post at once; with no author to show it, it waits for the next load.
    if (created != null) _events.fire(PostSaved(created));
  }

  /// Where each file goes and what the server should find there.
  Future<List<MediaTarget>> _targets(NewPostEntity post, String folder) =>
      Future.wait([
        for (final (i, item) in post.media.indexed)
          _media.target(
            ContentKind.post,
            item.toSend(),
            folder: folder,
            stem: _stem(item, i),
          ),
      ]);

  /// Sends the files that are not in [folder] yet; one listing for all of them.
  Future<void> _sendMissing(
    NewPostEntity post,
    String folder,
    void Function(double progress)? onProgress,
  ) async {
    final existing = await _media.existing(folder);
    final count = post.media.length;
    for (final (i, item) in post.media.indexed) {
      await _media.send(
        ContentKind.post,
        item.toSend(),
        folder: folder,
        stem: _stem(item, i),
        existing: existing,
        onProgress: (part) => onProgress?.call((i + part) / count),
      );
    }
  }

  /// [call]'s state. When it fails, the state the server has for [id] decides: refused for good throws
  /// a [RejectedFailure]; a lost answer whose call went through (one of [done]) returns that state;
  /// otherwise the failure.
  Future<PendingContentState?> _answer(
    String id,
    Future<PendingContentState?> Function() call, {
    required Set<PendingContentState> done,
  }) async {
    try {
      return await call();
    } on Failure catch (failure) {
      final known = (await _statesOrNull([id]))?[id];
      if (_refused.contains(known)) throw const RejectedFailure();
      final isLost = failure is NetworkFailure || failure is TimeoutFailure;
      if (!isLost || !done.contains(known)) rethrow;
      return known;
    }
  }

  /// From now on the post survives the app closing as a shared post, not as the draft.
  Future<void> _handOver(PostDraftModel draft) async {
    await _saveQuietly(draft);
    try {
      await _local.forget();
    } on Failure {
      // the draft opens again; Share is refused for it by the server once it is out
    }
  }

  /// Best effort: the post still goes out, it is only not resumed if the app closes.
  Future<void> _saveQuietly(PostDraftModel post) async {
    try {
      await _local.saveShared(post);
    } on Failure {
      // kept as last saved
    }
  }

  /// Forgets the shared post [id] and deletes its files on the device. Never throws.
  Future<void> _done(String id) async {
    try {
      await _local.forgetShared(id);
    } on Failure {
      // forgotten at the next start, when the server says it is finished
    }
    await _local.deleteFiles(id);
  }

  Future<void> _forgetDraft(String id) async {
    try {
      await _local.forget();
    } on Failure {
      return; // asked again at the next start
    }
    await _local.deleteFiles(id);
  }

  /// Each item's state by id; null when the server cannot be asked. [ids] null asks for every item that
  /// is not finished.
  Future<Map<String, PendingContentState?>?> _statesOrNull(
    List<String>? ids,
  ) async {
    if (ids != null && ids.isEmpty) return const {};
    try {
      final rows = await _server.status(ids);
      return {
        for (final row in rows)
          if (row.id != null) row.id!: row.state,
      };
    } on Failure {
      return null;
    }
  }

  /// The saved list could not be read: what the server still waits for is posted if its files are all
  /// there, and the folders of every unfinished item stay.
  Future<Set<String>> _unfinishedOnServer(
    Map<String, PendingContentState?> states,
  ) async {
    for (final entry in states.entries) {
      if (entry.value != PendingContentState.waiting) continue;
      try {
        await _server.publish(entry.key);
      } on Failure {
        // the server's minute job posts it once its files are there
      }
    }
    return states.keys.toSet();
  }

  static String _idOf(PostDraftModel post) => post.id!;

  static String _stem(NewPostMediaEntity item, int index) =>
      item.id ?? '$index';

  static String? _previewOf(PostDraftModel post) {
    final first = post.media?.firstOrNull;
    if (first == null) return null;
    return (first.isVideo ?? false) ? first.poster : first.path;
  }

  static PostShareRequestModel _request(
    NewPostEntity post,
    List<MediaTarget> targets,
  ) => PostShareRequestModel(
    caption: post.caption,
    location: post.location,
    commentsEnabled: post.commentsEnabled,
    visibility: post.visibility,
    moodKind: post.mood?.kind,
    moodKey: post.mood?.key,
    moodText: post.mood?.text,
    tags: [for (final tag in post.tags) tag.toModel()],
    media: [
      for (final (i, item) in post.media.indexed)
        PostShareMediaModel(
          media: item.toModel(
            SentMedia(path: targets[i].path, thumbPath: targets[i].thumbPath),
          ),
          mimeType: targets[i].mimeType,
          sizeBytes: targets[i].sizeBytes,
          thumbMimeType: targets[i].thumbPath == null
              ? null
              : MediaTarget.thumbMimeType,
          thumbSizeBytes: targets[i].thumbSizeBytes,
        ),
    ],
  );

  PostEntity? _toFeed(NewPostEntity post, List<MediaTarget> targets) {
    final username = post.authorUsername;
    if (username == null) return null;
    return PostEntity(
      id: post.id,
      authorId: _posts.currentUserId,
      username: username,
      fullName: post.authorFullName,
      avatarUrl: post.authorAvatarUrl,
      caption: post.caption,
      location: post.location,
      likeCount: 0,
      commentCount: 0,
      commentsEnabled: post.commentsEnabled,
      visibility: post.visibility,
      createdAt: clock.now(),
      likedByMe: false,
      savedByMe: false,
      mood: post.mood,
      tags: post.tags,
      tagCount: post.tags.length,
      media: [
        for (final (i, item) in post.media.indexed)
          PostMediaEntity(
            isVideo: item.isVideo,
            path: targets[i].path,
            thumbPath: targets[i].thumbPath,
            width: item.width,
            height: item.height,
            durationMs: item.durationMs,
            blurhash: item.blurhash,
          ),
      ],
    );
  }

  /// [post] as saved: the same fields, so the post built from it again is the same request.
  static PostDraftModel _record(
    NewPostEntity post, {
    required bool isOnServer,
  }) => PostDraftModel(
    id: post.id,
    isOnServer: isOnServer,
    caption: post.caption,
    location: post.location,
    commentsEnabled: post.commentsEnabled,
    visibility: post.visibility.wire,
    moodKind: post.mood?.kind.wire,
    moodKey: post.mood?.key,
    moodText: post.mood?.text,
    tags: [
      for (final tag in post.tags)
        PostDraftTagModel(
          userId: tag.userId,
          username: tag.username,
          fullName: tag.fullName,
          mediaPosition: tag.mediaPosition,
          x: tag.x,
          y: tag.y,
        ),
    ],
    media: [
      for (final item in post.media)
        PostDraftMediaModel(
          id: item.id,
          path: item.filePath,
          isVideo: item.isVideo,
          width: item.width,
          height: item.height,
          durationMs: item.durationMs,
          blurhash: item.blurhash,
          poster: item.thumbFilePath,
        ),
    ],
  );

  /// The post a saved one shares. A record saved before its files were read (the app closed right after
  /// Share) gets New post's fallbacks.
  static NewPostEntity _toPost(PostDraftModel post) {
    final caption = post.caption?.trim();
    return NewPostEntity(
      id: _idOf(post),
      caption: caption == null || caption.isEmpty ? null : caption,
      location: post.location,
      commentsEnabled: post.commentsEnabled ?? true,
      visibility:
          ContentAudience.fromWire(post.visibility) ?? ContentAudience.public,
      mood: _mood(post),
      tags: [
        for (final tag in post.tags ?? const <PostDraftTagModel>[])
          if (tag.userId != null)
            PostTagEntity(
              userId: tag.userId!,
              username: tag.username,
              fullName: tag.fullName,
              mediaPosition: tag.mediaPosition,
              x: tag.x,
              y: tag.y,
            ),
      ],
      media: [
        for (final item in post.media ?? const <PostDraftMediaModel>[])
          if (item.path != null) _toMedia(item),
      ],
    );
  }

  static NewPostMediaEntity _toMedia(PostDraftMediaModel item) {
    final isVideo = item.isVideo ?? false;
    return NewPostMediaEntity(
      id: item.id,
      filePath: item.path!,
      isVideo: isVideo,
      thumbFilePath: isVideo ? item.poster : null,
      width: item.width ?? _fallbackSide,
      height: item.height ?? _fallbackSide,
      durationMs: isVideo ? (item.durationMs ?? 0) : null,
      blurhash: item.blurhash,
    );
  }

  static PostMoodEntity? _mood(PostDraftModel post) {
    final kind = MoodKind.fromWire(post.moodKind);
    final key = post.moodKey;
    if (kind == null || key == null) return null;
    return PostMoodEntity(kind: kind, key: key, text: post.moodText);
  }
}
