import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/launch_service.dart';
import 'package:pulse/core/state/load_more_status.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/profile/data/datasource/profile_page_datasource.dart';
import 'package:pulse/features/profile/data/model/profile_grid_item_model.dart';
import 'package:pulse/features/profile/data/model/profile_page_model.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/profile/profile_cubit.dart';
import 'package:pulse/features/profile/presentation/utils/enums/profile_status.dart';
import 'package:pulse/features/profile/presentation/utils/enums/profile_tab.dart';

class _MockPages extends Mock implements ProfilePageDatasource {}

class _MockProfiles extends Mock implements ProfileRepository {}

class _MockUserId extends Mock implements GetCurrentUserIdUseCase {}

class _MockSign extends Mock implements SignPostMediaUrlsUseCase {}

class _MockLaunch extends Mock implements LaunchService {}

void main() {
  late _MockPages pages;
  late _MockProfiles profiles;
  late _MockSign sign;
  late _MockLaunch launch;
  late ProfileCubit cubit;

  const page = ProfilePageModel(
    id: 'me',
    username: 'ada',
    fullName: 'Ada',
    postsCount: 2,
  );

  ProfileGridItemModel tile(int n) => ProfileGridItemModel(
    id: 'p$n',
    sortAt: DateTime.utc(2026, 1, n),
    firstPath: 'path$n',
  );

  List<ProfileGridItemModel> fullPage() => [
    for (var i = 1; i <= ProfilePageDatasource.pageSize; i++) tile(i),
  ];

  setUp(() {
    pages = _MockPages();
    profiles = _MockProfiles();
    sign = _MockSign();
    launch = _MockLaunch();
    final userId = _MockUserId();
    when(() => userId()).thenReturn('me');
    when(() => pages.getProfilePage('me')).thenAnswer((_) async => page);
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => [tile(1), tile(2)]);
    when(() => pages.getSavedPosts(before: any(named: 'before')))
        .thenAnswer((_) async => [tile(3)]);
    when(() => sign(any())).thenAnswer((_) async => {'path1': 'https://u/1'});
    when(() => launch.shareText(any())).thenAnswer((_) async => true);
    cubit = ProfileCubit(pages, profiles, userId, sign, launch, EventBus());
  });

  tearDown(() => cubit.close());

  test('load shows the header, the posts and their links', () async {
    await cubit.load();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.page, page);
    expect(cubit.state.fromDevice, isFalse);
    expect(cubit.state.gridStatus, ProfileStatus.ready);
    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.urls, {'path1': 'https://u/1'});
  });

  test('a person with no posts gets an empty ready grid', () async {
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => const []);

    await cubit.load();

    expect(cubit.state.gridStatus, ProfileStatus.ready);
    expect(cubit.state.items, isEmpty);
    verifyNever(() => sign(any()));
  });

  test('a header failure with no connection shows the saved profile', () async {
    when(() => pages.getProfilePage('me')).thenThrow(const NetworkFailure());
    when(() => profiles.getProfile()).thenAnswer(
      (_) async =>
          const ProfileEntity(id: 'me', username: 'ada', fullName: 'Ada'),
    );

    await cubit.load();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.fromDevice, isTrue);
    expect(cubit.state.page?.username, 'ada');
    expect(cubit.state.page?.postsCount, isNull);
  });

  test('any other header failure fails the page', () async {
    when(() => pages.getProfilePage('me')).thenThrow(const ServerFailure());

    await cubit.load();

    expect(cubit.state.status, ProfileStatus.failed);
  });

  test('a grid failure fails the grid only; retry loads it', () async {
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenThrow(const ServerFailure());
    await cubit.load();
    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.gridStatus, ProfileStatus.failed);

    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => [tile(1)]);
    await cubit.retryGrid();

    expect(cubit.state.gridStatus, ProfileStatus.ready);
    expect(cubit.state.items, hasLength(1));
  });

  test('refresh replaces the posts and keeps them when it fails', () async {
    await cubit.load();
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenThrow(const NetworkFailure());

    await cubit.refresh();

    expect(cubit.state.items, hasLength(2));
    expect(cubit.state.isRefreshing, isFalse);
    expect(cubit.state.refreshFailure, const NetworkFailure());
  });

  test('load more adds the next page after the last tile', () async {
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => fullPage());
    await cubit.load();
    expect(cubit.state.hasMore, isTrue);
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => [tile(30)]);

    await cubit.loadMore();

    verify(() => pages.getPosts('me', before: fullPage().last)).called(1);
    expect(cubit.state.items, hasLength(ProfilePageDatasource.pageSize + 1));
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.loadMore, LoadMoreStatus.idle);
  });

  test('a failed page can be retried', () async {
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => fullPage());
    await cubit.load();
    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenThrow(const NetworkFailure());

    await cubit.loadMore();
    expect(cubit.state.loadMore, LoadMoreStatus.failed);

    when(() => pages.getPosts('me', before: any(named: 'before')))
        .thenAnswer((_) async => [tile(30)]);
    await cubit.retryLoadMore();
    expect(cubit.state.loadMore, LoadMoreStatus.idle);
    expect(cubit.state.items, hasLength(ProfilePageDatasource.pageSize + 1));
  });

  test('switching tabs loads that tab; Shorts loads nothing', () async {
    await cubit.load();

    await cubit.selectTab(ProfileTab.saved);
    expect(cubit.state.tab, ProfileTab.saved);
    expect(cubit.state.items.map((i) => i.id), ['p3']);

    await cubit.selectTab(ProfileTab.shorts);
    expect(cubit.state.items, isEmpty);
    expect(cubit.state.gridStatus, ProfileStatus.ready);
  });

  test('share hands the profile link to the share sheet', () async {
    await cubit.load();

    await cubit.shareProfile();

    verify(() => launch.shareText(any(that: contains('/u/ada')))).called(1);
  });
}
