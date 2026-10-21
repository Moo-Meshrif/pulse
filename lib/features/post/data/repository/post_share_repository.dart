import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/content/data/datasource/pending_content_datasource.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/pending_content_state.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../domain/entity/new_post_entity.dart';
import '../../domain/entity/new_post_media_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_media_entity.dart';
import '../datasource/posts_datasource.dart';
import '../model/post_share_media_model.dart';
import '../model/post_share_request_model.dart';

/// Shares a new post through the server: saves what to post (`share_content`), sends the files that are
/// not on the server yet, then asks the server to post it (`publish_content`); the server's minute job
/// posts it too once the files are there. Every step is safe to repeat, so Retry runs it all again. When
/// an answer is lost (offline, timeout) it asks the server where the post is first, so a post that went
/// out is never sent again. A post the server will never publish (rejected, discarded or abandoned)
/// throws a [RejectedFailure]. A repository because it combines the server, the files and storage.
@injectable
class PostShareRepository {
  PostShareRepository(this._server, this._media, this._posts);

  final PendingContentDatasource _server;
  final ContentMediaRepository _media;
  final PostsDatasource _posts;

  /// The server will never publish an item in these states.
  static const _refused = {
    PendingContentState.rejected,
    PendingContentState.discarded,
    PendingContentState.abandoned,
  };

  /// Returns the post as the feed shows it, or null when the author is unknown (the feed has to load
  /// again). [beforeUpload] completes when the files already on their way are uploaded, so nothing is sent
  /// twice. [onProgress] is told how much of the files went out (0..1). Throws a `Failure` when the post
  /// did not go out.
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
      // Waiting: a file is not there as shared, or an older shared post goes first.
      if (published != PendingContentState.published) {
        throw const ServerFailure();
      }
    }
    return _toFeed(post, targets);
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
      final known = await _stateOrNull(id);
      if (_refused.contains(known)) throw const RejectedFailure();
      final isLost = failure is NetworkFailure || failure is TimeoutFailure;
      if (!isLost || !done.contains(known)) rethrow;
      return known;
    }
  }

  Future<PendingContentState?> _stateOrNull(String id) async {
    try {
      final rows = await _server.status([id]);
      return rows.where((row) => row.id == id).firstOrNull?.state;
    } on Failure {
      return null;
    }
  }

  static String _stem(NewPostMediaEntity item, int index) =>
      item.id ?? '$index';

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
          media: item.toModel(_sent(targets[i])),
          mimeType: targets[i].mimeType,
          sizeBytes: targets[i].sizeBytes,
          thumbMimeType: targets[i].thumbPath == null
              ? null
              : MediaTarget.thumbMimeType,
          thumbSizeBytes: targets[i].thumbSizeBytes,
        ),
    ],
  );

  static SentMedia _sent(MediaTarget target) =>
      SentMedia(path: target.path, thumbPath: target.thumbPath);

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
}
