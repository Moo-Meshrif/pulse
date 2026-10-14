import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/audience_list.dart';
import 'package:pulse/features/story/data/enums/audience_tab.dart';
import 'package:pulse/features/story/data/model/audience_person_model.dart';
import 'package:pulse/features/story/presentation/cubit/audience_list_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/audience_list_status.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';

import '../../../../helpers/content_mocks.dart';

class _Stories extends Mock implements StoriesDatasource {}

AudiencePersonModel person(String id, {bool selected = false}) =>
    AudiencePersonModel(
      userId: id,
      username: id,
      fullName: 'Name $id',
      selected: selected,
    );

void main() {
  late _Stories stories;
  late MockGetAudienceSummary summary;

  setUpAll(() {
    registerFallbackValue(AudienceList.closeFriends);
    registerFallbackValue(AudienceTab.suggested);
  });

  setUp(() {
    stories = _Stories();
    summary = MockGetAudienceSummary();
    when(() => summary()).thenAnswer(
      (_) async => const AudienceSummaryEntity(
        followers: 50,
        closeFriends: 2,
        hidden: 1,
      ),
    );
    when(
      () => stories.getAudiencePeople(
        any(),
        tab: any(named: 'tab'),
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer(
      (_) async => [person('a', selected: true), person('b'), person('c')],
    );
    when(
      () => stories.updateAudienceList(
        any(),
        add: any(named: 'add'),
        remove: any(named: 'remove'),
      ),
    ).thenAnswer((_) async {});
  });

  AudienceListCubit build([AudienceList list = AudienceList.closeFriends]) =>
      AudienceListCubit(stories, summary, list);

  test('start: the saved count of that list and the first page', () async {
    final cubit = build();
    await cubit.start();
    expect(cubit.state.status, AudienceListStatus.ready);
    expect(cubit.state.savedCount, 2);
    expect(cubit.state.people, hasLength(3));
    expect(cubit.state.selectedCount, 2);
    await cubit.close();
  });

  test('the Hide from list counts its own people', () async {
    final cubit = build(AudienceList.hiddenFrom);
    await cubit.start();
    expect(cubit.state.savedCount, 1);
    await cubit.close();
  });

  test('a failed first load is failed, and retry loads again', () async {
    when(
      () => stories.getAudiencePeople(
        any(),
        tab: any(named: 'tab'),
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.start();
    expect(cubit.state.status, AudienceListStatus.failed);

    when(
      () => stories.getAudiencePeople(
        any(),
        tab: any(named: 'tab'),
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [person('a')]);
    await cubit.retry();
    expect(cubit.state.status, AudienceListStatus.ready);
    await cubit.close();
  });

  group('taps', () {
    test(
      'toggling moves the count and the row, nothing is saved yet',
      () async {
        final cubit = build();
        await cubit.start();
        cubit.toggle(person('b'));
        expect(cubit.state.selectedCount, 3);
        expect(cubit.state.isSelected(person('b')), isTrue);
        cubit.toggle(person('a', selected: true));
        expect(cubit.state.selectedCount, 2);
        expect(cubit.state.isSelected(person('a', selected: true)), isFalse);
        verifyNever(
          () => stories.updateAudienceList(
            any(),
            add: any(named: 'add'),
            remove: any(named: 'remove'),
          ),
        );
        await cubit.close();
      },
    );

    test('tapping twice is no change at all', () async {
      final cubit = build();
      await cubit.start();
      cubit.toggle(person('b'));
      cubit.toggle(person('b'));
      expect(cubit.state.selectedCount, 2);
      await cubit.save();
      expect(cubit.state.isSaved, isTrue);
      verifyNever(
        () => stories.updateAudienceList(
          any(),
          add: any(named: 'add'),
          remove: any(named: 'remove'),
        ),
      );
      await cubit.close();
    });

    test('Done saves the adds and the removals together', () async {
      final cubit = build();
      await cubit.start();
      cubit.toggle(person('b'));
      cubit.toggle(person('c'));
      cubit.toggle(person('a', selected: true));
      await cubit.save();
      verify(
        () => stories.updateAudienceList(
          AudienceList.closeFriends,
          add: ['b', 'c'],
          remove: ['a'],
        ),
      ).called(1);
      expect(cubit.state.isSaved, isTrue);
      await cubit.close();
    });

    test('a failed save keeps the taps and says why', () async {
      when(
        () => stories.updateAudienceList(
          any(),
          add: any(named: 'add'),
          remove: any(named: 'remove'),
        ),
      ).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.start();
      cubit.toggle(person('b'));
      await cubit.save();
      expect(cubit.state.isSaved, isFalse);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.failure, const NetworkFailure());
      expect(cubit.state.selectedCount, 3);
      await cubit.close();
    });
  });

  test('someone on the other list is ticked like anyone', () async {
    final cubit = build();
    await cubit.start();
    const onOther = AudiencePersonModel(
      userId: 'x',
      username: 'x',
      isInOtherList: true,
    );
    cubit.toggle(onOther);
    expect(cubit.state.isSelected(onOther), isTrue);
    expect(cubit.state.selectedCount, 3);
    await cubit.close();
  });

  group('hasChanges (what Done waits for)', () {
    test('false until something is ticked or unticked', () async {
      final cubit = build();
      await cubit.start();
      expect(cubit.state.hasChanges, isFalse);
      cubit.toggle(person('b'));
      expect(cubit.state.hasChanges, isTrue);
      await cubit.close();
    });

    test('ticking and unticking the same person is no change', () async {
      final cubit = build();
      await cubit.start();
      cubit.toggle(person('b'));
      cubit.toggle(person('b'));
      expect(cubit.state.hasChanges, isFalse);
      await cubit.close();
    });

    test('unticking someone who was on the list is a change', () async {
      final cubit = build();
      await cubit.start();
      cubit.toggle(person('a', selected: true));
      expect(cubit.state.hasChanges, isTrue);
      await cubit.close();
    });
  });

  group('search and tabs', () {
    test('the Selected tab asks for it and reloads', () async {
      final cubit = build();
      await cubit.start();
      cubit.setTab(AudienceTab.selected);
      await pumpEventQueue();
      verify(
        () => stories.getAudiencePeople(
          AudienceList.closeFriends,
          tab: AudienceTab.selected,
          query: '',
          limit: AudienceListCubit.pageSize,
          offset: 0,
        ),
      ).called(1);
      await cubit.close();
    });

    test('typing waits for a pause, then searches once', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        clearInteractions(stories);

        cubit.setQuery('s');
        async.elapse(const Duration(milliseconds: 100));
        cubit.setQuery('sa');
        async.elapse(const Duration(milliseconds: 100));
        cubit.setQuery('sar');
        async.elapse(AudienceListCubit.searchDelay);
        async.flushMicrotasks();

        verify(
          () => stories.getAudiencePeople(
            AudienceList.closeFriends,
            tab: AudienceTab.suggested,
            query: 'sar',
            limit: AudienceListCubit.pageSize,
            offset: 0,
          ),
        ).called(1);
        verifyNoMoreInteractions(stories);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('an older answer never replaces a newer search', () async {
      final slow = <String, List<AudiencePersonModel>>{};
      when(
        () => stories.getAudiencePeople(
          any(),
          tab: any(named: 'tab'),
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((i) async {
        final query = i.namedArguments[#query] as String?;
        if (query == 'old') {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        return slow[query ?? ''] ??= [person(query ?? 'all')];
      });
      final cubit = build();
      await cubit.start();
      cubit.setQuery('old');
      await Future<void>.delayed(AudienceListCubit.searchDelay * 1.2);
      cubit.setQuery('new');
      await Future<void>.delayed(
        AudienceListCubit.searchDelay * 1.2 + const Duration(milliseconds: 80),
      );
      expect(cubit.state.people.single.userId, 'new');
      await cubit.close();
    });
  });

  test('a full page loads the next one after the last person', () async {
    when(
      () => stories.getAudiencePeople(
        any(),
        tab: any(named: 'tab'),
        query: any(named: 'query'),
        limit: AudienceListCubit.pageSize,
        offset: 0,
      ),
    ).thenAnswer(
      (_) async => [
        for (var i = 0; i < AudienceListCubit.pageSize; i++) person('p$i'),
      ],
    );
    when(
      () => stories.getAudiencePeople(
        any(),
        tab: any(named: 'tab'),
        query: any(named: 'query'),
        limit: AudienceListCubit.pageSize,
        offset: AudienceListCubit.pageSize,
      ),
    ).thenAnswer((_) async => [person('last')]);
    final cubit = build();
    await cubit.start();
    expect(cubit.state.hasMore, isTrue);
    await cubit.loadMore();
    expect(cubit.state.people.last.userId, 'last');
    expect(cubit.state.hasMore, isFalse);
    await cubit.close();
  });
}
