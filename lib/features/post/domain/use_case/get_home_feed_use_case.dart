import 'package:injectable/injectable.dart';

import '../../data/datasource/posts_datasource.dart';
import '../entity/feed_cursor_entity.dart';
import '../entity/feed_page_entity.dart';
import '../mapper/post_entity_mapper.dart';

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
      posts: [for (final post in page.posts) ?PostEntityMapper.fromModel(post)],
      nextCursor: nextCreated == null || nextId == null
          ? null
          : FeedCursorEntity(createdAt: nextCreated, id: nextId),
    );
  }
}
