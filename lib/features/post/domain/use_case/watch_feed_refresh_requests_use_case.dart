import 'package:injectable/injectable.dart';

import '../../data/repository/feed_refresh_repository.dart';

/// Fires when the home feed should load again: a post was shared, or Home was tapped while open. Home
/// listens and refreshes.
@injectable
class WatchFeedRefreshRequestsUseCase {
  WatchFeedRefreshRequestsUseCase(this._refresh);

  final FeedRefreshRepository _refresh;

  Stream<void> call() => _refresh.requests;
}
