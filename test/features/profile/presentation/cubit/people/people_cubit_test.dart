import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/state/load_more_status.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/profile/data/datasource/people_datasource.dart';
import 'package:pulse/features/profile/data/datasource/profile_page_datasource.dart';
import 'package:pulse/features/profile/data/enums/people_kind.dart';
import 'package:pulse/features/profile/data/model/person_model.dart';
import 'package:pulse/features/profile/data/model/profile_page_model.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/people/people_cubit.dart';
import 'package:pulse/features/profile/presentation/utils/enums/profile_status.dart';
import 'package:pulse/features/profile/presentation/utils/people_limits.dart';

class _MockPeople extends Mock implements PeopleDatasource {}

class _MockPages extends Mock implements ProfilePageDatasource {}

class _MockToggle extends Mock implements ToggleFollowUseCase {}

class _MockUserId extends Mock implements GetCurrentUserIdUseCase {}

void main() {
  late _MockPeople people;
  late _MockPages pages;
  late _MockToggle toggle;
  late PeopleCubit cubit;

  PersonModel person(int n, {FollowStatus follow = FollowStatus.none}) =>
      PersonModel(
        id: 'u$n',
        username: 'user$n',
        followStatus: follow,
        sortAt: DateTime.utc(2026, 1, n),
      );

  List<PersonModel> fullPage() => [
    for (var i = 1; i <= PeopleDatasource.pageSize; i++) person(i),
  ];

  PeopleCubit build({PeopleKind kind = PeopleKind.followers}) {
    final userId = _MockUserId();
    when(() => userId()).thenReturn('me');
    return PeopleCubit(people, pages, toggle, userId, kind, 'target');
  }

  setUpAll(() {
    registerFallbackValue(PeopleKind.followers);
  });

  setUp(() {
    people = _MockPeople();
    pages = _MockPages();
    toggle = _MockToggle();
    when(
      () => people.getPeople(
        any(),
        any(),
        query: any(named: 'query'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => [person(1), person(2)]);
    cubit = build();
  });

  tearDown(() => cubit.close());

  test('load shows the first page', () async {
    await cubit.load();

    expect(cubit.state.status, ProfileStatus.ready);
    expect(cubit.state.people, [person(1), person(2)]);
    expect(cubit.state.hasMore, isFalse);
  });

  test('load failure shows the failed state', () async {
    when(
      () => people.getPeople(
        any(),
        any(),
        query: any(named: 'query'),
        before: any(named: 'before'),
      ),
    ).thenThrow(const NetworkFailure());

    await cubit.load();

    expect(cubit.state.status, ProfileStatus.failed);
  });

  test('an empty list of a private account not followed is locked', () async {
    when(
      () => people.getPeople(
        any(),
        any(),
        query: any(named: 'query'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => []);
    when(() => pages.getProfilePage('target')).thenAnswer(
      (_) async => const ProfilePageModel(isPrivate: true, iFollow: 'none'),
    );

    await cubit.load();

    expect(cubit.state.isLocked, isTrue);
  });

  test('an empty list of a public account is just empty', () async {
    when(
      () => people.getPeople(
        any(),
        any(),
        query: any(named: 'query'),
        before: any(named: 'before'),
      ),
    ).thenAnswer((_) async => []);
    when(() => pages.getProfilePage('target')).thenAnswer(
      (_) async => const ProfilePageModel(isPrivate: false, iFollow: 'none'),
    );

    await cubit.load();

    expect(cubit.state.isLocked, isFalse);
    expect(cubit.state.people, isEmpty);
  });

  test('load more appends the next page and skips repeats', () async {
    when(
      () => people.getPeople(
        PeopleKind.followers,
        'target',
        query: null,
        before: null,
      ),
    ).thenAnswer((_) async => fullPage());
    final last = fullPage().last;
    when(
      () => people.getPeople(
        PeopleKind.followers,
        'target',
        query: null,
        before: last,
      ),
    ).thenAnswer((_) async => [last, person(99)]);
    await cubit.load();

    await cubit.loadMore();

    expect(cubit.state.people.length, PeopleDatasource.pageSize + 1);
    expect(cubit.state.people.last, person(99));
    expect(cubit.state.hasMore, isFalse);
  });

  test('a failed page waits for retry', () async {
    when(() => people.getPeople(any(), any(), query: null, before: null))
        .thenAnswer((_) async => fullPage());
    when(
      () => people.getPeople(
        any(),
        any(),
        query: null,
        before: any(named: 'before', that: isNotNull),
      ),
    ).thenThrow(const NetworkFailure());
    await cubit.load();

    await cubit.loadMore();
    expect(cubit.state.more, LoadMoreStatus.failed);

    clearInteractions(people);
    await cubit.loadMore();
    verifyNever(
      () => people.getPeople(
        any(),
        any(),
        query: any(named: 'query'),
        before: any(named: 'before'),
      ),
    );
  });

  test('search waits for a pause, then loads with the text', () {
    fakeAsync((async) {
      cubit.queryChanged('ad');
      cubit.queryChanged('ada');
      async.elapse(PeopleLimits.searchDelay);
      async.flushMicrotasks();

      verify(
        () => people.getPeople(
          PeopleKind.followers,
          'target',
          query: 'ada',
          before: null,
        ),
      ).called(1);
    });
  });

  group('toggleFollow', () {
    test('a public follow shows Following and keeps the answer', () async {
      when(() => toggle('u1', follow: true))
          .thenAnswer((_) async => FollowStatus.accepted);
      await cubit.load();

      await cubit.toggleFollow(person(1));

      expect(cubit.state.people.first.followStatus, FollowStatus.accepted);
    });

    test('a private follow ends as Requested', () async {
      when(() => toggle('u1', follow: true))
          .thenAnswer((_) async => FollowStatus.pending);
      await cubit.load();

      await cubit.toggleFollow(person(1));

      expect(cubit.state.people.first.followStatus, FollowStatus.pending);
    });

    test('a failure puts the pill back and reports it', () async {
      when(() => toggle('u1', follow: true)).thenThrow(const NetworkFailure());
      await cubit.load();

      await cubit.toggleFollow(person(1));

      expect(cubit.state.people.first.followStatus, FollowStatus.none);
      expect(cubit.state.failure, isA<NetworkFailure>());
    });

    test('your own row does nothing', () async {
      await cubit.load();

      await cubit.toggleFollow(const PersonModel(id: 'me'));

      verifyNever(() => toggle(any(), follow: any(named: 'follow')));
    });
  });
}
