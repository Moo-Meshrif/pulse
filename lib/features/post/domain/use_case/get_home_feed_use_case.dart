import 'package:injectable/injectable.dart';

import '../../data/repository/feed_repository.dart';
import '../entity/feed_cursor_entity.dart';
import '../entity/feed_page_entity.dart';
import '../mapper/feed_page_mapper.dart';

/// A page of the home feed, newest first. The entry point Home calls; pass the last page's
/// [FeedPageEntity.nextCursor] for the next one. With [saved] it returns the first page saved on the
/// device, with no request (no posts when nothing is saved).
@injectable
class GetHomeFeedUseCase {
  GetHomeFeedUseCase(this._feed);

  static const pageSize = 20;

  final FeedRepository _feed;

  Future<FeedPageEntity> call({
    FeedCursorEntity? cursor,
    bool saved = false,
  }) async => FeedPageMapper.fromModel(
    await _feed.page(
      limit: pageSize,
      beforeCreated: cursor?.createdAt,
      beforeId: cursor?.id,
      saved: saved,
    ),
  );
}
