import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';
import 'package:pulse/features/post/domain/entity/tagged_person_entity.dart';
import 'package:pulse/features/post/domain/use_case/get_tagged_people_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/tagged_people/tagged_people_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/tagged_people_status.dart';

class _GetPeople extends Mock implements GetTaggedPeopleUseCase {}

class _Follow extends Mock implements ToggleFollowUseCase {}

void main() {
  late _GetPeople getPeople;
  late _Follow follow;
  late TaggedPeopleCubit cubit;

  const me = TaggedPersonEntity(
    id: 'me',
    username: 'me',
    followState: FollowState.me,
  );
  const sara = TaggedPersonEntity(
    id: 'u2',
    username: 'sara',
    followState: FollowState.none,
  );
  const omar = TaggedPersonEntity(
    id: 'u3',
    username: 'omar',
    followState: FollowState.following,
  );

  FollowState stateOf(String id) =>
      cubit.state.people.firstWhere((p) => p.id == id).followState;

  setUp(() {
    getPeople = _GetPeople();
    follow = _Follow();
    cubit = TaggedPeopleCubit(getPeople, follow, 'p1');
  });

  tearDown(() => cubit.close());

  test('loads the list, and says when it cannot', () async {
    when(() => getPeople('p1')).thenAnswer((_) async => [me, sara]);
    await cubit.load();
    expect(cubit.state.status, TaggedPeopleStatus.ready);
    expect(cubit.state.people, [me, sara]);

    when(() => getPeople('p1')).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.status, TaggedPeopleStatus.failed);
  });

  group('follow', () {
    setUp(() async {
      when(() => getPeople('p1')).thenAnswer((_) async => [me, sara, omar]);
      await cubit.load();
    });

    test('shows Following at once, then what the server says', () async {
      final answer = Completer<FollowStatus>();
      when(() => follow('u2', follow: true)).thenAnswer((_) => answer.future);

      final done = cubit.toggleFollow(sara);
      expect(stateOf('u2'), FollowState.following);
      answer.complete(FollowStatus.pending);
      await done;

      expect(stateOf('u2'), FollowState.pending);
    });

    test('a following person is unfollowed', () async {
      when(() => follow('u3', follow: false))
          .thenAnswer((_) async => FollowStatus.none);

      await cubit.toggleFollow(omar);

      expect(stateOf('u3'), FollowState.none);
    });

    test('puts it back and tells once when it fails', () async {
      when(() => follow('u2', follow: true)).thenThrow(const NetworkFailure());

      await cubit.toggleFollow(sara);

      expect(stateOf('u2'), FollowState.none);
      expect(cubit.state.failure, const NetworkFailure());
    });

    test('your own row and a second tap in flight do nothing', () async {
      final answer = Completer<FollowStatus>();
      when(() => follow('u2', follow: true)).thenAnswer((_) => answer.future);

      await cubit.toggleFollow(me);
      final first = cubit.toggleFollow(sara);
      await cubit.toggleFollow(sara);
      answer.complete(FollowStatus.accepted);
      await first;

      verifyNever(() => follow('me', follow: any(named: 'follow')));
      verify(() => follow('u2', follow: true)).called(1);
    });
  });
}
