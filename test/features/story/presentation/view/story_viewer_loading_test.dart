import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/video_overlay_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer/story_viewer_cubit.dart';
import 'package:pulse/features/story/presentation/view/story_viewer_view.dart';
import 'package:pulse/features/story/presentation/widgets/story_progress_bars.dart';

import '../../../../helpers/content_mocks.dart';
import '../../../../helpers/pump_app.dart';

class _Rail extends Mock implements GetStoryRailUseCase {}

class _Stories extends Mock implements StoriesDatasource {}

class _Gallery extends Mock implements GalleryService {}

class _VideoOverlay extends Fake implements VideoOverlayService {}

void main() {
  late Completer<List<StoryRailItemEntity>> rail;
  late StoryViewerCubit cubit;

  setUp(() {
    rail = Completer();
    final railCase = _Rail();
    when(() => railCase()).thenAnswer((_) => rail.future);
    cubit = StoryViewerCubit(
      railCase,
      _Stories(),
      _Gallery(),
      _VideoOverlay(),
      okSetMute(),
      okReportContent(),
      okRemoveMediaFiles(),
      EventBus(),
    );
  });

  tearDown(() => cubit.close());

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    StoryRailItemEntity? person,
  }) async {
    setUpView(tester);
    unawaited(cubit.load('a')); // the rail has not answered yet
    await tester.pumpApp(
      Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: BlocProvider.value(
                        value: cubit,
                        child: StoryViewerView(authorId: 'a', person: person),
                      ),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
      locale: locale,
      settle: false,
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('while loading: the close button is there, the rest of the '
      'header is not', (tester) async {
    await open(tester);
    expect(find.bySemanticsLabel(l10nEn.close), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyMore), findsNothing);
    expect(find.bySemanticsLabel(l10nEn.storyLike), findsNothing);
    expect(find.text(l10nEn.storyReplyHint), findsNothing);
  });

  testWidgets('the close button leaves a viewer that is still loading', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(StoryViewerView), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('the close button is a 44 target at the end, in both '
      'directions', (tester) async {
    await open(tester);
    final en = tester.getRect(find.bySemanticsLabel(l10nEn.close));
    expect(en.width, greaterThanOrEqualTo(44));
    expect(en.center.dx, greaterThan(195));
    rail.complete(const []); // let the Cubit finish before the next test
    await tester.pumpWidget(const SizedBox());
    await open(tester, locale: const Locale('ar'));
    expect(
      tester.getRect(find.bySemanticsLabel(l10nAr.close)).center.dx,
      lessThan(195),
    );
  });

  group('with the person the rail passed', () {
    const nour = StoryRailItemEntity(
      authorId: 'a',
      username: 'nour.adel',
      fullName: 'Nour Adel',
      isMe: false,
      storyCount: 3,
      allSeen: false,
    );

    testWidgets('shows their avatar and name, one empty bar and the X, nothing '
        'else of the header', (tester) async {
      await open(tester, person: nour);
      expect(find.text('nour.adel'), findsOneWidget);
      expect(find.text('NA'), findsOneWidget); // the initials avatar
      expect(find.byType(StoryProgressBars), findsOneWidget);
      // One bar, whatever the rail counted: the stories are not known until they load.
      expect(
        tester.widget<StoryProgressBars>(find.byType(StoryProgressBars)).count,
        1,
      );
      expect(find.bySemanticsLabel(l10nEn.close), findsOneWidget);
      expect(find.bySemanticsLabel(l10nEn.storyMore), findsNothing);
      expect(find.bySemanticsLabel(l10nEn.storyLike), findsNothing);
      expect(find.text(l10nEn.storyReplyHint), findsNothing);
    });

    testWidgets('the bars stay empty while loading', (tester) async {
      await open(tester, person: nour);
      expect(
        tester
            .widget<StoryProgressBars>(find.byType(StoryProgressBars))
            .progress
            .value,
        0,
      );
    });

    testWidgets('your own story reads "Your story"', (tester) async {
      await open(
        tester,
        person: const StoryRailItemEntity(
          authorId: 'me',
          username: 'me',
          isMe: true,
          storyCount: 1,
          allSeen: true,
        ),
      );
      expect(find.text(l10nEn.storyYourStory), findsOneWidget);
    });

    testWidgets('X still leaves, and in Arabic sits at the left', (
      tester,
    ) async {
      await open(tester, person: nour, locale: const Locale('ar'));
      expect(
        tester.getCenter(find.bySemanticsLabel(l10nAr.close)).dx,
        lessThan(195),
      );
      await tester.tap(find.bySemanticsLabel(l10nAr.close));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(StoryViewerView), findsNothing);
    });
  });
}
