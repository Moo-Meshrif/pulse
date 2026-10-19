import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/video_overlay_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/data/model/story_viewer_model.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/story_audience_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewers_cubit.dart';
import 'package:pulse/features/story/presentation/view/story_viewer_view.dart';
import 'package:pulse/features/story/presentation/widgets/story_paused_chip.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/mute_scope.dart';
import 'package:pulse/shared/content/domain/use_case/remove_media_files_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

import '../../../../../helpers/content_mocks.dart';
import '../../../../../helpers/png_http_overrides.dart';
import '../../../../../helpers/pump_app.dart';

const _nour = StoryRailItemEntity(
  authorId: 'a',
  username: 'nour.adel',
  fullName: 'Nour Adel',
  isMe: false,
  storyCount: 1,
  allSeen: false,
);
const _me = StoryRailItemEntity(
  authorId: 'me',
  username: 'me',
  fullName: 'Me Myself',
  isMe: true,
  storyCount: 1,
  allSeen: true,
);

class _Rail implements GetStoryRailUseCase {
  @override
  Future<List<StoryRailItemEntity>> call() async => const [_nour, _me];
}

/// One fake datasource for the whole viewer: it records what the menus do (mute, delete, report).
class _Stories extends Fake implements StoriesDatasource {
  final deleted = <String?>[];

  @override
  Future<List<StoryModel>> getAuthorStories(String authorId) async => [
    StoryModel(
      id: authorId == 'a' ? 'a1' : 'm1',
      type: StoryMediaType.image,
      mediaUrl: 'https://test.local/$authorId.jpg',
      seenByMe: true,
      likedByMe: false,
      viewCount: authorId == 'a' ? null : 24,
    ),
  ];

  @override
  Future<void> markViewed(String storyId) async {}

  @override
  Future<void> deleteStory(StoryModel story) async => deleted.add(story.id);

  @override
  Future<List<StoryViewerModel>> getViewers(
    String storyId, {
    required int limit,
    DateTime? before,
  }) async => [
    StoryViewerModel(
      userId: 'u1',
      username: 'sara',
      fullName: 'Sara Ali',
      viewedAt: DateTime(2026, 10, 13, 12),
      liked: true,
      total: 24,
    ),
    StoryViewerModel(
      userId: 'u2',
      username: 'omar',
      fullName: 'Omar Hassan',
      viewedAt: DateTime(2026, 10, 13, 11),
      liked: false,
      total: 24,
    ),
  ];
}

class _Gallery extends Fake implements GalleryService {}

class _VideoOverlay extends Fake implements VideoOverlayService {}

class _Mute extends Fake implements SetMuteUseCase {
  final calls = <(String, bool)>[];

  @override
  Future<void> call(
    String userId, {
    required bool muted,
    required MuteScope scope,
  }) async => calls.add((userId, muted));
}

class _RemoveFiles extends Fake implements RemoveMediaFilesUseCase {
  @override
  Future<void> call(List<String> paths) async {}
}

class _Report extends Fake implements ReportContentUseCase {
  final calls = <(String, ReportReason)>[];

  @override
  Future<void> call(
    ContentKind kind,
    String id,
    ReportReason reason, {
    String? note,
  }) async => calls.add((id, reason));
}

void main() {
  late _Stories stories;
  late _Mute mute;
  late _Report report;
  late StoryViewerCubit cubit;
  HttpOverrides? previous;

  setUpAll(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = PngHttpOverrides();
  });
  tearDownAll(() => HttpOverrides.global = previous);

  setUp(() async {
    stories = _Stories();
    mute = _Mute();
    report = _Report();
    await getIt.reset();
    getIt.registerFactoryParam<StoryAudienceCubit, String, ContentAudience>(
      (id, audience) => StoryAudienceCubit(
        okGetAudienceSummary(),
        okSetContentAudience(),
        id,
        audience,
      ),
    );
    getIt.registerFactory<StoryViewersCubit>(() => StoryViewersCubit(stories));
    cubit = StoryViewerCubit(
      _Rail(),
      stories,
      _Gallery(),
      _VideoOverlay(),
      mute,
      report,
      _RemoveFiles(),
      EventBus(),
    );
  });

  tearDown(() async {
    await cubit.close();
    await getIt.reset();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> open(
    WidgetTester tester,
    String author, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    VoidCallback? onPopped,
  }) async {
    setUpView(tester, textScale: textScale);
    await cubit.load(author);
    await tester.pumpApp(
      Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (_) => Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context)
                    .push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          body: BlocProvider.value(
                            value: cubit,
                            child: StoryViewerView(authorId: author),
                          ),
                        ),
                      ),
                    )
                    .then((_) => onPopped?.call()),
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

  Future<void> tapMore(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel(l10nEn.storyMore));
    await settle(tester);
  }

  group("someone's story", () {
    testWidgets('the sheet pauses the story and offers mute, profile, report', (
      tester,
    ) async {
      await open(tester, 'a');
      expect(find.byType(StoryPausedChip), findsNothing);

      await tapMore(tester);

      expect(find.byType(StoryPausedChip), findsOneWidget);
      expect(find.text(l10nEn.storyPaused), findsOneWidget);
      expect(find.text(l10nEn.storyMute('nour.adel')), findsOneWidget);
      expect(find.text(l10nEn.storyMuteHint), findsOneWidget);
      expect(find.text(l10nEn.storyGoToProfile), findsOneWidget);
      expect(find.text(l10nEn.storyReportTitle), findsOneWidget);
      expect(find.text(l10nEn.storyDelete), findsNothing);
      expect(find.text(l10nEn.storySaveToDevice), findsNothing);

      // Dismissed from the scrim: the story plays again.
      await tester.tapAt(const Offset(195, 40));
      await settle(tester);
      expect(find.byType(StoryPausedChip), findsNothing);
      expect(cubit.state.isPaused, isFalse);
    });

    testWidgets('mute hides the person, moves on and Undo takes it back', (
      tester,
    ) async {
      await open(tester, 'a');
      await tapMore(tester);

      await tester.tap(find.text(l10nEn.storyMute('nour.adel')));
      await settle(tester);

      expect(mute.calls, [('a', true)]);
      expect(cubit.state.person!.authorId, 'me');
      expect(find.text(l10nEn.storyMuted('nour.adel')), findsOneWidget);

      await tester.tap(find.text(l10nEn.undo));
      await settle(tester);
      expect(mute.calls.last, ('a', false));
    });

    testWidgets('report sends the reason, then Done skips to the next', (
      tester,
    ) async {
      await open(tester, 'a');
      await tapMore(tester);

      await tester.tap(find.text(l10nEn.storyReportTitle));
      await settle(tester);
      expect(find.text(l10nEn.storyReportBody), findsOneWidget);

      await tester.tap(find.text(l10nEn.reportReasonSpam));
      await settle(tester);
      expect(report.calls, [('a1', ReportReason.spam)]);

      await tester.tap(find.text(l10nEn.reportDone));
      await settle(tester);
      expect(cubit.state.person!.authorId, 'me');
      expect(cubit.state.isPaused, isFalse);
    });
  });

  group('your story', () {
    testWidgets('the sheet offers save, audience, viewers and delete', (
      tester,
    ) async {
      await open(tester, 'me');
      await tapMore(tester);

      expect(find.text(l10nEn.storySaveToDevice), findsOneWidget);
      expect(find.text(l10nEn.storyWhoCanSee), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceFollowers), findsOneWidget);
      expect(find.text(l10nEn.storyViewersItem), findsOneWidget);
      expect(find.text('24'), findsWidgets);
      expect(find.text(l10nEn.storyDelete), findsOneWidget);
      expect(find.text(l10nEn.storyReportTitle), findsNothing);
      expect(find.text(l10nEn.storyGoToProfile), findsNothing);

      // The audience row opens the Who can see this sheet.
      await tester.tap(find.text(l10nEn.storyWhoCanSee));
      await settle(tester);
      expect(find.text(l10nEn.storyAudienceBody), findsOneWidget);
      expect(find.text(l10nEn.storyAudienceCloseFriends), findsOneWidget);
    });

    testWidgets('delete asks first; Cancel keeps the story', (tester) async {
      await open(tester, 'me');
      await tapMore(tester);
      await tester.tap(find.text(l10nEn.storyDelete));
      await settle(tester);

      expect(find.text(l10nEn.storyDeleteTitle), findsOneWidget);
      expect(find.text(l10nEn.storyDeleteBody(24)), findsOneWidget);

      await tester.tap(find.text(l10nEn.cancel));
      await settle(tester);
      expect(stories.deleted, isEmpty);
      expect(find.byType(StoryPausedChip), findsNothing);
    });

    testWidgets('Delete removes the last story, shows the notice, closes', (
      tester,
    ) async {
      var popped = false;
      await open(tester, 'me', onPopped: () => popped = true);
      await tapMore(tester);
      await tester.tap(find.text(l10nEn.storyDelete));
      await settle(tester);

      await tester.tap(find.text(l10nEn.delete));
      await settle(tester);

      expect(stories.deleted, isEmpty); // waits for the notice to end
      expect(cubit.state.isFinished, isTrue);
      expect(find.text(l10nEn.storyDeleted), findsOneWidget);

      await tester.tap(find.text(l10nEn.storyDeleted));
      await settle(tester);
      expect(stories.deleted, ['m1']);
      expect(popped, isFalse); // the screen (not the bare view) pops on finish
    });

    testWidgets('the count chip opens the viewers sheet', (tester) async {
      await open(tester, 'me');
      await tester.tap(find.bySemanticsLabel(l10nEn.storyViewers(24)));
      await settle(tester);

      expect(find.byType(StoryPausedChip), findsOneWidget);
      expect(find.text(l10nEn.storyViewers(24)), findsWidgets);
      expect(find.text('Sara Ali'), findsOneWidget);
      expect(find.text('@sara'), findsOneWidget);
      expect(find.text('Omar Hassan'), findsOneWidget);
    });

    testWidgets('swiping up opens the viewers sheet', (tester) async {
      await open(tester, 'me');
      await tester.flingFrom(
        const Offset(195, 600),
        const Offset(0, -300),
        1500,
      );
      await settle(tester);
      expect(find.text('Sara Ali'), findsOneWidget);
    });

    testWidgets('swiping up on someone else\'s story does nothing', (
      tester,
    ) async {
      await open(tester, 'a');
      await tester.flingFrom(
        const Offset(195, 600),
        const Offset(0, -300),
        1500,
      );
      await settle(tester);
      expect(find.byType(StoryPausedChip), findsNothing);
    });

    testWidgets('the viewers sheet delete circle leads to the dialog', (
      tester,
    ) async {
      await open(tester, 'me');
      await tester.tap(find.bySemanticsLabel(l10nEn.storyViewers(24)));
      await settle(tester);

      await tester.tap(find.bySemanticsLabel(l10nEn.storyDelete));
      await settle(tester);
      expect(find.text(l10nEn.storyDeleteTitle), findsOneWidget);
    });
  });

  group('locale and text size', () {
    testWidgets('Arabic: the options sheet is Arabic and mirrors', (
      tester,
    ) async {
      await open(tester, 'a', locale: const Locale('ar'));
      await tester.tap(find.bySemanticsLabel(l10nAr.storyMore));
      await settle(tester);

      expect(find.text(l10nAr.storyMute('nour.adel')), findsOneWidget);
      expect(find.text(l10nAr.storyGoToProfile), findsOneWidget);
      final edge = tester.getTopRight(find.text(l10nAr.storyGoToProfile));
      expect(
        edge.dx,
        lessThan(390 - 16 - 16 - 22),
      ); // icon sits at the right, text beside it
    });

    testWidgets('1.5x text: the sheets do not overflow', (tester) async {
      await open(tester, 'me', textScale: 1.5);
      await tapMore(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10nEn.storyViewersItem));
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Sara Ali'), findsOneWidget);
    });
  });
}
