import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/domain/use_case/set_content_audience_use_case.dart';
import '../../data/datasource/posts_datasource.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';
import '../../data/repository/feed_refresh_repository.dart';
import '../../data/repository/post_media_repository.dart';
import '../entity/edit_post_entity.dart';
import '../entity/post_entity.dart';
import '../entity/post_media_entity.dart';
import 'set_comments_enabled_use_case.dart';

/// Saves an edited post: applies a changed comments switch and audience first, uploads the added files under names no existing file has (the post keeps showing
/// its old media until the save succeeds), replaces the post's caption, place and media in one call, then
/// removes the files the post no longer uses. If the save fails the new files are removed. Once it is
/// saved the home feed is asked to load again.
@injectable
class UpdatePostUseCase {
  UpdatePostUseCase(
    this._posts,
    this._media,
    this._feedRefresh,
    this._setCommentsEnabled,
    this._setAudience,
  );

  final PostsDatasource _posts;
  final PostMediaRepository _media;
  final FeedRefreshRepository _feedRefresh;
  final SetCommentsEnabledUseCase _setCommentsEnabled;
  final SetContentAudienceUseCase _setAudience;

  Future<void> call(EditPostEntity post, {required PostEntity before}) async {
    if (post.commentsEnabled != before.commentsEnabled) {
      await _setCommentsEnabled(post.id, enabled: post.commentsEnabled);
    }
    if (post.visibility != before.visibility) {
      await _setAudience(ContentKind.post, post.id, post.visibility);
    }

    final folder = '${_posts.currentUserId}/${post.id}';
    final stamp = clock.now().microsecondsSinceEpoch;

    final added = <PostMediaModel>[];
    for (var i = 0; i < post.added.length; i++) {
      added.add(await _media.upload(folder, 'e${stamp}_$i', post.added[i], {}));
    }

    try {
      await _posts.updatePost(
        id: post.id,
        caption: post.caption,
        location: post.location,
        media: [for (final item in post.kept) _model(item), ...added],
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
    _feedRefresh.request();
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
