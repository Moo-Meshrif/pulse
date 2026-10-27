import 'dart:async';

import 'package:injectable/injectable.dart';

import '../datasource/feed_local_datasource.dart';
import '../datasource/posts_datasource.dart';
import '../model/feed_page_model.dart';

/// The home feed from the server, with the pages loaded so far kept on the device (up to [maxSaved] posts,
/// for one day) so Home can open with them next time.
abstract interface class FeedRepository {
  /// Most posts kept on the device; a longer feed keeps its newest.
  static const maxSaved = 100;

  /// A page of the feed. The first page (no cursor) replaces the saved feed; a later page is added to it.
  /// With [saved] no request is made: it returns the saved feed, or an empty page. A failed request
  /// throws; it never falls back to the saved page.
  Future<FeedPageModel> page({
    required int limit,
    DateTime? beforeCreated,
    String? beforeId,
    bool saved = false,
  });

  /// Replaces the saved feed with [page] (a post was shared, edited or deleted). No request.
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
    } else {
      _append(page);
    }
    return page;
  }

  @override
  void saveFirstPage(FeedPageModel page) => _save(page);

  /// Adds a later page to the saved feed. With no saved feed (a day old, or none) nothing is saved: a feed
  /// that starts in the middle would be wrong.
  void _append(FeedPageModel page) {
    try {
      final userId = _remote.currentUserId;
      final current = _local.read(userId);
      if (current == null) return;
      final known = current.posts.map((post) => post.id).toSet();
      _save(
        FeedPageModel(
          posts: [
            ...current.posts,
            ...page.posts.where((post) => !known.contains(post.id)),
          ],
          nextBeforeCreated: page.nextBeforeCreated,
          nextBeforeId: page.nextBeforeId,
        ),
      );
    } on Object {
      return;
    }
  }

  /// Does not wait for the disk, and a failed copy never fails the load.
  void _save(FeedPageModel page) {
    try {
      unawaited(_local.write(_remote.currentUserId, _capped(page)));
    } on Object {
      return;
    }
  }

  /// The first [FeedRepository.maxSaved] posts, with the cursor after the last kept one when the rest is cut.
  FeedPageModel _capped(FeedPageModel page) {
    if (page.posts.length <= FeedRepository.maxSaved) return page;
    final kept = page.posts.take(FeedRepository.maxSaved).toList();
    return FeedPageModel(
      posts: kept,
      nextBeforeCreated: kept.last.createdAt,
      nextBeforeId: kept.last.id,
    );
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
