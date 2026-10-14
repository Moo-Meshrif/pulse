import 'package:injectable/injectable.dart';

import '../../../../shared/content/data/enums/content_audience.dart';
import '../../data/datasource/posts_datasource.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../../data/model/post_model.dart';
import '../entity/feed_cursor_entity.dart';
import '../entity/feed_page_entity.dart';
import '../entity/post_entity.dart';
import '../entity/post_media_entity.dart';

/// A page of the home feed, newest first. The entry point Home calls; pass the last page's
/// [FeedPageEntity.nextCursor] for the next one.
@injectable
class GetHomeFeedUseCase {
  GetHomeFeedUseCase(this._posts);

  static const pageSize = 20;

  final PostsDatasource _posts;

  Future<FeedPageEntity> call({FeedCursorEntity? cursor}) async {
    final page = await _posts.getHomeFeed(
      limit: pageSize,
      beforeCreated: cursor?.createdAt,
      beforeId: cursor?.id,
    );
    final nextCreated = page.nextBeforeCreated;
    final nextId = page.nextBeforeId;
    return FeedPageEntity(
      posts: [for (final post in page.posts) ?_post(post)],
      nextCursor: nextCreated == null || nextId == null
          ? null
          : FeedCursorEntity(createdAt: nextCreated, id: nextId),
    );
  }

  /// A row missing something the card needs is left out.
  PostEntity? _post(PostModel post) {
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
    );
  }

  PostMediaEntity? _media(PostMediaModel item) {
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
