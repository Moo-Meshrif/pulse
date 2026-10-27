import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../../profile/domain/use_case/get_current_user_id_use_case.dart';
import '../../../domain/entity/post_liker_entity.dart';
import '../../../domain/use_case/get_post_likers_use_case.dart';
import '../../utils/enums/post_likes_status.dart';
import '../../utils/new_post_limits.dart';
import 'post_likes_state.dart';

/// The likes list of one post (docs/specs/post/screens/s15-post-page.md, S16): pages of people, a search
/// that waits for a pause in typing, and a Follow button on every row that answers at once and is put
/// back when the request fails.
@injectable
class PostLikesCubit extends BaseCubit<PostLikesState> {
  PostLikesCubit(
    this._getLikers,
    this._toggleFollow,
    GetCurrentUserIdUseCase currentUserId,
    @factoryParam this.postId,
  ) : super(PostLikesState(userId: currentUserId()));

  final GetPostLikersUseCase _getLikers;
  final ToggleFollowUseCase _toggleFollow;
  final String postId;

  Timer? _debounce;

  /// Counts the loads from the top: an answer for an older search or a reloaded list is dropped.
  int _generation = 0;

  /// People with a follow request in flight: a second tap waits.
  final _followPending = <String>{};

  /// Loads the first page of what is typed (also the retry).
  Future<void> load() {
    final generation = ++_generation;
    return run(
      () => _getLikers(postId, query: _query),
      loading: state.copyWith(
        status: PostLikesStatus.loading,
        likers: const [],
        nextCursor: null,
        more: LoadMoreStatus.idle,
      ),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: PostLikesStatus.ready,
              likers: page.likers,
              total: state.isSearching ? state.total : page.total,
              nextCursor: page.nextCursor,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(status: PostLikesStatus.failed),
    );
  }

  /// Pull to refresh: reads the first page again and keeps the rows until it is in. A failure keeps them.
  Future<void> refresh() {
    final generation = ++_generation;
    return run(
      () => _getLikers(postId, query: _query),
      prevent: state.isRefreshing,
      loading: state.copyWith(isRefreshing: true),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              status: PostLikesStatus.ready,
              likers: page.likers,
              total: state.isSearching ? state.total : page.total,
              nextCursor: page.nextCursor,
              more: LoadMoreStatus.idle,
              isRefreshing: false,
            ),
      onFailure: (failure) => generation != _generation
          ? null
          : state.copyWith(isRefreshing: false, failure: failure),
    );
  }

  /// Search as you type: one request per pause; blank again shows everyone.
  void queryChanged(String query) {
    if (query.trim() == state.query.trim()) return;
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _generation++;
    _debounce = Timer(TagLimits.searchDelay, load);
  }

  /// Loads the next page. A failed page waits for [retry] (the list calls this on every scroll).
  Future<void> loadMore({bool retry = false}) {
    final cursor = state.nextCursor;
    final generation = _generation;
    return run(
      () => _getLikers(postId, query: _query, before: cursor),
      prevent:
          cursor == null ||
          state.status != PostLikesStatus.ready ||
          state.more == LoadMoreStatus.loading ||
          (state.more == LoadMoreStatus.failed && !retry),
      loading: state.copyWith(more: LoadMoreStatus.loading),
      onSuccess: (page) => generation != _generation
          ? null
          : state.copyWith(
              likers: _withoutRepeats(state.likers, page.likers),
              nextCursor: page.nextCursor,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(more: LoadMoreStatus.failed),
    );
  }

  /// Follows [liker], or unfollows (or cancels the request to) them when you already do.
  Future<void> toggleFollow(PostLikerEntity liker) async {
    final id = liker.id;
    if (id == state.userId || !_followPending.add(id)) return;
    final before = liker.follow;
    final follow = before == FollowStatus.none;
    _setFollow(id, follow ? FollowStatus.accepted : FollowStatus.none);
    await run(
      () => _toggleFollow(id, follow: follow),
      onSuccess: (status) {
        _followPending.remove(id);
        _setFollow(id, status);
      },
      onFailure: (failure) {
        _followPending.remove(id);
        _setFollow(id, before);
        emit(state.copyWith(failure: failure));
      },
    );
  }

  String? get _query {
    final text = state.query.trim();
    return text.isEmpty ? null : text;
  }

  void _setFollow(String id, FollowStatus status) => emit(
    state.copyWith(
      likers: [
        for (final liker in state.likers)
          liker.id == id ? liker.withFollow(status) : liker,
      ],
    ),
  );

  /// The page after [shown], without anyone already on screen (a like made while paging shifts the pages).
  List<PostLikerEntity> _withoutRepeats(
    List<PostLikerEntity> shown,
    List<PostLikerEntity> page,
  ) {
    final ids = {for (final liker in shown) liker.id};
    return [
      ...shown,
      for (final liker in page)
        if (!ids.contains(liker.id)) liker,
    ];
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
