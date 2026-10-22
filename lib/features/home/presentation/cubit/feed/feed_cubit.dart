import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/domain/event/content_changed.dart';
import '../../../../../shared/content/domain/event/content_ping.dart';
import '../../../../../shared/content/domain/use_case/check_content_changes_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_post_counts_use_case.dart';
import '../../../../../shared/content/domain/use_case/start_content_live_use_case.dart';
import '../../../../../shared/content/domain/use_case/stop_content_live_use_case.dart';
import '../../../../post/domain/entity/feed_cursor_entity.dart';
import '../../../../post/domain/entity/feed_page_entity.dart';
import '../../../../post/domain/entity/post_entity.dart';
import '../../../../post/domain/event/feed_refresh_requested.dart';
import '../../../../post/domain/event/post_saved.dart';
import '../../../../post/domain/use_case/get_home_feed_use_case.dart';
import '../../../../post/domain/use_case/get_posts_by_ids_use_case.dart';
import '../../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../../utils/enums/feed_status.dart';
import '../../utils/feed_changes.dart';
import '../../utils/feed_post.dart';
import '../../utils/feed_post_signer.dart';
import 'feed_state.dart';

/// The home feed: first load, pull to refresh and the next pages (docs/specs/home/screens/s1-home-feed.md).
/// What people do to a post is [PostActionsCubit]'s.
@injectable
class FeedCubit extends BaseCubit<FeedState> with EventCubitMixin<FeedState> {
  FeedCubit(
    this._feed,
    SignPostMediaUrlsUseCase signMedia,
    this._events,
    GetCurrentUserIdUseCase currentUserId,
    this._checkChanges,
    this._postsByIds,
    this._counts,
    this._startLive,
    this._stopLive,
  ) : _signer = FeedPostSigner(signMedia),
      super(FeedState(userId: currentUserId()));

  final GetHomeFeedUseCase _feed;
  final FeedPostSigner _signer;
  final EventBus _events;
  final CheckContentChangesUseCase _checkChanges;
  final GetPostsByIdsUseCase _postsByIds;
  final GetPostCountsUseCase _counts;
  final StartContentLiveUseCase _startLive;
  final StopContentLiveUseCase _stopLive;

  /// Most posts read in one check; one request carries at most 50.
  static const _maxRead = 50;

  /// How long a post that just arrived keeps its ring (the ring fades by itself in the card).
  static const _freshStay = Duration(seconds: 4);
  Timer? _freshTimer;

  @override
  EventBus get events => _events;

  /// Loads the feed and loads it again whenever something asks for it (Home was tapped while open). A post
  /// that was shared or edited is put in the feed without loading.
  Future<void> start() {
    listenTo<FeedRefreshRequested>((_) => _reload());
    listenTo<PostSaved>((event) => _postSaved(event.post));
    listenTo<ContentChanged>(_contentChanged);
    listenTo<ContentPing>(_onPing);
    resumeLive();
    final loading = load();
    unawaited(checkChanges());
    return loading;
  }

  /// The server says posts changed: run the same check as when Home opens, so counts move too.
  void _onPing(ContentPing event) {
    if (event.kind == ContentKind.post) unawaited(checkChanges());
  }

  /// Listens to the server for changes (also the Stories rail's) while Home is open and the app is in
  /// front.
  void resumeLive() => _startLive();

  /// Stops listening: the app went to the background.
  void pauseLive() => _stopLive();

  /// Asks what changed since the last check and the counts of the posts on screen. The changes arrive as
  /// a [ContentChanged] event. Quiet when offline. Called when Home opens and when the app comes back.
  Future<void> checkChanges() async {
    await _checkChanges(ContentKind.post);
    await refreshCounts();
  }

  /// The newest like and comment counts of the posts on screen; they land in [FeedState.counts].
  Future<void> refreshCounts() => run(
    () => _counts(state.posts.map((post) => post.id).toList()),
    prevent: state.status != FeedStatus.ready || state.posts.isEmpty,
    onSuccess: (counts) => state.copyWith(
      counts: Map.fromEntries(
        counts
            .where((count) => count.id != null)
            .map((count) => MapEntry(count.id!, count)),
      ),
    ),
    onFailure: (_) => null,
  );

  Future<void> _contentChanged(ContentChanged event) async {
    if (event.kind != ContentKind.post) return;
    // A load that is running brings the newest posts anyway.
    if (event.mustReload) return _isBusy(state) ? null : refresh(silent: true);
    if (!await _settled()) return;
    final removed = event.removedIds.toSet();
    if (removed.isNotEmpty) removePosts(removed);
    final ids = event.upsertedIds.take(_maxRead).toList();
    if (ids.isNotEmpty) await _readChanged(ids);
  }

  /// Reads the changed and new posts and puts them in place (see [applyFreshPosts]).
  Future<void> _readChanged(List<String> ids) => run(
    () async => _signer.sign(await _postsByIds(ids)),
    onSuccess: (fresh) {
      final result = applyFreshPosts(
        posts: state.posts,
        pending: state.pendingPosts,
        fresh: fresh,
        asked: ids,
      );
      return state.copyWith(
        posts: result.posts,
        pendingPosts: result.pending,
        replacedIds: result.replacedIds,
      );
    },
    onFailure: (_) => null,
  );

  /// The person asked for the waiting posts (the pill): they go on top.
  void showPending() {
    final pending = state.pendingPosts;
    if (pending.isEmpty) return;
    emit(
      state.copyWith(
        posts: withPendingOnTop(state.posts, pending),
        pendingPosts: const [],
        freshIds: pending.map((post) => post.id).toSet(),
      ),
    );
    _clearFreshLater();
  }

  void _clearFreshLater() {
    _freshTimer?.cancel();
    _freshTimer = Timer(_freshStay, () => emit(state.copyWith(freshIds: {})));
  }

  @override
  Future<void> close() {
    _freshTimer?.cancel();
    _stopLive();
    return super.close();
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

  /// Pull to refresh: the posts on screen stay until the new ones arrive. [silent] skips the refresh band,
  /// for a refresh the person did not ask for.
  Future<void> refresh({bool silent = false}) => run(
    () => _page(null),
    prevent:
        state.status != FeedStatus.ready ||
        state.isRefreshing ||
        state.loadMore == LoadMoreStatus.loading,
    loading: state.copyWith(isRefreshing: !silent, refreshFailure: null),
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
        final known = state.posts.map((post) => post.id).toSet();
        return state.copyWith(
          posts: [
            ...state.posts,
            ...page.posts.where((post) => !known.contains(post.id)),
          ],
          nextCursor: page.nextCursor,
          loadMore: LoadMoreStatus.idle,
        );
      },
      onFailure: (_) => state.copyWith(loadMore: LoadMoreStatus.failed),
    );
  }

  /// A post was shared or edited: a new one waits in the pending list (the feed does not move), an edited
  /// one is replaced where it is.
  Future<void> _postSaved(PostEntity entity) async {
    final post = await _signOrNull(entity);
    if (post == null) return _reload();
    if (!await _settled()) return;
    if (state.status != FeedStatus.ready) return _reload();
    final isEdit = state.posts.any((item) => item.id == post.id);
    if (isEdit) {
      emit(state.copyWith(posts: _replacedPost(post)));
    } else if (!state.pendingPosts.any((item) => item.id == post.id)) {
      emit(state.copyWith(pendingPosts: [post, ...state.pendingPosts]));
    }
  }

  Future<FeedPost?> _signOrNull(PostEntity entity) async {
    try {
      return (await _signer.sign([entity])).single;
    } on Object {
      return null;
    }
  }

  List<FeedPost> _replacedPost(FeedPost post) =>
      state.posts.map((item) => item.id == post.id ? post : item).toList();

  /// A post was deleted or reported: it leaves the feed, so an empty feed shows its empty page.
  void removePosts(Set<String> ids) => emit(
    state.copyWith(
      posts: state.posts.where((post) => !ids.contains(post.id)).toList(),
      pendingPosts: state.pendingPosts
          .where((post) => !ids.contains(post.id))
          .toList(),
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
    return _Page(await _signer.sign(page.posts), page.nextCursor);
  }
}

class _Page {
  const _Page(this.posts, this.nextCursor);

  final List<FeedPost> posts;
  final FeedCursorEntity? nextCursor;
}
