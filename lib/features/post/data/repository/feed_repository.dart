import 'dart:async';

import 'package:injectable/injectable.dart';

import '../datasource/feed_local_datasource.dart';
import '../datasource/posts_datasource.dart';
import '../model/feed_page_model.dart';

/// The home feed from the server, with the first page kept on the device so Home can open with it next time.
abstract interface class FeedRepository {
  /// A page of the feed. The first page (no cursor) is also saved for the signed-in user. With [saved]
  /// no request is made: it returns the saved first page, or an empty page when nothing is saved or there
  /// is no session. A failed request throws; it never falls back to the saved page (the caller shows that
  /// first, itself).
  Future<FeedPageModel> page({
    required int limit,
    DateTime? beforeCreated,
    String? beforeId,
    bool saved = false,
  });

  /// Replaces the saved first page with [page] (a post was shared, edited or deleted). No request.
  void saveFirstPage(FeedPageModel page);
}

@LazySingleton(as: FeedRepository)
class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._remote, this._local);

  final PostsDatasource _remote;
  final FeedLocalDatasource _local;

  @override
  Future<FeedPageModel> page({
    required int limit,
    DateTime? beforeCreated,
    String? beforeId,
    bool saved = false,
  }) async {
    if (saved) return _savedPage();
    final page = await _remote.getHomeFeed(
      limit: limit,
      beforeCreated: beforeCreated,
      beforeId: beforeId,
    );
    if (beforeCreated == null && beforeId == null) {
      _save(page);
    }
    return page;
  }

  @override
  void saveFirstPage(FeedPageModel page) => _save(page);

  /// The page is already on its way to the screen: it does not wait for the disk, and a copy that cannot be
  /// made (no session) never fails the load.
  void _save(FeedPageModel page) {
    try {
      unawaited(_local.write(_remote.currentUserId, page));
    } on Object {
      return;
    }
  }

  FeedPageModel _savedPage() {
    final String userId;
    try {
      userId = _remote.currentUserId;
    } on Object {
      return const FeedPageModel(posts: []);
    }
    return _local.read(userId) ?? const FeedPageModel(posts: []);
  }
}
