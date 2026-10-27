import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/domain/entity/tag_person_entity.dart';
import 'package:pulse/features/post/presentation/cubit/tag_people/tag_people_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/tag_people_status.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_people_args.dart';

import '../../../post_doubles.dart';

TagPersonEntity person(String id, {bool canTag = true}) =>
    TagPersonEntity(id: id, username: 'user$id', canTag: canTag);

void main() {
  late MockPostRepository posts;
  late TagPeopleCubit cubit;

  TagPeopleCubit build([List<TagChoice> chosen = const []]) =>
      TagPeopleCubit(posts, TagPeopleArgs(chosen: chosen, photos: const []));

  setUp(() {
    posts = MockPostRepository();
    when(() => posts.searchTagPeople(any()))
        .thenAnswer((_) async => [person('1'), person('2')]);
    cubit = build();
  });

  tearDown(() => cubit.close());

  test('loads the suggested people', () async {
    await cubit.load();

    expect(cubit.state.status, TagPeopleStatus.ready);
    expect(cubit.state.people.length, 2);
    verify(() => posts.searchTagPeople(null)).called(1);
  });

  test('a failed load can be tried again', () async {
    when(() => posts.searchTagPeople(any())).thenThrow(const NetworkFailure());
    await cubit.load();
    expect(cubit.state.status, TagPeopleStatus.failed);

    when(() => posts.searchTagPeople(any()))
        .thenAnswer((_) async => [person('1')]);
    await cubit.load();
    expect(cubit.state.status, TagPeopleStatus.ready);
  });

  group('choosing', () {
    test('a tap tags the person, a second tap takes them off', () {
      cubit
        ..toggle(person('1'))
        ..toggle(person('2'));
      expect(cubit.state.chosen.map((c) => c.id), ['1', '2']);

      cubit.toggle(person('1'));
      expect(cubit.state.chosen.map((c) => c.id), ['2']);
    });

    test('someone who does not allow tags cannot be picked', () {
      cubit.toggle(person('1', canTag: false));
      expect(cubit.state.chosen, isEmpty);
    });

    test('a chosen person can still be taken off', () {
      final cubit = build([const TagChoice(id: '1', username: 'u')]);
      cubit.toggle(person('1', canTag: false));
      expect(cubit.state.chosen, isEmpty);
    });

    test('stops at the most people and says so once', () {
      for (var i = 0; i < TagLimits.maxPeople; i++) {
        cubit.toggle(person('$i'));
      }
      expect(cubit.state.isFull, isTrue);

      cubit.toggle(person('extra'));

      expect(cubit.state.chosen.length, TagLimits.maxPeople);
      expect(cubit.state.isOverLimit, isTrue);
      cubit.clearOverLimit();
      expect(cubit.state.isOverLimit, isFalse);
    });

    test('remove takes one off the chips', () {
      cubit
        ..toggle(person('1'))
        ..toggle(person('2'))
        ..remove('1');
      expect(cubit.state.chosen.map((c) => c.id), ['2']);
    });

    test('knows whether anything changed since it opened', () {
      expect(cubit.hasChanges, isFalse);
      cubit.toggle(person('1'));
      expect(cubit.hasChanges, isTrue);
      cubit.remove('1');
      expect(cubit.hasChanges, isFalse);
    });

    test('Tag in photo handing spots back replaces the chosen', () {
      cubit.toggle(person('1'));
      cubit.spotsChanged([TagChoice.person(person('1')).withSpot(0, 0.5, 0.5)]);
      expect(cubit.state.chosen.single.hasSpot, isTrue);
      expect(cubit.hasChanges, isTrue);
    });
  });

  group('search', () {
    test('waits for a pause, then asks once with the text', () async {
      cubit
        ..queryChanged('s')
        ..queryChanged('sa')
        ..queryChanged('sar');
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 100),
      );

      verify(() => posts.searchTagPeople('sar')).called(1);
      verifyNever(() => posts.searchTagPeople('s'));
    });

    test('blank again goes back to the suggested people', () async {
      cubit.queryChanged('sa');
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 100),
      );
      cubit.queryChanged('  ');
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 100),
      );

      verify(() => posts.searchTagPeople(null)).called(1);
    });

    test('an older answer never replaces a newer one', () async {
      final slow = Completer<List<TagPersonEntity>>();
      when(() => posts.searchTagPeople('a')).thenAnswer((_) => slow.future);
      when(() => posts.searchTagPeople('ab'))
          .thenAnswer((_) async => [person('9')]);

      cubit.queryChanged('a');
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 50),
      );
      cubit.queryChanged('ab');
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 100),
      );
      slow.complete([person('1')]);
      await pumpEventQueue();

      expect(cubit.state.people.single.id, '9');
    });

    test('closing cancels a search that was waiting', () async {
      cubit.queryChanged('sa');
      await cubit.close();
      await Future<void>.delayed(
        TagLimits.searchDelay + const Duration(milliseconds: 100),
      );

      verifyNever(() => posts.searchTagPeople('sa'));
    });
  });
}
