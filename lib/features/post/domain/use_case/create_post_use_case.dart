import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../../data/repository/feed_refresh_repository.dart';
import '../../data/repository/post_media_repository.dart';
import '../entity/new_post_entity.dart';
import '../entity/post_entity.dart';
import '../entity/post_media_entity.dart';

/// Shares a post: uploads its files to `{uid}/{postId}/`, then inserts the post in one call. Files
/// already there from an earlier attempt are not sent again, so Retry only uploads what is missing. If
/// the insert fails the files are removed. Once the post exists the home feed gets it to show at once (or is asked to load again when the author is unknown).
@injectable
class CreatePostUseCase {
  CreatePostUseCase(this._posts, this._media, this._feedRefresh);

  final PostsDatasource _posts;
  final PostMediaRepository _media;
  final FeedRefreshRepository _feedRefresh;

  Future<void> call(NewPostEntity post) async {
    final folder = '${_posts.currentUserId}/${post.id}';
    final uploaded = (await _posts.listFiles(folder)).toSet();

    final media = <PostMediaModel>[];
    for (var i = 0; i < post.media.length; i++) {
      media.add(await _media.upload(folder, '$i', post.media[i], uploaded));
    }

    try {
      await _posts.createPost(
        id: post.id,
        caption: post.caption,
        location: post.location,
        commentsEnabled: post.commentsEnabled,
        visibility: post.visibility,
        media: media,
      );
    } catch (_) {
      await _media.removeQuietly([
        for (final item in media) ...[?item.path, ?item.thumbPath],
      ]);
      rethrow;
    }
    final username = post.authorUsername;
    if (username == null) {
      _feedRefresh.request();
      return;
    }
    _feedRefresh.postSaved(
      PostEntity(
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
        media: [
          for (final item in media)
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
      ),
    );
  }
}
