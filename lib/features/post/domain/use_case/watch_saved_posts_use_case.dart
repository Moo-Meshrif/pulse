import 'package:injectable/injectable.dart';

import '../../data/repository/feed_refresh_repository.dart';
import '../entity/post_entity.dart';

/// Fires with the post each time one is shared or edited. Home puts it in the feed without loading again.
@injectable
class WatchSavedPostsUseCase {
  WatchSavedPostsUseCase(this._refresh);

  final FeedRefreshRepository _refresh;

  Stream<PostEntity> call() => _refresh.savedPosts;
}
