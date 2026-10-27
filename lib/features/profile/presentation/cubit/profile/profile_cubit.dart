import 'package:injectable/injectable.dart';

import '../../../../../core/enums/auth_failure_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/launch_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../post/domain/use_case/sign_post_media_urls_use_case.dart';
import '../../../data/datasource/profile_page_datasource.dart';
import '../../../data/model/profile_grid_item_model.dart';
import '../../../data/model/profile_page_model.dart';
import '../../../data/repository/profile_repository.dart';
import '../../../domain/use_case/get_current_user_id_use_case.dart';
import '../../utils/enums/profile_status.dart';
import '../../utils/enums/profile_tab.dart';
import '../../utils/profile_link.dart';
import 'profile_state.dart';

/// The signed-in user's own profile page: the header, the numbers and the Posts and Saved grids
/// (docs/specs/profile/screens/s1-profile.md).
@injectable
class ProfileCubit extends BaseCubit<ProfileState> {
  ProfileCubit(
    this._pages,
    this._profiles,
    this._currentUserId,
    this._signMedia,
    this._launch,
  ) : super(const ProfileState());

  final ProfilePageDatasource _pages;
  final ProfileRepository _profiles;
  final GetCurrentUserIdUseCase _currentUserId;
  final SignPostMediaUrlsUseCase _signMedia;
  final LaunchService _launch;

  /// Loads the header and the active tab's first page, together.
  Future<void> load() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        gridStatus: ProfileStatus.loading,
      ),
    );
    await Future.wait([_loadHeader(), _loadFirstPage()]);
  }

  /// Pull to refresh: both again, keeping what is on screen until it arrives.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true, refreshFailure: null));
    await Future.wait([_loadHeader(quiet: true), _loadFirstPage(quiet: true)]);
    emit(state.copyWith(isRefreshing: false));
  }

  /// Opens the share sheet with the link of this profile.
  Future<void> shareProfile() async {
    final username = state.page?.username;
    if (username == null) return;
    await _launch.shareText(profileLink(username));
  }

  /// The "Try again" of a grid that failed to load.
  Future<void> retryGrid() async {
    emit(state.copyWith(gridStatus: ProfileStatus.loading));
    await _loadFirstPage();
  }

  Future<void> selectTab(ProfileTab tab) async {
    if (tab == state.tab) return;
    emit(
      state.copyWith(
        tab: tab,
        items: const [],
        hasMore: false,
        loadMore: LoadMoreStatus.idle,
        gridStatus: tab == ProfileTab.shorts
            ? ProfileStatus.ready
            : ProfileStatus.loading,
      ),
    );
    await _loadFirstPage();
  }

  Future<void> loadMore() async {
    await run(
      () => _page(before: state.items.last),
      prevent:
          !state.hasMore ||
          state.items.isEmpty ||
          state.loadMore != LoadMoreStatus.idle ||
          state.gridStatus != ProfileStatus.ready,
      loading: state.copyWith(loadMore: LoadMoreStatus.loading),
      onSuccess: (items) => state.copyWith(
        items: [...state.items, ...items],
        hasMore: items.length == ProfilePageDatasource.pageSize,
        loadMore: LoadMoreStatus.idle,
      ),
      onFailure: (_) => state.copyWith(loadMore: LoadMoreStatus.failed),
    );
    await _signMissing();
  }

  /// The "Retry" of a page that failed.
  Future<void> retryLoadMore() async {
    emit(state.copyWith(loadMore: LoadMoreStatus.idle));
    await loadMore();
  }

  Future<void> _loadHeader({bool quiet = false}) => run(
    _header,
    onSuccess: (header) => state.copyWith(
      status: ProfileStatus.ready,
      page: header.page,
      fromDevice: header.fromDevice,
    ),
    onFailure: (failure) => quiet || state.page != null
        ? state.copyWith(refreshFailure: failure)
        : state.copyWith(status: ProfileStatus.failed),
  );

  Future<void> _loadFirstPage({bool quiet = false}) async {
    final tab = state.tab;
    if (tab == ProfileTab.shorts) return;
    await run(
      () => _page(),
      onSuccess: (items) {
        // The person moved to another tab while this one loaded.
        if (state.tab != tab) return null;
        return state.copyWith(
          gridStatus: ProfileStatus.ready,
          items: items,
          hasMore: items.length == ProfilePageDatasource.pageSize,
          loadMore: LoadMoreStatus.idle,
        );
      },
      onFailure: (failure) {
        if (state.tab != tab) return null;
        return quiet
            ? state.copyWith(refreshFailure: failure)
            : state.copyWith(gridStatus: ProfileStatus.failed);
      },
    );
    await _signMissing();
  }

  Future<List<ProfileGridItemModel>> _page({ProfileGridItemModel? before}) {
    final userId = _userId;
    return switch (state.tab) {
      ProfileTab.posts => _pages.getPosts(userId, before: before),
      ProfileTab.saved => _pages.getSavedPosts(before: before),
      ProfileTab.shorts => Future.value(const []),
    };
  }

  String get _userId =>
      _currentUserId() ??
      (throw const AuthFailure(AuthFailureReason.sessionExpired));

  /// The page from the server; when the connection fails, the profile saved on the phone, without numbers.
  Future<({ProfilePageModel page, bool fromDevice})> _header() async {
    try {
      final page = await _pages.getProfilePage(_userId);
      if (page == null) throw const NotFoundFailure();
      return (page: page, fromDevice: false);
    } on Failure catch (failure) {
      if (failure is! NetworkFailure && failure is! TimeoutFailure) rethrow;
      final saved = await _profiles.getProfile();
      return (
        page: ProfilePageModel(
          id: saved.id,
          username: saved.username,
          fullName: saved.fullName,
          bio: saved.bio,
          city: saved.city,
          avatarUrl: saved.avatarUrl,
        ),
        fromDevice: true,
      );
    }
  }

  /// Signs the pictures of the tiles that have no link yet. A tile whose link failed keeps its blurhash.
  Future<void> _signMissing() async {
    final paths = {
      for (final item in state.items)
        if (item.thumbPath case final path? when !state.urls.containsKey(path))
          path,
    };
    if (paths.isEmpty) return;
    try {
      final signed = await _signMedia(paths.toList());
      emit(state.copyWith(urls: {...state.urls, ...signed}));
    } on Failure {
      // The grid stays on its blurhashes; the next page or refresh tries again.
    }
  }
}
