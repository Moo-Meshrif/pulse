import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';
import '../../data/model/post_media_model.dart';
import '../../data/repository/feed_refresh_repository.dart';
import '../../data/repository/post_media_repository.dart';
import '../entity/new_post_entity.dart';

/// Shares a post: uploads its files to `{uid}/{postId}/`, then inserts the post in one call. Files
/// already there from an earlier attempt are not sent again, so Retry only uploads what is missing. If
/// the insert fails the files are removed. Once the post exists the home feed is asked to load again.
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
    _feedRefresh.request();
  }
}
