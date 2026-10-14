import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/state/base_cubit.dart';
import '../../../../core/state/load_more_status.dart';
import '../../../post/domain/entity/feed_cursor_entity.dart';
import '../../../post/domain/entity/feed_page_entity.dart';
import '../../../post/domain/use_case/get_home_feed_use_case.dart';
import '../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../post/domain/use_case/watch_feed_refresh_requests_use_case.dart';
import '../../../post/presentation/utils/post_card_media.dart';
import '../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../utils/enums/feed_status.dart';
import '../utils/feed_post.dart';
import 'feed_state.dart';

/// The home feed: first load, pull to refresh and the next pages (docs/specs/home/screens/s1-home-feed.md).
/// What people do to a post is [PostActionsCubit]'s.
@injectable
class FeedCubit extends BaseCubit<FeedState> {
  FeedCubit(
    this._feed,
    this._signMedia,
    this._refreshRequests,
    GetCurrentUserIdUseCase currentUserId,
  ) : super(FeedState(userId: currentUserId()));

  final GetHomeFeedUseCase _feed;
  final SignPostMediaUrlsUseCase _signMedia;
  final WatchFeedRefreshRequestsUseCase _refreshRequests;
  StreamSubscription<void>? _requests;

  /// Loads the feed and loads it again whenever something asks for it (a post was shared, Home was tapped
  /// while open).
  Future<void> start() {
    _requests ??= _refreshRequests().listen((_) => _reload());
    return load();
  }

  /// A feed that failed to load tries again; one on screen refreshes. While it is busy this does nothing.
  Future<void> _reload() =>
      state.status == FeedStatus.failed ? load() : refresh();

  /// First load, and Try again after it failed.
  Future<void> load() => run(
    () => _page(null),
    prevent:
        state.status == FeedStatus.loading || state.status == FeedStatus.ready,
    loading: state.copyWith(status: FeedStatus.loading, failure: null),
    onSuccess: (page) => _replaced(page),
    onFailure: (failure) =>
        state.copyWith(status: FeedStatus.failed, failure: failure),
  );

  /// Pull to refresh: the posts on screen stay until the new ones arrive.
  Future<void> refresh() => run(
    () => _page(null),
    prevent:
        state.status != FeedStatus.ready ||
        state.isRefreshing ||
        state.loadMore == LoadMoreStatus.loading,
    loading: state.copyWith(isRefreshing: true, refreshFailure: null),
    onSuccess: (page) => _replaced(page),
    onFailure: (failure) =>
        state.copyWith(isRefreshing: false, refreshFailure: failure),
  );

  /// The next page, also the retry after it failed.
  Future<void> loadMore() {
    final cursor = state.nextCursor;
    return run(
      () => _page(cursor),
      prevent:
          cursor == null ||
          state.status != FeedStatus.ready ||
          state.isRefreshing ||
          state.loadMore == LoadMoreStatus.loading,
      loading: state.copyWith(loadMore: LoadMoreStatus.loading),
      onSuccess: (page) {
        final known = {for (final post in state.posts) post.id};
        return state.copyWith(
          posts: [
            ...state.posts,
            for (final post in page.posts)
              if (!known.contains(post.id)) post,
          ],
          nextCursor: page.nextCursor,
          loadMore: LoadMoreStatus.idle,
        );
      },
      onFailure: (_) => state.copyWith(loadMore: LoadMoreStatus.failed),
    );
  }

  /// A post was deleted or reported: it leaves the feed, so an empty feed shows its empty page.
  void removePosts(Set<String> ids) => emit(
    state.copyWith(
      posts: [
        for (final post in state.posts)
          if (!ids.contains(post.id)) post,
      ],
    ),
  );

  @override
  Future<void> close() async {
    await _requests?.cancel();
    return super.close();
  }

  FeedState _replaced(_Page page) => state.copyWith(
    status: FeedStatus.ready,
    posts: page.posts,
    nextCursor: page.nextCursor,
    isRefreshing: false,
    loadMore: LoadMoreStatus.idle,
    generation: state.generation + 1,
    failure: null,
  );

  /// One page with the links of all its media signed in a single request. A file whose link could not be
  /// made is left out of its post.
  Future<_Page> _page(FeedCursorEntity? cursor) async {
    final FeedPageEntity page = await _feed(cursor: cursor);
    final paths = {
      for (final post in page.posts)
        for (final item in post.media) ...[item.path, ?item.thumbPath],
    }.toList();
    final links = paths.isEmpty
        ? const <String, String>{}
        : await _signMedia(paths);
    return _Page([
      for (final post in page.posts)
        FeedPost(
          entity: post,
          media: [
            for (final item in post.media)
              if (links[item.path] case final url?)
                PostCardMedia(
                  isVideo: item.isVideo,
                  url: url,
                  posterUrl: links[item.thumbPath],
                  cacheKey: item.path,
                  width: item.width,
                  height: item.height,
                  durationMs: item.durationMs,
                  blurhash: item.blurhash,
                ),
          ],
        ),
    ], page.nextCursor);
  }
}

class _Page {
  const _Page(this.posts, this.nextCursor);

  final List<FeedPost> posts;
  final FeedCursorEntity? nextCursor;
}
