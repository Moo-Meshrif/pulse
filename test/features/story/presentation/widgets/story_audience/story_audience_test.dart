import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/audience_list.dart';
import 'package:pulse/features/story/data/enums/audience_tab.dart';
import 'package:pulse/features/story/data/enums/story_audience.dart';
import 'package:pulse/features/story/data/model/audience_person_model.dart';
import 'package:pulse/features/story/data/model/audience_summary_model.dart';
import 'package:pulse/features/story/presentation/cubit/audience_list_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_audience_cubit.dart';
import 'package:pulse/features/story/presentation/screen/audience_list_screen.dart';
import 'package:pulse/features/story/presentation/widgets/story_audience/audience_check.dart';
import 'package:pulse/features/story/presentation/widgets/story_audience/story_audience_sheet.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../../helpers/pump_app.dart';

class _Stories extends Mock implements StoriesDatasource {}

AudiencePersonModel person(String id, {bool selected = false}) =>
    AudiencePersonModel(
      userId: id,
      username: '$id.user',
      fullName: 'Person $id',
      selected: selected,
    );

void main() {
  late _Stories stories;

  setUpAll(() {
    registerFallbackValue(StoryAudience.followers);
    registerFallbackValue(AudienceList.closeFriends);
    registerFallbackValue(AudienceTab.suggested);
  });

  setUp(() async {
    stories = _Stories();
    when(() => stories.getAudienceSummary()).thenAnswer(
      (_) async => const AudienceSummaryModel(
        followers: 312,
        closeFriends: 12,
        hidden: 1,
      ),
    );
    when(() => stories.setAudience(any(), any())).thenAnswer((_) async {});
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
    await getIt.reset();
    getIt.registerFactoryParam<StoryAudienceCubit, String, StoryAudience>(
      (id, audience) => StoryAudienceCubit(stories, id, audience),
    );
    getIt.registerFactoryParam<AudienceListCubit, AudienceList, void>(
      (list, _) => AudienceListCubit(stories, list),
    );
  });

  tearDown(getIt.reset);

  Future<void> pump(WidgetTester tester) =>
      tester.pump(const Duration(milliseconds: 400));

  group('the Who can see this sheet', () {
    StoryAudience? result;

    Future<void> open(
      WidgetTester tester, {
      StoryAudience audience = StoryAudience.followers,
      Locale locale = const Locale('en'),
      double textScale = 1,
    }) async {
      result = null;
      setUpView(tester, textScale: textScale);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) => MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (_) => settings.name == '/'
                ? Builder(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () async =>
                            result = await StoryAudienceSheet.show(
                              context,
                              storyId: 's1',
                              audience: audience,
                            ),
                        child: const Text('open'),
                      ),
                    ),
                  )
                : Text('route ${settings.name}'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await pump(tester);
      await pump(tester);
    }

    testWidgets('a loader fills the sheet until the numbers arrive', (
      tester,
    ) async {
      final gate = Completer<AudienceSummaryModel>();
      when(() => stories.getAudienceSummary()).thenAnswer((_) => gate.future);
      await open(tester);
      expect(find.byType(PulseLineLoader), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceFollowers), findsNothing);
      expect(find.text(l10nEn.storyAudienceDone), findsNothing);

      gate.complete(
        const AudienceSummaryModel(followers: 312, closeFriends: 12, hidden: 1),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(PulseLineLoader), findsNothing);
      expect(find.text('312 people'), findsOneWidget);
    });

    testWidgets('a failed load offers Retry, which loads again', (
      tester,
    ) async {
      when(() => stories.getAudienceSummary())
          .thenThrow(const NetworkFailure());
      await open(tester);
      expect(find.text(l10nEn.storyAudienceLoadFailed), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceFollowers), findsNothing);

      when(() => stories.getAudienceSummary()).thenAnswer(
        (_) async => const AudienceSummaryModel(
          followers: 7,
          closeFriends: 2,
          hidden: 0,
        ),
      );
      await tester.tap(find.text(l10nEn.retry));
      await tester.pump();
      await tester.pump();
      expect(find.text('7 people'), findsOneWidget);
    });

    testWidgets('title, note, the rows with their counts, and Done', (
      tester,
    ) async {
      await open(tester);
      expect(find.text(l10nEn.storyWhoCanSee), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceBody), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceFollowers), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceCloseFriends), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceHideFrom), findsOneWidget);
      expect(find.text('312 people'), findsOneWidget);
      expect(find.text('12 people'), findsOneWidget);
      expect(find.text('1 person'), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceEdit), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceDone), findsOneWidget);
    });

    testWidgets('the current audience has the green check', (tester) async {
      await open(tester);
      final checks = tester
          .widgetList<AudienceCheck>(find.byType(AudienceCheck))
          .toList();
      expect(checks.map((c) => c.selected), [true, false]);
    });

    testWidgets('Close friends is saved at once and the check moves', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await tester.pump();
      verify(() => stories.setAudience('s1', StoryAudience.closeFriends))
          .called(1);
      final checks = tester
          .widgetList<AudienceCheck>(find.byType(AudienceCheck))
          .toList();
      expect(checks.map((c) => c.selected), [false, true]);
    });

    testWidgets('a failed save goes back and says so inside the sheet', (
      tester,
    ) async {
      when(() => stories.setAudience(any(), any()))
          .thenThrow(const NetworkFailure());
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await tester.pump();
      await tester.pump();
      final checks = tester
          .widgetList<AudienceCheck>(find.byType(AudienceCheck))
          .toList();
      expect(checks.map((c) => c.selected), [true, false]);
      expect(find.text(l10nEn.errorNetwork), findsOneWidget);
    });

    testWidgets('Done closes and hands back the audience', (tester) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await tester.pump();
      await tester.tap(find.text(l10nEn.storyAudienceDone));
      await pump(tester);
      await pump(tester);
      expect(result, StoryAudience.closeFriends);
      expect(find.text(l10nEn.storyAudienceBody), findsNothing);
    });

    testWidgets('dismissing from the scrim hands back the change too', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await tester.pump();
      await tester.tapAt(const Offset(195, 40));
      await pump(tester);
      await pump(tester);
      expect(result, StoryAudience.closeFriends);
    });

    testWidgets('Edit and Hide story from open their list screens', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceEdit));
      await pump(tester);
      expect(
        find.text(
          'route ${AppRoutes.audienceCloseFriends}',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    });

    testWidgets('no close friends: a chevron row that opens the list, no Edit '
        'and no radio', (tester) async {
      when(() => stories.getAudienceSummary()).thenAnswer(
        (_) async => const AudienceSummaryModel(
          followers: 312,
          closeFriends: 0,
          hidden: 0,
        ),
      );
      await open(tester);
      expect(find.text('0 people'), findsNWidgets(2));
      expect(find.text(l10nEn.storyAudienceEdit), findsNothing);
      // Only Followers keeps a selector.
      expect(find.byType(AudienceCheck), findsOneWidget);

      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await pump(tester);
      expect(
        find.text(
          'route ${AppRoutes.audienceCloseFriends}',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      verifyNever(() => stories.setAudience(any(), any()));
    });

    testWidgets('choosing people from the empty Close friends row marks Close '
        'friends', (tester) async {
      when(() => stories.getAudienceSummary()).thenAnswer(
        (_) async => const AudienceSummaryModel(
          followers: 312,
          closeFriends: 0,
          hidden: 0,
        ),
      );
      await open(tester);
      await tester.tap(find.text(l10nEn.storyAudienceCloseFriends));
      await pump(tester);

      // The list screen saved three people.
      when(() => stories.getAudienceSummary()).thenAnswer(
        (_) async => const AudienceSummaryModel(
          followers: 312,
          closeFriends: 3,
          hidden: 0,
        ),
      );
      Navigator.of(
        tester.element(
          find.text(
            'route ${AppRoutes.audienceCloseFriends}',
            skipOffstage: false,
          ),
        ),
      ).pop(true);
      await pump(tester);
      await pump(tester);

      verify(() => stories.setAudience('s1', StoryAudience.closeFriends))
          .called(1);
      final checks = tester
          .widgetList<AudienceCheck>(find.byType(AudienceCheck))
          .map((c) => c.selected)
          .toList();
      expect(checks, [false, true]);
      expect(find.text(l10nEn.storyAudienceEdit), findsOneWidget);
    });

    testWidgets('with close friends the Edit pill and the radio are there', (
      tester,
    ) async {
      await open(tester);
      expect(find.text(l10nEn.storyAudienceEdit), findsOneWidget);
      expect(find.byType(AudienceCheck), findsNWidgets(2));
    });

    testWidgets('Arabic and 1.5x text: no overflow, strings are Arabic', (
      tester,
    ) async {
      await open(tester, locale: const Locale('ar'), textScale: 1.5);
      expect(find.text(l10nAr.storyAudienceCloseFriends), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every row is at least 56 high and the buttons 44', (
      tester,
    ) async {
      await open(tester);
      for (final title in [
        l10nEn.storyAudienceFollowers,
        l10nEn.storyAudienceCloseFriends,
        l10nEn.storyAudienceHideFrom,
      ]) {
        final row = tester.getSize(
          find
              .ancestor(of: find.text(title), matching: find.byType(InkWell))
              .first,
        );
        expect(row.height, greaterThanOrEqualTo(56), reason: title);
      }
      // The Edit button is its own node for a screen reader.
      expect(find.bySemanticsLabel(l10nEn.storyAudienceEdit), findsOneWidget);
    });
  });

  group('a list screen', () {
    bool? popped;

    Future<void> open(
      WidgetTester tester, {
      AudienceList list = AudienceList.closeFriends,
      Locale locale = const Locale('en'),
      double textScale = 1,
    }) async {
      popped = null;
      setUpView(tester, textScale: textScale);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => popped = await Navigator.of(context)
                    .push<bool>(
                      MaterialPageRoute<bool>(
                        builder: (_) => AudienceListScreen(list: list),
                      ),
                    ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await pump(tester);
      await pump(tester);
    }

    testWidgets(
      'close friends: title, count, search, hint, tabs, people, Done',
      (tester) async {
        await open(tester);
        expect(find.text(l10nEn.storyCloseFriendsTitle), findsOneWidget);
        expect(find.text('12 selected'), findsOneWidget);
        expect(find.text(l10nEn.storyAudienceSearch), findsOneWidget);
        expect(find.text(l10nEn.storyCloseFriendsHint), findsOneWidget);
        expect(find.text(l10nEn.storyAudienceTabSuggested), findsOneWidget);
        expect(find.text('Selected · 12'), findsOneWidget);
        expect(find.text('Person a'), findsOneWidget);
        expect(find.text('@a.user'), findsOneWidget);
        expect(find.text(l10nEn.storyAudienceDone), findsOneWidget);
        final checks = tester
            .widgetList<AudienceCheck>(find.byType(AudienceCheck))
            .map((c) => c.selected)
            .toList();
        expect(checks, [true, false, false]);
      },
    );

    testWidgets('Hide story from has its own title and hint', (tester) async {
      await open(tester, list: AudienceList.hiddenFrom);
      expect(find.text(l10nEn.storyHiddenTitle), findsOneWidget);
      expect(find.text(l10nEn.storyHiddenHint), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('a tap toggles the row and moves both counts', (tester) async {
      await open(tester);
      await tester.tap(find.text('Person b'));
      await tester.pump();
      expect(find.text('13 selected'), findsOneWidget);
      expect(find.text('Selected · 13'), findsOneWidget);
      await tester.tap(find.text('Person a'));
      await tester.pump();
      expect(find.text('12 selected'), findsOneWidget);
    });

    testWidgets('Done saves the changes and pops true', (tester) async {
      await open(tester);
      await tester.tap(find.text('Person b'));
      await tester.pump();
      await tester.tap(find.text(l10nEn.storyAudienceDone));
      await tester.pump();
      await pump(tester);
      await pump(tester);
      verify(
        () => stories.updateAudienceList(
          AudienceList.closeFriends,
          add: ['b'],
          remove: [],
        ),
      ).called(1);
      expect(popped, isTrue);
    });

    testWidgets('Done is dimmed and does nothing until something is picked', (
      tester,
    ) async {
      await open(tester);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(
        find.text(l10nEn.storyAudienceDone),
        warnIfMissed: false,
      );
      await tester.pump();
      verifyNever(
        () => stories.updateAudienceList(
          any(),
          add: any(named: 'add'),
          remove: any(named: 'remove'),
        ),
      );
      expect(popped, isNull);

      await tester.tap(find.text('Person b'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );

      await tester.tap(find.text('Person b')); // back to how it was
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('a failed save stays on the screen with a notice', (
      tester,
    ) async {
      when(
        () => stories.updateAudienceList(
          any(),
          add: any(named: 'add'),
          remove: any(named: 'remove'),
        ),
      ).thenThrow(const NetworkFailure());
      await open(tester);
      await tester.tap(find.text('Person b'));
      await tester.pump();
      await tester.tap(find.text(l10nEn.storyAudienceDone));
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.errorNetwork), findsOneWidget);
      expect(find.text(l10nEn.storyCloseFriendsTitle), findsOneWidget);
      expect(popped, isNull);
    });

    void stubOtherListPerson({required bool selected}) =>
        when(
          () => stories.getAudiencePeople(
            any(),
            tab: any(named: 'tab'),
            query: any(named: 'query'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer(
          (_) async => [
            AudiencePersonModel(
              userId: 'h',
              username: 'h.user',
              fullName: 'Person h',
              selected: selected,
              isInOtherList: true,
            ),
          ],
        );

    testWidgets('a person on the other list looks like anyone else', (
      tester,
    ) async {
      stubOtherListPerson(selected: false);
      await open(tester, list: AudienceList.hiddenFrom);
      expect(find.text('Person h'), findsOneWidget);
      expect(find.text('@h.user'), findsOneWidget);
    });

    testWidgets('ticking them on Hide story from asks first; Cancel changes '
        'nothing', (tester) async {
      stubOtherListPerson(selected: false);
      await open(tester, list: AudienceList.hiddenFrom);
      await tester.tap(find.text('Person h'));
      await pump(tester);

      expect(
        find.text(l10nEn.storyMoveToHiddenTitle('Person h')),
        findsOneWidget,
      );
      expect(
        find.text(l10nEn.storyMoveToHiddenBody('Person h')),
        findsOneWidget,
      );

      await tester.tap(find.text(l10nEn.cancel));
      await pump(tester);
      expect(find.text('1 selected'), findsOneWidget); // unchanged
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    });

    testWidgets('confirming ticks them and Done saves the move', (
      tester,
    ) async {
      stubOtherListPerson(selected: false);
      await open(tester, list: AudienceList.hiddenFrom);
      await tester.tap(find.text('Person h'));
      await pump(tester);
      await tester.tap(find.text(l10nEn.storyMoveToHiddenConfirm));
      await pump(tester);
      expect(find.text('2 selected'), findsOneWidget);

      await tester.tap(find.text(l10nEn.storyAudienceDone));
      await tester.pump();
      verify(
        () => stories.updateAudienceList(
          AudienceList.hiddenFrom,
          add: ['h'],
          remove: [],
        ),
      ).called(1);
    });

    testWidgets('on Close friends the question is about adding them', (
      tester,
    ) async {
      stubOtherListPerson(selected: false);
      await open(tester);
      await tester.tap(find.text('Person h'));
      await pump(tester);
      expect(
        find.text(l10nEn.storyMoveToCloseTitle('Person h')),
        findsOneWidget,
      );
      expect(find.text(l10nEn.storyMoveToCloseConfirm), findsOneWidget);
    });

    testWidgets('unticking someone already picked asks nothing', (
      tester,
    ) async {
      stubOtherListPerson(selected: true);
      await open(tester, list: AudienceList.hiddenFrom);
      await tester.tap(find.text('Person h'));
      await pump(tester);
      expect(
        find.text(l10nEn.storyMoveToHiddenTitle('Person h')),
        findsNothing,
      );
      expect(find.text('0 selected'), findsOneWidget);
    });

    testWidgets('the Selected tab asks for the saved list', (tester) async {
      await open(tester);
      await tester.tap(find.text('Selected · 12'));
      await tester.pump();
      verify(
        () => stories.getAudiencePeople(
          AudienceList.closeFriends,
          tab: AudienceTab.selected,
          query: '',
          limit: AudienceListCubit.pageSize,
          offset: 0,
        ),
      ).called(1);
    });

    testWidgets('typing searches after a pause', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextField), 'sar');
      await tester.pump(const Duration(milliseconds: 350));
      verify(
        () => stories.getAudiencePeople(
          AudienceList.closeFriends,
          tab: AudienceTab.suggested,
          query: 'sar',
          limit: AudienceListCubit.pageSize,
          offset: 0,
        ),
      ).called(1);
    });

    testWidgets('nobody found, and a failed load with Retry', (tester) async {
      when(
        () => stories.getAudiencePeople(
          any(),
          tab: any(named: 'tab'),
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => []);
      await open(tester);
      expect(find.text(l10nEn.storyAudienceEmpty), findsOneWidget);
    });

    testWidgets('a load that fails offers Retry', (tester) async {
      when(
        () => stories.getAudiencePeople(
          any(),
          tab: any(named: 'tab'),
          query: any(named: 'query'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(const NetworkFailure());
      await open(tester);
      expect(find.text(l10nEn.storyAudienceLoadFailed), findsOneWidget);
      expect(find.text(l10nEn.retry), findsOneWidget);
    });

    testWidgets('the rows are at least 44 high and say selected or not to a '
        'screen reader', (tester) async {
      await open(tester);
      final row = tester.getSize(
        find
            .ancestor(of: find.text('Person b'), matching: find.byType(InkWell))
            .first,
      );
      expect(row.height, greaterThanOrEqualTo(44));
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(l10nEn.storyAudienceSelectPerson('Person a')),
        ),
        isSemantics(isButton: true, hasCheckedState: true, isChecked: true),
      );
      expect(
        tester.getSemantics(
          find.bySemanticsLabel(l10nEn.storyAudienceSelectPerson('Person b')),
        ),
        isSemantics(isButton: true, hasCheckedState: true, isChecked: false),
      );
    });

    testWidgets('Arabic mirrors the header and 1.5x text does not overflow', (
      tester,
    ) async {
      await open(tester, locale: const Locale('ar'), textScale: 1.5);
      expect(find.text(l10nAr.storyCloseFriendsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        tester.getCenter(find.bySemanticsLabel(l10nAr.back)).dx,
        greaterThan(195),
      );
    });
  });

  test('both list routes resolve to the list screen', () {
    for (final route in [
      AppRoutes.audienceCloseFriends,
      AppRoutes.audienceHidden,
    ]) {
      final resolved = AppRouter.onGenerateRoute(RouteSettings(name: route));
      expect(resolved, isA<MaterialPageRoute<dynamic>>());
      expect(resolved.settings.name, route);
    }
  });
}
