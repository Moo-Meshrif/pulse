import 'package:injectable/injectable.dart';

import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../../follow/domain/use_case/toggle_follow_use_case.dart';
import '../../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../data/datasource/blocks_datasource.dart';
import '../../../data/datasource/mutual_preview_datasource.dart';
import '../../../data/datasource/profile_page_datasource.dart';
import '../../../data/model/profile_grid_item_model.dart';
import '../../utils/enums/profile_status.dart';
import 'other_profile_state.dart';

@injectable
class OtherProfileCubit extends BaseCubit<OtherProfileState> {
  OtherProfileCubit(
    this._pages,
    this._follow,
    this._blocks,
    this._sign,
    this._mutual,
    @factoryParam this.userId,
  ) : super(const OtherProfileState());

  final ProfilePageDatasource _pages;
  final ToggleFollowUseCase _follow;
  final BlocksDatasource _blocks;
  final SignPostMediaUrlsUseCase _sign;
  final MutualPreviewDatasource _mutual;
  final String userId;
  int _generation = 0;

  bool get _locked =>
      state.page?.isPrivate == true && state.follow != FollowStatus.accepted;

  Future<void> load() async {
    final generation = ++_generation;
    await run(
      () => _pages.getProfilePage(userId),
      loading: state.copyWith(status: ProfileStatus.loading),
      onSuccess: (page) {
        if (generation != _generation) return;
        if (page == null) {
          emit(state.copyWith(status: ProfileStatus.ready, notFound: true));
          return;
        }
        emit(
          state.copyWith(
            status: ProfileStatus.ready,
            page: page,
            notFound: false,
            follow: FollowStatus.fromJson(page.iFollow),
            followers: page.followersCount ?? 0,
          ),
        );
      },
      onFailure: (_) => generation == _generation
          ? state.copyWith(status: ProfileStatus.failed)
          : null,
    );
    if (generation != _generation || state.page == null || state.notFound) {
      return;
    }
    await Future.wait([_loadMutual(), loadGrid()]);
  }

  Future<void> _loadMutual() async {
    await run(
      () => _mutual.get(userId),
      onSuccess: (preview) => state.copyWith(mutual: preview),
      onFailure: (_) => null,
    );
  }

  Future<void> selectTab(int tab) async {
    if (state.tab == tab) return;
    emit(
      state.copyWith(
        tab: tab,
        items: const [],
        hasMore: false,
        more: LoadMoreStatus.idle,
      ),
    );
    await loadGrid();
  }

  Future<List<ProfileGridItemModel>> _fetch(
    int tab, {
    ProfileGridItemModel? before,
  }) => tab == 2
      ? _pages.getTagged(userId, before: before)
      : _pages.getPosts(userId, before: before);

  Future<void> loadGrid() async {
    final tab = state.tab;
    final generation = ++_generation;
    if (tab == 1 || _locked || state.page?.blockedByMe == true) {
      emit(
        state.copyWith(
          gridStatus: ProfileStatus.ready,
          items: const [],
          hasMore: false,
        ),
      );
      return;
    }
    await run(
      () => _fetch(tab),
      loading: state.copyWith(gridStatus: ProfileStatus.loading),
      onSuccess: (items) => generation != _generation
          ? null
          : state.copyWith(
              gridStatus: ProfileStatus.ready,
              items: items,
              hasMore: items.length == ProfilePageDatasource.pageSize,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(gridStatus: ProfileStatus.failed),
    );
    if (generation == _generation) await _signMissing();
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.items.isEmpty ||
        state.more != LoadMoreStatus.idle) {
      return;
    }
    final generation = _generation;
    final tab = state.tab;
    await run(
      () => _fetch(tab, before: state.items.last),
      loading: state.copyWith(more: LoadMoreStatus.loading),
      onSuccess: (items) => generation != _generation
          ? null
          : state.copyWith(
              items: [...state.items, ...items],
              hasMore: items.length == ProfilePageDatasource.pageSize,
              more: LoadMoreStatus.idle,
            ),
      onFailure: (_) => generation != _generation
          ? null
          : state.copyWith(more: LoadMoreStatus.failed),
    );
    if (generation == _generation) await _signMissing();
  }

  Future<void> retryMore() async {
    emit(state.copyWith(more: LoadMoreStatus.idle));
    await loadMore();
  }

  Future<void> _signMissing() async {
    final paths = {
      for (final item in state.items)
        if (item.thumbPath case final path? when !state.urls.containsKey(path))
          path,
    };
    if (paths.isEmpty) return;
    await run(
      () => _sign(paths.toList()),
      onSuccess: (urls) => state.copyWith(urls: {...state.urls, ...urls}),
      onFailure: (_) => null,
    );
  }

  Future<void> toggleFollow() async {
    if (state.busy) return;
    final before = state.follow;
    final count = state.followers;
    final following = before == FollowStatus.none;
    final optimistic = following
        ? (state.page?.isPrivate == true
              ? FollowStatus.pending
              : FollowStatus.accepted)
        : FollowStatus.none;
    final optimisticCount =
        count +
        (optimistic == FollowStatus.accepted ? 1 : 0) -
        (before == FollowStatus.accepted ? 1 : 0);
    emit(
      state.copyWith(
        busy: true,
        follow: optimistic,
        followers: optimisticCount,
        failure: null,
        requestSent: false,
      ),
    );
    await run(
      () => _follow(userId, follow: following),
      onSuccess: (result) => state.copyWith(
        busy: false,
        follow: result,
        followers:
            count +
            (result == FollowStatus.accepted ? 1 : 0) -
            (before == FollowStatus.accepted ? 1 : 0),
        requestSent: following && result == FollowStatus.pending,
      ),
      onFailure: (failure) => state.copyWith(
        busy: false,
        follow: before,
        followers: count,
        failure: failure,
      ),
    );
    if (state.follow != before) await loadGrid();
  }

  Future<void> unblock() async {
    if (state.busy) return;
    await run(
      () => _blocks.unblock(userId),
      loading: state.copyWith(busy: true, failure: null),
      onSuccess: (_) => state.copyWith(busy: false),
      onFailure: (failure) => state.copyWith(busy: false, failure: failure),
    );
    if (state.failure == null) await load();
  }
}
