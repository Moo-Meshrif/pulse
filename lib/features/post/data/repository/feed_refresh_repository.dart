import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../domain/entity/post_entity.dart';

/// Tells the screens that show the home feed what changed: it should load again (the Home tab was tapped
/// while already open), or a post was shared or edited, so the feed can show it without loading. It holds the signal across screens, so it is a repository.
abstract interface class FeedRefreshRepository {
  /// One event per request. Requests made while nobody listens are dropped.
  Stream<void> get requests;

  void request();

  /// One event per post shared or edited, with the post as it is now.
  Stream<PostEntity> get savedPosts;

  void postSaved(PostEntity post);
}

@LazySingleton(as: FeedRefreshRepository)
final class FeedRefreshRepositoryImpl implements FeedRefreshRepository {
  final _requests = StreamController<void>.broadcast();
  final _savedPosts = StreamController<PostEntity>.broadcast();

  @override
  Stream<void> get requests => _requests.stream;

  @override
  void request() => _requests.add(null);

  @override
  Stream<PostEntity> get savedPosts => _savedPosts.stream;

  @override
  void postSaved(PostEntity post) => _savedPosts.add(post);
}
