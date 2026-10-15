import 'package:injectable/injectable.dart';

import '../../../../core/events/event_bus.dart';
import '../../../../core/events/event_cubit_mixin.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/state/load_more_status.dart';
import '../../../post/domain/entity/feed_cursor_entity.dart';
import '../../../post/domain/entity/feed_page_entity.dart';
import '../../../post/domain/entity/post_entity.dart';
import '../../../post/domain/event/feed_refresh_requested.dart';
import '../../../post/domain/event/post_saved.dart';
import '../../../post/domain/use_case/get_home_feed_use_case.dart';
import '../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../post/presentation/utils/post_card_media.dart';
import '../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../utils/enums/feed_status.dart';
import '../utils/feed_post.dart';
import 'feed_state.dart';

/// The home feed: first load, pull to refresh and the next pages (docs/specs/home/screens/s1-home-feed.md).
/// What people do to a post is [PostActionsCubit]'s.
@injectable
class FeedCubit extends BaseCubit<FeedState> with EventCubitMixin<FeedState> {
  FeedCubit(
    this._feed,
    this._signMedia,
    this._events,
    GetCurrentUserIdUseCase currentUserId,
  ) : super(FeedState(userId: currentUserId()));

  final GetHomeFeedUseCase _feed;
  final SignPostMediaUrlsUseCase _signMedia;
  final EventBus _events;

  @override
  EventBus get events => _events;

  /// Loads the feed and loads it again whenever something asks for it (Home was tapped while open). A post
  /// that was shared or edited is put in the feed without loading.
  Future<void> start() {
    listenTo<FeedRefreshRequested>((_) => _reload());
    listenTo<PostSaved>((event) => _postSaved(event.post));
    return load();
  }

  /// A feed that failed to load tries again; one on screen refreshes. A request that arrives while the feed
  /// is busy waits for it to finish, so a post shared meanwhile is not missed.
  Future<void> _reload() async {
    if (_isBusy(state)) {
      try {
        await stream.firstWhere((state) => !_isBusy(state));
      } on StateError {
        return;
      }
    }
    return state.status == FeedStatus.failed ? load() : refresh();
  }

  /// Waits for a load or refresh that is running, since its page may have been read before the post was
  /// saved and would replace it with the old version. False if the Cubit closed meanwhile.
  Future<bool> _settled() async {
    bool isReplacing(FeedState s) =>
        s.status == FeedStatus.loading || s.isRefreshing;
    if (isReplacing(state)) {
      try {
        await stream.firstWhere((s) => !isReplacing(s));
      } on StateError {
        return false;
      }
    }
    return !isClosed;
  }

  bool _isBusy(FeedState state) =>
      state.status == FeedStatus.loading ||
      state.isRefreshing ||
      state.loadMore == LoadMoreStatus.loading;

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

  /// A post was shared or edited: a new one goes first, an edited one is replaced where it is.
  Future<void> _postSaved(PostEntity entity) async {
    final FeedPost post;
    try {
      post = (await _signed([entity])).single;
    } on Object {
      return _reload();
    }
    if (!await _settled()) return;
    final index = state.posts.indexWhere((item) => item.id == post.id);
    if (index >= 0) {
      emit(state.copyWith(posts: [...state.posts]..[index] = post));
    } else if (state.status == FeedStatus.ready) {
      emit(state.copyWith(posts: [post, ...state.posts]));
    } else {
      await _reload();
    }
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

  /// Posts deleted but not yet committed: the delete's notice can still Undo them.
  void setPendingDeletes(Set<String> ids) =>
      emit(state.copyWith(pendingDeleteIds: ids));

  FeedState _replaced(_Page page) => state.copyWith(
    status: FeedStatus.ready,
    posts: page.posts,
    nextCursor: page.nextCursor,
    isRefreshing: false,
    loadMore: LoadMoreStatus.idle,
    generation: state.generation + 1,
    pendingDeleteIds: const {},
    failure: null,
  );

  /// One page of the feed with its media links signed.
  Future<_Page> _page(FeedCursorEntity? cursor) async {
    final FeedPageEntity page = await _feed(cursor: cursor);
    return _Page(await _signed(page.posts), page.nextCursor);
  }

  /// The posts with the links of all their media signed in a single request. A file whose link could not be
  /// made is left out of its post.
  Future<List<FeedPost>> _signed(List<PostEntity> posts) async {
    final paths = {
      for (final post in posts)
        for (final item in post.media) ...[item.path, ?item.thumbPath],
    }.toList();
    final links = paths.isEmpty
        ? const <String, String>{}
        : await _signMedia(paths);
    return [
      for (final post in posts)
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
    ];
  }
}

class _Page {
  const _Page(this.posts, this.nextCursor);

  final List<FeedPost> posts;
  final FeedCursorEntity? nextCursor;
}
