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
