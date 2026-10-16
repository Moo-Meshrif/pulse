import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/domain/use_case/set_content_audience_use_case.dart';
import '../../data/datasource/posts_datasource.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../entity/edit_post_entity.dart';
import '../entity/post_entity.dart';
import '../entity/post_media_entity.dart';
import 'set_comments_enabled_use_case.dart';

/// Saves an edited post: applies a changed comments switch and audience first, uploads the added files under names no existing file has (the post keeps showing
/// its old media until the save succeeds), replaces the post's caption, place and media in one call, then
/// removes the files the post no longer uses. If the save fails the new files are removed. Once it is
/// saved it returns the post as it is now.
@injectable
class UpdatePostUseCase {
  UpdatePostUseCase(
    this._posts,
    this._media,
    this._setCommentsEnabled,
    this._setAudience,
  );

  final PostsDatasource _posts;
  final ContentMediaRepository _media;
  final SetCommentsEnabledUseCase _setCommentsEnabled;
  final SetContentAudienceUseCase _setAudience;

  /// [onProgress] is told how much of the added files went out (0..1), each file counting the same.
  Future<PostEntity> call(
    EditPostEntity post, {
    required PostEntity before,
    void Function(double progress)? onProgress,
  }) async {
    if (post.commentsEnabled != before.commentsEnabled) {
      await _setCommentsEnabled(post.id, enabled: post.commentsEnabled);
    }
    if (post.visibility != before.visibility) {
      await _setAudience(ContentKind.post, post.id, post.visibility);
    }

    final folder = '${_posts.currentUserId}/${post.id}';
    final stamp = clock.now().microsecondsSinceEpoch;

    final count = post.added.length;
    final added = <PostMediaModel>[];
    for (var i = 0; i < count; i++) {
      final item = post.added[i];
      final sent = await _media.send(
        ContentKind.post,
        item.toSend(),
        folder: folder,
        stem: 'e${stamp}_$i',
        onProgress: (part) => onProgress?.call((i + part) / count),
      );
      added.add(item.toModel(sent));
    }

    try {
      await _posts.updatePost(
        id: post.id,
        caption: post.caption,
        location: post.location,
        media: [for (final item in post.kept) _model(item), ...added],
        moodKind: post.mood?.kind,
        moodKey: post.mood?.key,
        moodText: post.mood?.text,
        tags: [for (final tag in post.tags) tag.toModel()],
      );
    } catch (_) {
      await _media.removeQuietly(_paths(added));
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
    return PostEntity(
      id: before.id,
      authorId: before.authorId,
      username: before.username,
      fullName: before.fullName,
      avatarUrl: before.avatarUrl,
      caption: post.caption,
      location: post.location,
      likeCount: before.likeCount,
      commentCount: before.commentCount,
      commentsEnabled: post.commentsEnabled,
      visibility: post.visibility,
      createdAt: before.createdAt,
      likedByMe: before.likedByMe,
      savedByMe: before.savedByMe,
      mood: post.mood,
      tags: post.tags,
      tagCount: post.tags.length,
      iAmTagged: before.iAmTagged,
      media: [
        ...post.kept,
        for (final item in added)
          PostMediaEntity(
            isVideo: item.type == MediaType.video,
            path: item.path!,
            thumbPath: item.thumbPath,
            width: item.width!,
            height: item.height!,
            durationMs: item.durationMs,
            blurhash: item.blurhash,
          ),
      ],
    );
  }

  List<String> _paths(List<PostMediaModel> media) => [
    for (final item in media) ...[?item.path, ?item.thumbPath],
  ];

  PostMediaModel _model(PostMediaEntity item) => PostMediaModel(
    type: item.isVideo ? MediaType.video : MediaType.image,
    path: item.path,
    thumbPath: item.thumbPath,
    width: item.width,
    height: item.height,
    durationMs: item.durationMs,
    blurhash: item.blurhash,
  );
}
