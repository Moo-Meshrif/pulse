import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/events/event_bus.dart';
import '../../../../../core/events/event_cubit_mixin.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../shared/content/data/enums/content_kind.dart';
import '../../../../../shared/content/data/model/post_count_model.dart';
import '../../../../../shared/content/domain/event/content_changed.dart';
import '../../../../../shared/content/domain/event/content_delete_event.dart';
import '../../../../../shared/content/domain/event/content_ping.dart';
import '../../../../../shared/content/domain/use_case/check_content_changes_use_case.dart';
import '../../../../../shared/content/domain/use_case/get_post_counts_use_case.dart';
import '../../../../../shared/content/domain/use_case/start_content_live_use_case.dart';
import '../../../../../shared/content/domain/use_case/stop_content_live_use_case.dart';
import '../../../../post/domain/entity/feed_cursor_entity.dart';
import '../../../../post/domain/entity/feed_page_entity.dart';
import '../../../../post/domain/entity/post_entity.dart';
import '../../../../post/domain/event/feed_refresh_requested.dart';
import '../../../../post/domain/event/post_counts_changed.dart';
import '../../../../post/domain/event/post_saved.dart';
import '../../../../post/domain/use_case/get_home_feed_use_case.dart';
import '../../../../post/domain/use_case/get_liked_by_previews_use_case.dart';
import '../../../../post/domain/use_case/get_posts_by_ids_use_case.dart';
import '../../../../post/domain/use_case/save_home_feed_use_case.dart';
import '../../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../../post/presentation/utils/feed_post.dart';
import '../../../../post/presentation/utils/feed_post_signer.dart';
import '../../../../profile/domain/event/profile_updated.dart';
import '../../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../../utils/enums/feed_status.dart';
import '../../utils/feed_changes.dart';
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
    this._saveFeed,
    this._likedByPreviews,
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
  final SaveHomeFeedUseCase _saveFeed;
  final GetLikedByPreviewsUseCase _likedByPreviews;

  /// Most posts read in one check; one request carries at most 50.
  static const _maxRead = 50;

  /// How long a post that just arrived keeps its ring (the ring fades by itself in the card).
  static const _freshStay = Duration(seconds: 4);
  Timer? _freshTimer;

  /// Posts whose "Liked by" line was asked for in the current [FeedState.generation], so a post nobody liked
  /// is not asked again on every page.
  final _askedLikedBy = <String>{};
  int _askedGeneration = 0;

  /// What the last like change told about each post, to tell a new change from a repeat.
  final _likedSeen = <String, bool>{};

  /// Whether the feed is scrolled to the top (the floaters tell): only then may the fresh page replace
  /// the saved posts.
  bool _atTop = true;

  @override
  EventBus get events => _events;

  void setAtTop(bool atTop) => _atTop = atTop;

  /// Shows the feed saved on the phone at once, then loads the fresh one behind it; with nothing saved it
  /// loads the feed. Loads it again whenever something asks for it (Home was tapped while open). A post
  /// that was shared or edited is put in the feed without loading.
  Future<void> start() async {
    listenTo<FeedRefreshRequested>((_) => _reload());
    listenTo<PostSaved>((event) => _postSaved(event.post));
    // The person's name or photo changed: the fresh page brings it onto their posts.
    listenTo<ProfileUpdated>((_) => _freshFirstPage());
    listenTo<PostCountsChanged>(_countsChanged);
    listenTo<ContentChanged>(_contentChanged);
    listenTo<ContentDeleteEvent>(_onDelete);
    listenTo<ContentPing>(_onPing);
    resumeLive();
    await _showSaved();
    final loading = state.fromPhone ? _freshFirstPage() : load();
    unawaited(checkChanges());
    return loading;
  }

  /// The saved first page, with no media links, as the feed (nothing happens when none is saved).
  Future<void> _showSaved() => run(
    () => _feed(saved: true),
    onSuccess: (saved) => saved.posts.isEmpty
        ? null
        : state.copyWith(
            status: FeedStatus.ready,
            posts: _signer.unsigned(saved.posts),
            nextCursor: saved.nextCursor,
            fromPhone: true,
            generation: state.generation + 1,
          ),
    onFailure: (_) => null,
  );

  /// Loads the fresh first page behind the saved posts, quietly. At the top it replaces them; further down
  /// the posts on screen are updated where they stand and new ones wait for the pill. A failure leaves the
  /// saved posts as they are.
  Future<void> _freshFirstPage() async {
    final generation = state.generation;
    await run(
      () => _page(null),
      prevent: state.isSyncing,
      loading: state.copyWith(isSyncing: true),
      onSuccess: (page) => _freshArrived(page, generation),
      onFailure: (_) => state.copyWith(isSyncing: false),
    );
    await _signLeftovers();
    await _fillLikedBy();
  }

  /// A refresh that ended first wins: its posts are newer than this page's.
  FeedState _freshArrived(_Page page, int generation) {
    if (state.generation != generation) return state.copyWith(isSyncing: false);
    if (_atTop) return _replaced(page);
    final result = applyFreshPosts(
      posts: state.posts,
      pending: state.pendingPosts,
      fresh: page.posts,
      asked: const [],
    );
    final next = state.copyWith(
      posts: result.posts,
      pendingPosts: result.pending,
      replacedIds: result.replacedIds,
      fromPhone: false,
      isSyncing: false,
    );
    _saveSnapshot(next);
    return next;
  }

  /// Keeps the feed as the next launch should open it: the waiting posts on top, then the posts on screen.
  /// A load of the first page already saved its own; this is for a change made in place.
  void _saveSnapshot(FeedState state) => _saveFeed([
    for (final post in [...state.pendingPosts, ...state.posts]) post.entity,
  ]);

  /// Gives the links to the posts that are still on screen with none, in one request. A failure is
  /// ignored: they keep their covers until the next refresh.
  Future<void> _signLeftovers() {
    final generation = state.generation;
    final entities = [
      for (final post in [...state.posts, ...state.pendingPosts])
        if (_hasNoLink(post)) post.entity,
    ];
    return run(
      () => _signer.sign(entities),
      prevent: entities.isEmpty,
      onSuccess: (signed) => state.generation != generation
          ? null
          : _withLinks({for (final post in signed) post.id: post}),
      onFailure: (_) => null,
    );
  }

  bool _hasNoLink(FeedPost post) =>
      post.media.any((media) => media.url == null) ||
      post.originalMedia.any((media) => media.url == null);

  /// The posts on screen that still have no links, with the media of [signed]; the rest of the post stays
  /// as it is.
  FeedState _withLinks(Map<String, FeedPost> signed) {
    FeedPost linked(FeedPost post) {
      final fresh = signed[post.id];
      if (fresh == null || !_hasNoLink(post)) return post;
      return FeedPost(
        entity: post.entity,
        media: fresh.media,
        originalMedia: fresh.originalMedia,
      );
    }

    return state.copyWith(
      posts: state.posts.map(linked).toList(),
      pendingPosts: state.pendingPosts.map(linked).toList(),
    );
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
  Future<void> _readChanged(List<String> ids) async {
    await _readChangedPosts(ids);
    await _fillLikedBy();
  }

  Future<void> _readChangedPosts(List<String> ids) => run(
    () async => _signer.sign(await _postsByIds(ids)),
    onSuccess: (fresh) {
      final result = applyFreshPosts(
        posts: state.posts,
        pending: state.pendingPosts,
        fresh: fresh,
        asked: ids,
      );
      final next = state.copyWith(
        posts: result.posts,
        pendingPosts: result.pending,
        replacedIds: result.replacedIds,
      );
      _saveSnapshot(next);
      return next;
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
        s.status == FeedStatus.loading || s.isRefreshing || s.isSyncing;
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
      state.isSyncing ||
      state.loadMore == LoadMoreStatus.loading;

  /// First load, and Try again after it failed.
  Future<void> load() async {
    await _load();
    await _fillLikedBy();
  }

  Future<void> _load() => run(
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
  Future<void> refresh({bool silent = false}) async {
    await _refresh(silent: silent);
    await _fillLikedBy();
  }

  Future<void> _refresh({required bool silent}) => run(
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
  Future<void> loadMore() async {
    await _loadMore();
    await _fillLikedBy();
  }

  Future<void> _loadMore() {
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
      _emitSaved(state.copyWith(posts: _replacedPost(post)));
    } else if (!state.pendingPosts.any((item) => item.id == post.id)) {
      _emitSaved(state.copyWith(pendingPosts: [post, ...state.pendingPosts]));
    }
  }

  /// The post page changed a post's counts or save: they go to its card through [FeedState.counts]. A like
  /// made there changes its "Liked by" line too.
  void _countsChanged(PostCountsChanged event) {
    if (!state.posts.any((post) => post.id == event.postId)) return;
    emit(
      state.copyWith(
        counts: {
          ...state.counts,
          event.postId: PostCountModel(
            id: event.postId,
            likeCount: event.likeCount,
            commentCount: event.commentCount,
            likedByMe: event.likedByMe,
            savedByMe: event.savedByMe,
          ),
        },
      ),
    );
    likeChanged(
      event.postId,
      liked: event.likedByMe,
      settled: event.likeSettled ?? Future.value(),
    );
  }

  /// The like of a post on screen is [liked]; nothing happens when that is already known. When it was the only like the line goes at once;
  /// the new line is read after [settled] (the like request ends), since the server only knows it then.
  void likeChanged(
    String postId, {
    required bool liked,
    required Future<void> settled,
  }) {
    final post = state.posts.where((post) => post.id == postId);
    if (post.isEmpty) return;
    if ((_likedSeen[postId] ?? post.first.entity.likedByMe) == liked) return;
    _likedSeen[postId] = liked;
    if (!liked && (state.likedBy[postId]?.isOnlyMe ?? false)) {
      emit(state.copyWith(likedBy: {...state.likedBy}..remove(postId)));
    }
    unawaited(settled.then((_) => _refreshLikedBy(postId)));
  }

  Future<void> _refreshLikedBy(String postId) {
    final generation = state.generation;
    return run(
      () => _likedByPreviews([postId]),
      prevent: !state.posts.any((post) => post.id == postId),
      onSuccess: (found) {
        if (state.generation != generation) return null;
        final likedBy = {...state.likedBy};
        final line = found[postId];
        line == null ? likedBy.remove(postId) : likedBy[postId] = line;
        return state.copyWith(likedBy: likedBy);
      },
      onFailure: (_) => null,
    );
  }

  /// Reads the "Liked by" lines of the posts on screen that have likes and were not asked for yet, in
  /// requests of up to 50. A failure leaves those lines hidden and lets a later call ask again.
  Future<void> _fillLikedBy() async {
    if (_askedGeneration != state.generation) {
      _askedLikedBy.clear();
      _likedSeen.clear();
      _askedGeneration = state.generation;
    }
    final ids = [
      for (final post in state.posts)
        if (post.entity.likeCount > 0 && _askedLikedBy.add(post.id)) post.id,
    ];
    final generation = state.generation;
    for (var from = 0; from < ids.length; from += _maxRead) {
      final batch = ids.skip(from).take(_maxRead).toList();
      await run(
        () => _likedByPreviews(batch),
        onSuccess: (found) => state.generation != generation
            ? null
            : state.copyWith(likedBy: {...state.likedBy, ...found}),
        onFailure: (_) {
          if (state.generation == generation) _askedLikedBy.removeAll(batch);
          return null;
        },
      );
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
  void removePosts(Set<String> ids) {
    if (ids.isEmpty) return;
    final posts = state.posts.where((post) => !ids.contains(post.id)).toList();
    final pending = state.pendingPosts
        .where((post) => !ids.contains(post.id))
        .toList();
    if (posts.length == state.posts.length &&
        pending.length == state.pendingPosts.length) {
      return;
    }
    _emitSaved(state.copyWith(posts: posts, pendingPosts: pending));
  }

  void _emitSaved(FeedState next) {
    emit(next);
    _saveSnapshot(next);
  }

  /// A post of yours is being deleted somewhere (its page, or a card): it leaves the feed at once, comes
  /// back on Undo or a failure, and is dropped for good, with its saved copy, once the delete went through.
  void _onDelete(ContentDeleteEvent event) {
    if (event.kind != ContentKind.post) return;
    final pending = {...state.pendingDeleteIds};
    if (event.stage == ContentDeleteStage.pending) {
      pending.add(event.id);
    } else {
      pending.remove(event.id);
    }
    emit(state.copyWith(pendingDeleteIds: pending));
    if (event.stage == ContentDeleteStage.deleted) removePosts({event.id});
  }

  /// Posts deleted but not yet committed: the delete's notice can still Undo them.
  void setPendingDeletes(Set<String> ids) =>
      emit(state.copyWith(pendingDeleteIds: ids));

  FeedState _replaced(_Page page) => state.copyWith(
    status: FeedStatus.ready,
    posts: page.posts,
    nextCursor: page.nextCursor,
    isRefreshing: false,
    fromPhone: false,
    isSyncing: false,
    loadMore: LoadMoreStatus.idle,
    generation: state.generation + 1,
    likedBy: const {},
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
