import '../../../../shared/content/data/enums/content_audience.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../../data/model/post_model.dart';
import '../../data/model/post_tag_model.dart';
import '../entity/post_entity.dart';
import '../entity/post_media_entity.dart';
import '../entity/post_mood_entity.dart';
import '../entity/post_tag_entity.dart';

/// Turns a post row from the server into a [PostEntity]; shared by every use case that reads posts.
abstract final class PostEntityMapper {
  /// A row missing something the card needs is left out.
  static PostEntity? fromModel(PostModel post) {
    final id = post.id;
    final authorId = post.authorId;
    final username = post.username;
    final createdAt = post.createdAt;
    if (id == null ||
        authorId == null ||
        username == null ||
        createdAt == null) {
      return null;
    }
    return PostEntity(
      id: id,
      authorId: authorId,
      username: username,
      fullName: post.fullName,
      avatarUrl: post.avatarUrl,
      caption: post.caption,
      location: post.location,
      likeCount: post.likeCount ?? 0,
      commentCount: post.commentCount ?? 0,
      commentsEnabled: post.commentsEnabled ?? true,
      visibility: post.visibility ?? ContentAudience.public,
      createdAt: createdAt,
      likedByMe: post.likedByMe ?? false,
      savedByMe: post.savedByMe ?? false,
      media: [
        for (final item in post.media ?? const <PostMediaModel>[])
          ?_media(item),
      ],
      mood: _mood(post),
      tags: [for (final tag in post.tags ?? const <PostTagModel>[]) ?_tag(tag)],
      tagCount: post.tagCount ?? 0,
      iAmTagged: post.iAmTagged ?? false,
      isShare: post.isShare ?? false,
      original: _original(post.sharedPost),
    );
  }

  /// The row again, for the copy kept on the device ([fromModel] of it gives the same post).
  static PostModel toModel(PostEntity post) => PostModel(
    id: post.id,
    authorId: post.authorId,
    username: post.username,
    fullName: post.fullName,
    avatarUrl: post.avatarUrl,
    caption: post.caption,
    location: post.location,
    likeCount: post.likeCount,
    commentCount: post.commentCount,
    commentsEnabled: post.commentsEnabled,
    visibility: post.visibility,
    createdAt: post.createdAt,
    likedByMe: post.likedByMe,
    savedByMe: post.savedByMe,
    media: [
      for (final (position, item) in post.media.indexed)
        PostMediaModel(
          position: position,
          type: item.isVideo ? MediaType.video : MediaType.image,
          path: item.path,
          thumbPath: item.thumbPath,
          width: item.width,
          height: item.height,
          durationMs: item.durationMs,
          blurhash: item.blurhash,
        ),
    ],
    moodKind: post.mood?.kind,
    moodKey: post.mood?.key,
    moodText: post.mood?.text,
    tagCount: post.tagCount,
    tags: [
      for (final tag in post.tags)
        PostTagModel(
          userId: tag.userId,
          username: tag.username,
          fullName: tag.fullName,
          mediaPosition: tag.mediaPosition,
          x: tag.x,
          y: tag.y,
        ),
    ],
    iAmTagged: post.iAmTagged,
    isShare: post.isShare,
    sharedPostId: post.original?.id,
    sharedPost: post.original == null ? null : toModel(post.original!),
  );

  static PostEntity? _original(PostModel? original) =>
      original == null ? null : fromModel(original);

  static PostMoodEntity? _mood(PostModel post) {
    final kind = post.moodKind;
    final key = post.moodKey;
    if (kind == null || key == null) return null;
    return PostMoodEntity(kind: kind, key: key, text: post.moodText);
  }

  static PostTagEntity? _tag(PostTagModel tag) {
    final userId = tag.userId;
    final username = tag.username;
    if (userId == null || username == null) return null;
    return PostTagEntity(
      userId: userId,
      username: username,
      fullName: tag.fullName,
      mediaPosition: tag.mediaPosition,
      x: tag.x,
      y: tag.y,
    );
  }

  static PostMediaEntity? _media(PostMediaModel item) {
    final type = item.type;
    final path = item.path;
    final width = item.width;
    final height = item.height;
    if (type == null || path == null || width == null || height == null) {
      return null;
    }
    return PostMediaEntity(
      isVideo: type == MediaType.video,
      path: path,
      thumbPath: item.thumbPath,
      width: width,
      height: height,
      durationMs: item.durationMs,
      blurhash: item.blurhash,
    );
  }
}
