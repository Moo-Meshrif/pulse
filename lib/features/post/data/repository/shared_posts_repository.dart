import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../shared/content/data/datasource/pending_content_datasource.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/pending_content_state.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../../domain/event/feed_refresh_requested.dart';
import '../../domain/event/post_saved.dart';
import '../datasource/post_draft_datasource.dart';
import '../enums/mood_kind.dart';
import '../model/post_draft_media_model.dart';
import '../model/post_draft_model.dart';
import '../model/post_draft_tag_model.dart';
import 'post_share_repository.dart';

/// The posts shared from New post until they are out: each is saved on this device first (like a draft,
/// in the draft's folder), sent in the background ([ContentPublishRepository]) through the server
/// ([PostShareRepository]), and forgotten with its files once it is posted or discarded. After a restart
/// [resume] asks the server where each one is and sends again only what is not out. A repository because
/// it combines the device copy, the server and the background sender.
@LazySingleton()
class SharedPostsRepository {
  SharedPostsRepository(
    this._local,
    this._server,
    this._sharing,
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

  final PostDraftDatasource _local;
  final PendingContentDatasource _server;
  final PostShareRepository _sharing;
  final ContentPublishRepository _publish;
  final EventBus _events;

  /// Hands [draft] to the background sender and returns at once; false (nothing done) while another
  /// post goes out. [build] makes the post once its files are read, on every try. [beforeUpload]
  /// completes when the draft's own uploads are done; [onStop] stops them. The draft record is replaced
  /// by the saved shared post on the first try.
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

  /// At start, for the signed-in user: each saved shared post the server says is out or discarded is
  /// forgotten with its files, and the others are sent again (only what is missing goes). A draft the
  /// server says is finished is forgotten too. Then the folders no record uses are deleted. When the
  /// saved list cannot be read, nothing is deleted but what the server says is finished. Never throws.
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

  /// False when [post] is finished and was forgotten.
  Future<bool> _resumeOne(
    PostDraftModel post,
    PendingContentState? state,
  ) async {
    final id = _idOf(post);
    if (_finished.contains(state)) {
      await _done(id);
      if (state == PendingContentState.published) {
        _events.fire(const FeedRefreshRequested());
      }
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
    final created = await _sharing.share(
      post,
      beforeUpload: beforeUpload,
      onProgress: report,
    );
    onStop?.call();
    await _done(post.id);
    _announce(created);
  }

  /// The feed shows the post at once; with no author to show it loads again.
  void _announce(PostEntity? created) => _events.fire(
    created == null ? const FeedRefreshRequested() : PostSaved(created),
  );

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

  static String? _previewOf(PostDraftModel post) {
    final first = post.media?.firstOrNull;
    if (first == null) return null;
    return (first.isVideo ?? false) ? first.poster : first.path;
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
