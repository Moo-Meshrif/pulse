import 'dart:async';

import 'package:injectable/injectable.dart';

/// Tells the screens that show the home feed when it should load again: after a post was shared, when the
/// Home tab is tapped while already open. It holds the signal across screens, so it is a repository.
abstract interface class FeedRefreshRepository {
  /// One event per request. Requests made while nobody listens are dropped.
  Stream<void> get requests;

  void request();
}

@LazySingleton(as: FeedRefreshRepository)
final class FeedRefreshRepositoryImpl implements FeedRefreshRepository {
  final _requests = StreamController<void>.broadcast();

  @override
  Stream<void> get requests => _requests.stream;

  @override
  void request() => _requests.add(null);
}
