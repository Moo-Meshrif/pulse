import '../../data/model/feed_page_model.dart';
import '../entity/feed_cursor_entity.dart';
import '../entity/feed_page_entity.dart';
import 'post_entity_mapper.dart';

abstract final class FeedPageMapper {
  /// The posts that can be shown, and the cursor only when both parts of it are set.
  static FeedPageEntity fromModel(FeedPageModel page) {
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
