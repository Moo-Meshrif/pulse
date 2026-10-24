import 'package:injectable/injectable.dart';

import '../../data/model/feed_page_model.dart';
import '../../data/repository/feed_repository.dart';
import '../entity/post_entity.dart';
import '../mapper/post_entity_mapper.dart';
import 'get_home_feed_use_case.dart';

/// Saves the feed as it is now on the device, so the next launch opens with a post that was shared, edited
/// or deleted. Keeps the first page worth of [posts] (newest first), no request; the next-page cursor only when there
/// are that many.
@injectable
class SaveHomeFeedUseCase {
  SaveHomeFeedUseCase(this._feed);

  final FeedRepository _feed;

  void call(List<PostEntity> posts) {
    final kept = posts.take(GetHomeFeedUseCase.pageSize).toList();
    final hasMore = posts.length >= GetHomeFeedUseCase.pageSize;
    _feed.saveFirstPage(
      FeedPageModel(
        posts: kept.map(PostEntityMapper.toModel).toList(),
        nextBeforeCreated: hasMore ? kept.last.createdAt : null,
        nextBeforeId: hasMore ? kept.last.id : null,
      ),
    );
  }
}
