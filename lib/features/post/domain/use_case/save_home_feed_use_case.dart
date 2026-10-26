import 'package:injectable/injectable.dart';

import '../../data/model/feed_page_model.dart';
import '../../data/repository/feed_repository.dart';
import '../entity/post_entity.dart';
import '../mapper/post_entity_mapper.dart';
import 'get_home_feed_use_case.dart';

/// Saves the feed as it is now on the device, so the next launch opens with a post that was shared, edited
/// or deleted. Keeps [posts] (newest first, up to the most the device keeps), no request; the next-page
/// cursor is the last post, unless the whole feed is shorter than a page.
@injectable
class SaveHomeFeedUseCase {
  SaveHomeFeedUseCase(this._feed);

  final FeedRepository _feed;

  void call(List<PostEntity> posts) {
    final kept = posts.take(FeedRepository.maxSaved).toList();
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
