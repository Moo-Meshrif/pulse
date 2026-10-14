import 'package:injectable/injectable.dart';

import '../../data/repository/feed_refresh_repository.dart';

/// Asks the home feed to load again (the shell calls it when the Home tab is tapped while open).
@injectable
class RequestFeedRefreshUseCase {
  RequestFeedRefreshUseCase(this._refresh);

  final FeedRefreshRepository _refresh;

  void call() => _refresh.request();
}
