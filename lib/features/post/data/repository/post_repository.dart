import 'dart:async';

import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/content/data/datasource/media_files_datasource.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/repository/content_changes_repository.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/data/repository/content_publish_repository.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../../domain/entity/comment_cursor_entity.dart';
import '../../domain/entity/comment_entity.dart';
import '../../domain/entity/comment_page_entity.dart';
import '../../domain/entity/edit_post_entity.dart';
import '../../domain/entity/liked_by_preview_entity.dart';
import '../../domain/entity/mention_person_entity.dart';
import '../../domain/entity/post_entity.dart';
import '../../domain/entity/post_liker_entity.dart';
import '../../domain/entity/post_likers_cursor_entity.dart';
import '../../domain/entity/post_likers_page_entity.dart';
import '../../domain/entity/post_media_entity.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../../domain/entity/post_tag_entity.dart';
import '../../domain/entity/tag_person_entity.dart';
import '../../domain/entity/tagged_person_entity.dart';
import '../../domain/mapper/comment_entity_mapper.dart';
import '../../domain/mapper/liked_by_preview_mapper.dart';
import '../../domain/mapper/post_entity_mapper.dart';
import '../datasource/comments_datasource.dart';
import '../datasource/comments_local_datasource.dart';
import '../datasource/post_actions_datasource.dart';
import '../datasource/post_likes_datasource.dart';
import '../datasource/post_tags_datasource.dart';
import '../datasource/posts_datasource.dart';
import '../enums/comment_sort.dart';
import '../enums/follow_state.dart';
import '../enums/media_type.dart';
import '../model/mention_person_model.dart';
import '../model/post_liker_model.dart';
import '../model/post_media_model.dart';
import '../model/post_tag_model.dart';

/// What the post screens read and write: comments, actions on a post, one post, its likes and its tags.
/// Every call throws a `Failure` on error. The feed, the New post draft and shared posts have their own
/// repositories.
abstract class PostRepository {
  static const commentsPageSize = 20;
  static const repliesPageSize = 20;
  static const likersPageSize = 20;

  /// The first page of [postId]'s comments saved on the device for [userId] in [sort]; null when none.
  CommentPageEntity? savedComments(
    String userId,
    String postId,
    CommentSort sort,
  );

  /// A page of [postId]'s top-level comments with their first replies. Pass the previous page's
  /// `nextCursor` as [before] for the next one. [focusCommentId] puts that thread first on the first
  /// page; pass it on every page. A first page without a focus comment is also saved for [userId].
  Future<CommentPageEntity> comments(
    String postId, {
    required CommentSort sort,
    String? userId,
    CommentCursorEntity? before,
    String? focusCommentId,
  });

  /// The replies of a top-level comment after [after] (none = from the start), oldest first. Fewer than
  /// [repliesPageSize] means the thread is complete.
  Future<List<CommentEntity>> replies(String commentId, {CommentEntity? after});

  /// Writes a comment on [postId], or a reply when [parentId] is set. The same [clientId] writes once, so
  /// a retry is safe. Throws a [NotFoundFailure] when the post is gone, a [RejectedFailure] when comments
  /// are off.
  Future<CommentEntity> addComment(
    String postId,
    String body, {
    String? parentId,
    required String clientId,
  });

  /// Changes the words of your own comment and returns it as saved.
  Future<CommentEntity> editComment(String commentId, String body);

  /// People to suggest for `@query` in a comment on [postId]: the thread first, then your followers.
  Future<List<MentionPersonEntity>> mentionCandidates(
    String postId,
    String query,
  );

  /// Likes or unlikes a post and returns its like count afterwards.
  Future<int> setLike(String postId, {required bool liked});

  /// Saves or unsaves a post and returns where the save stands afterwards.
  Future<bool> setSave(String postId, {required bool saved});

  /// Hides a post from the feed ("Not interested"); hidden false is Undo.
  Future<void> hidePost(String postId, {required bool hidden});

  /// Turns comments on or off for the signed-in user's post.
  Future<void> setCommentsEnabled(String postId, {required bool enabled});

  /// Deletes the post, then its files (best effort). The files are listed first, while the post still
  /// shows.
  Future<void> deletePost(String postId);

  /// One post for its own page, as the signed-in user can see it now; null when it is gone or hidden.
  Future<PostEntity?> post(String postId);

  /// The posts and shorts [ids] (at most 50) as the signed-in user can see them now. One the user can no
  /// longer see, or that is gone, is not in the answer.
  Future<List<PostEntity>> postsByIds(List<String> ids);

  /// Short-lived links for post media [paths], by path; a path that cannot be signed is missing.
  Future<Map<String, String>> signMediaUrls(List<String> paths);

  /// Saves an edited post in one call, uploading added files first under new names so the post keeps its
  /// old media until the save succeeds, then removes files the post no longer uses. If an upload or the
  /// save fails, this try's files are removed and the failure is thrown. Returns the post as saved; null
  /// when it was saved but could not be read back (the caller reloads it). [onProgress] goes 0..1.
  Future<PostEntity?> updatePost(
    EditPostEntity post, {
    required PostEntity before,
    void Function(double progress)? onProgress,
  });

  /// Shares a Public post to your own feed. It goes out in the background and shows in Home's banner;
  /// returns false (nothing done) while three posts are already going out. A post that is gone or can't
  /// be shared fails in the banner with a `NotFoundFailure`. A null [audience] is your default one.
  bool shareToFeed(
    String postId, {
    String? caption,
    ContentAudience? audience,
    PostMoodEntity? mood,
    String? location,
    List<PostTagEntity> tags,
  });

  /// The "Liked by" row of [postId]; null when nobody else liked it or the row is incomplete.
  Future<LikedByPreviewEntity?> likedByPreview(String postId);

  /// The "Liked by" rows of up to 50 posts, by post id. A post that is not visible, has no likes or has an
  /// incomplete row is missing from the map.
  Future<Map<String, LikedByPreviewEntity>> likedByPreviews(
    List<String> postIds,
  );

  /// A page of the people who liked [postId] that the signed-in user may see, newest first; [query]
  /// narrows it by name or username. Pass the previous page's `nextCursor` as [before] for the next one.
  /// A row missing something the list needs is left out.
  Future<PostLikersPageEntity> likers(
    String postId, {
    String? query,
    PostLikersCursorEntity? before,
  });

  /// Everyone tagged on [postId], with how you follow each. A row missing something the list needs is
  /// left out.
  Future<List<TaggedPersonEntity>> taggedPeople(String postId);

  /// People you can tag: the ones you follow for a blank [query], otherwise those matching it. A row
  /// missing something the list needs is left out.
  Future<List<TagPersonEntity>> searchTagPeople([String? query]);

  /// Removes your tag from [postId]. Returns false when you were not tagged. You cannot be tagged on
  /// that post again for 24 hours.
  Future<bool> removeMyTag(String postId);
}

@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl(
    this._posts,
    this._actions,
    this._comments,
    this._commentsLocal,
    this._likes,
    this._tags,
    this._files,
    this._media,
    this._publish,
    this._changes,
  );

  final PostsDatasource _posts;
  final PostActionsDatasource _actions;
  final CommentsDatasource _comments;
  final CommentsLocalDatasource _commentsLocal;
  final PostLikesDatasource _likes;
  final PostTagsDatasource _tags;
  final MediaFilesDatasource _files;
  final ContentMediaRepository _media;
  final ContentPublishRepository _publish;
  final ContentChangesRepository _changes;

  @override
  CommentPageEntity? savedComments(
    String userId,
    String postId,
    CommentSort sort,
  ) {
    final page = _commentsLocal.read(userId, postId, sort);
    return page == null ? null : CommentEntityMapper.page(page);
  }

  @override
  Future<CommentPageEntity> comments(
    String postId, {
    required CommentSort sort,
    String? userId,
    CommentCursorEntity? before,
    String? focusCommentId,
  }) async {
    final page = await _comments.getComments(
      postId,
      sort: sort,
      limit: PostRepository.commentsPageSize,
      beforeRank: before?.rank,
      beforeCreated: before?.createdAt,
      beforeId: before?.id,
      focusCommentId: focusCommentId,
    );
    if (userId != null && before == null && focusCommentId == null) {
      unawaited(_commentsLocal.write(userId, postId, sort, page));
    }
    return CommentEntityMapper.page(page);
  }

  @override
  Future<List<CommentEntity>> replies(
    String commentId, {
    CommentEntity? after,
  }) async => CommentEntityMapper.list(
    await _comments.getReplies(
      commentId,
      limit: PostRepository.repliesPageSize,
      afterCreated: after?.createdAt,
      afterId: after?.id,
    ),
  );

  @override
  Future<CommentEntity> addComment(
    String postId,
    String body, {
    String? parentId,
    required String clientId,
  }) async {
    final comment = await _comments.addComment(
      postId,
      body,
      parentId: parentId,
      clientId: clientId,
    );
    return CommentEntityMapper.fromModel(comment) ??
        (throw const ParseFailure());
  }

  @override
  Future<CommentEntity> editComment(String commentId, String body) async {
    final comment = await _comments.editComment(commentId, body);
    return CommentEntityMapper.fromModel(comment) ??
        (throw const ParseFailure());
  }

  @override
  Future<List<MentionPersonEntity>> mentionCandidates(
    String postId,
    String query,
  ) async {
    final people = await _comments.getMentionCandidates(postId, query);
    return [for (final person in people) ?_mentionPerson(person)];
  }

  MentionPersonEntity? _mentionPerson(MentionPersonModel person) {
    final id = person.id;
    final username = person.username;
    if (id == null || username == null) return null;
    return MentionPersonEntity(
      id: id,
      username: username,
      fullName: person.fullName,
      avatarUrl: person.avatarUrl,
    );
  }

  @override
  Future<int> setLike(String postId, {required bool liked}) =>
      _actions.setLike(postId, liked: liked);

  @override
  Future<bool> setSave(String postId, {required bool saved}) =>
      _actions.setSave(postId, saved: saved);

  @override
  Future<void> hidePost(String postId, {required bool hidden}) =>
      _actions.hidePost(postId, hidden: hidden);

  @override
  Future<void> setCommentsEnabled(String postId, {required bool enabled}) =>
      _actions.setCommentsEnabled(postId, enabled: enabled);

  @override
  Future<void> deletePost(String postId) async {
    final paths = await _files.listFolder(postId);
    await _actions.deletePost(postId);
    await _files.remove(paths);
    await _changes.check(ContentKind.post);
  }

  @override
  Future<PostEntity?> post(String postId) async {
    final model = await _posts.getPost(postId);
    return model == null ? null : PostEntityMapper.fromModel(model);
  }

  @override
  Future<List<PostEntity>> postsByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final posts = await _posts.getPostsByIds(ids);
    return [for (final post in posts) ?PostEntityMapper.fromModel(post)];
  }

  @override
  Future<Map<String, String>> signMediaUrls(List<String> paths) =>
      _posts.signMediaUrls(paths);

  @override
  Future<PostEntity?> updatePost(
    EditPostEntity post, {
    required PostEntity before,
    void Function(double progress)? onProgress,
  }) async {
    final folder = '${_posts.currentUserId}/${post.id}';
    // Every file of this try starts with it: only those are removed when the try fails.
    final stem = 'e${clock.now().microsecondsSinceEpoch}_';

    final count = post.added.length;
    final added = <PostMediaModel>[];
    try {
      for (var i = 0; i < count; i++) {
        final item = post.added[i];
        final sent = await _media.send(
          ContentKind.post,
          item.toSend(),
          folder: folder,
          stem: '$stem$i',
          onProgress: (part) => onProgress?.call((i + part) / count),
        );
        added.add(item.toModel(sent));
      }
    } catch (_) {
      await _removeAttemptFiles(folder, stem);
      rethrow;
    }

    try {
      await _posts.updatePost(
        id: post.id,
        caption: post.caption,
        location: post.location,
        media: [for (final item in post.kept) _mediaModel(item), ...added],
        moodKind: post.mood?.kind,
        moodKey: post.mood?.key,
        moodText: post.mood?.text,
        tags: [for (final tag in post.tags) tag.toModel()],
        commentsEnabled: post.commentsEnabled != before.commentsEnabled
            ? post.commentsEnabled
            : null,
        audience: post.visibility != before.visibility ? post.visibility : null,
      );
    } catch (_) {
      await _removeAttemptFilesUnlessSaved(post.id, folder, stem);
      rethrow;
    }

    final kept = {
      for (final item in post.kept) ...[item.path, ?item.thumbPath],
    };
    await _media.removeQuietly(
      [
        for (final item in before.media) ...[item.path, ?item.thumbPath],
      ].where((path) => !kept.contains(path)).toList(),
    );
    return _readSaved(post.id);
  }

  /// The post as the server has it now, or null when it can't be read: the edit is saved either way, so
  /// a failed read must not fail it (a retry would upload everything again).
  Future<PostEntity?> _readSaved(String id) async {
    try {
      return await post(id);
    } on Object {
      return null;
    }
  }

  /// Removes the files of one try ([stem]) from [folder], thumbnails included. Never touches other files,
  /// and never throws: a leftover must not hide why the edit failed.
  Future<void> _removeAttemptFiles(String folder, String stem) async {
    try {
      final names = await _media.existing(folder);
      await _media.removeQuietly([
        for (final name in names)
          if (name.startsWith(stem)) '$folder/$name',
      ]);
    } on Object {
      // Leftover files are not worth an error.
    }
  }

  /// The save may have gone through with only its answer lost, so the files of this try go only when the
  /// server shows the post does not use them; when it can't tell they stay.
  Future<void> _removeAttemptFilesUnlessSaved(
    String id,
    String folder,
    String stem,
  ) async {
    try {
      final saved = await post(id);
      final used =
          saved?.media.any((item) => item.path.startsWith('$folder/$stem')) ??
          false;
      if (used) return;
    } on Object {
      return;
    }
    await _removeAttemptFiles(folder, stem);
  }

  PostMediaModel _mediaModel(PostMediaEntity item) => PostMediaModel(
    type: item.isVideo ? MediaType.video : MediaType.image,
    path: item.path,
    thumbPath: item.thumbPath,
    width: item.width,
    height: item.height,
    durationMs: item.durationMs,
    blurhash: item.blurhash,
  );

  @override
  bool shareToFeed(
    String postId, {
    String? caption,
    ContentAudience? audience,
    PostMoodEntity? mood,
    String? location,
    List<PostTagEntity> tags = const [],
  }) => _publish.enqueue(
    kind: ContentKind.post,
    send: (_) async {
      await _posts.shareToFeed(
        postId: postId,
        caption: caption,
        audience: audience,
        moodKind: mood?.kind,
        moodKey: mood?.key,
        moodText: mood?.text,
        location: location,
        tags: [for (final tag in tags) PostTagModel(userId: tag.userId)],
      );
      // The new share arrives in the feed through the change check (the feed adds it on top).
      await _changes.check(ContentKind.post);
    },
  );

  @override
  Future<LikedByPreviewEntity?> likedByPreview(String postId) async {
    final model = await _likes.getPreview(postId);
    return model == null ? null : LikedByPreviewMapper.fromModel(model);
  }

  @override
  Future<Map<String, LikedByPreviewEntity>> likedByPreviews(
    List<String> postIds,
  ) async {
    final models = await _likes.getPreviews(postIds);
    final previews = <String, LikedByPreviewEntity>{};
    for (final entry in models.entries) {
      final preview = LikedByPreviewMapper.fromModel(entry.value);
      if (preview != null) previews[entry.key] = preview;
    }
    return previews;
  }

  @override
  Future<PostLikersPageEntity> likers(
    String postId, {
    String? query,
    PostLikersCursorEntity? before,
  }) async {
    final page = await _likes.getLikers(
      postId,
      query: query,
      limit: PostRepository.likersPageSize,
      beforeLikedAt: before?.likedAt,
      beforeId: before?.id,
    );
    final nextAt = page.nextLikedAt;
    final nextId = page.nextId;
    return PostLikersPageEntity(
      likers: [for (final model in page.likers) ?_liker(model)],
      total: page.likers.firstOrNull?.total,
      nextCursor: nextAt == null || nextId == null
          ? null
          : PostLikersCursorEntity(likedAt: nextAt, id: nextId),
    );
  }

  PostLikerEntity? _liker(PostLikerModel model) {
    final id = model.id;
    final username = model.username;
    final likedAt = model.likedAt;
    if (id == null || username == null || likedAt == null) return null;
    return PostLikerEntity(
      id: id,
      username: username,
      fullName: model.fullName,
      avatarUrl: model.avatarUrl,
      likedAt: likedAt,
      follow: FollowStatus.fromJson(model.followStatus),
      followsMe: model.followsMe ?? false,
    );
  }

  @override
  Future<List<TaggedPersonEntity>> taggedPeople(String postId) async {
    final people = await _tags.getTaggedPeople(postId);
    return [
      for (final person in people)
        if (person.id != null && person.username != null)
          TaggedPersonEntity(
            id: person.id!,
            username: person.username!,
            fullName: person.fullName,
            avatarUrl: person.avatarUrl,
            followState: person.followState ?? FollowState.none,
          ),
    ];
  }

  @override
  Future<List<TagPersonEntity>> searchTagPeople([String? query]) async {
    final people = await _tags.searchPeople(query);
    return [
      for (final person in people)
        if (person.id != null && person.username != null)
          TagPersonEntity(
            id: person.id!,
            username: person.username!,
            fullName: person.fullName,
            avatarUrl: person.avatarUrl,
            canTag: person.canTag ?? false,
          ),
    ];
  }

  @override
  Future<bool> removeMyTag(String postId) => _tags.removeMyTag(postId);
}
