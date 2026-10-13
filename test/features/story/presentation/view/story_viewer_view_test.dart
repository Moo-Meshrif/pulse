import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/enums/story_overlay_type.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/data/model/story_overlay_model.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer_cubit.dart';
import 'package:pulse/features/story/presentation/view/story_viewer_view.dart';
import 'package:pulse/features/story/presentation/widgets/story_progress_bars.dart';

import '../../../../helpers/png_http_overrides.dart';
import '../../../../helpers/pump_app.dart';

// Hand-written fakes: the test needs no matcher state, and a mock's stubs set in setUp were lost between
// tests of this file.
class _Rail implements GetStoryRailUseCase {
  @override
  Future<List<StoryRailItemEntity>> call() async => const [
    StoryRailItemEntity(
      authorId: 'a',
      username: 'nour.adel',
      fullName: 'Nour Adel',
      isMe: false,
      storyCount: 3,
      allSeen: false,
    ),
    StoryRailItemEntity(
      authorId: 'me',
      username: 'me',
      fullName: 'Me Myself',
      isMe: true,
      storyCount: 1,
      allSeen: true,
    ),
  ];
}

class _Stories extends Fake implements StoriesDatasource {
  final likes = <(String, bool)>[];

  @override
  Future<List<StoryModel>> getAuthorStories(String authorId) async =>
      authorId == 'a'
      ? [
          story('a1', at: clock.now().subtract(const Duration(hours: 2))),
          story('a2'),
          story('a3'),
        ]
      : [story('m1', views: 24)];

  @override
  Future<void> markViewed(String storyId) async {}

  @override
  Future<void> setLiked(String storyId, {required bool liked}) async =>
      likes.add((storyId, liked));
}

class _Gallery extends Fake implements GalleryService {}

StoryModel story(String id, {bool liked = false, int? views, DateTime? at}) =>
    StoryModel(
      id: id,
      type: StoryMediaType.image,
      mediaUrl: 'https://test.local/$id.jpg',
      seenByMe: true,
      likedByMe: liked,
      viewCount: views,
      createdAt: at,
      overlays: const [
        StoryOverlayModel(
          type: StoryOverlayType.location,
          text: 'Zamalek, Cairo',
          x: 0.5,
          y: 0.6,
          rotation: -4,
        ),
        StoryOverlayModel(
          type: StoryOverlayType.text,
          text: 'Golden hour',
          x: 0.5,
          y: 0.3,
          color: '#FFFFFF',
        ),
      ],
    );

void main() {
  late _Stories stories;
  late StoryViewerCubit cubit;
  HttpOverrides? previous;

  setUpAll(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = PngHttpOverrides();
  });
  tearDownAll(() => HttpOverrides.global = previous);

  setUp(() {
    stories = _Stories();
    cubit = StoryViewerCubit(_Rail(), stories, _Gallery());
  });

  tearDown(() => cubit.close());

  Future<void> open(
    WidgetTester tester,
    String author, {
    Locale locale = const Locale('en'),
    VoidCallback? onPopped,
  }) async {
    setUpView(tester);
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

  Future<void> tapAtFraction(WidgetTester tester, double fraction) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width * fraction, size.height * 0.5));
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('someone else: bars, header, reply bar and stickers', (
    tester,
  ) async {
    await open(tester, 'a');

    expect(find.byType(StoryProgressBars), findsOneWidget);
    expect(
      tester.widget<StoryProgressBars>(find.byType(StoryProgressBars)).count,
      3,
    );
    expect(find.text('nour.adel'), findsOneWidget);
    expect(find.text('2h'), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.close), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyMore), findsOneWidget);
    expect(find.text(l10nEn.storyReplyHint), findsOneWidget);
    // An empty field shows the heart; the send icon only appears with text.
    expect(find.bySemanticsLabel(l10nEn.storyLike), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storySend), findsNothing);
    expect(find.text('ZAMALEK, CAIRO'), findsOneWidget);
    expect(find.text('Golden hour'), findsOneWidget);
  });

  testWidgets('your own story: your name and the view count, no reply bar', (
    tester,
  ) async {
    await open(tester, 'me');
    expect(find.text(l10nEn.storyYourStory), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyViewers(24)), findsOneWidget);
    expect(find.text(l10nEn.storyReplyHint), findsNothing);
  });

  group('taps', () {
    testWidgets('the right two thirds go on, the left third goes back', (
      tester,
    ) async {
      await open(tester, 'a');
      expect(cubit.state.story!.id, 'a1');

      await tapAtFraction(tester, 0.8);
      expect(cubit.state.story!.id, 'a2');
      await tapAtFraction(tester, 0.5);
      expect(cubit.state.story!.id, 'a3');
      await tapAtFraction(tester, 0.1);
      expect(cubit.state.story!.id, 'a2');
    });

    testWidgets('Arabic: the zones swap', (tester) async {
      await open(tester, 'a', locale: const Locale('ar'));
      await tapAtFraction(tester, 0.1); // the left is "next" in RTL
      expect(cubit.state.story!.id, 'a2');
      await tapAtFraction(tester, 0.9); // the right is "previous"
      expect(cubit.state.story!.id, 'a1');
    });

    testWidgets('after the last story of the last person the viewer finishes', (
      tester,
    ) async {
      await open(tester, 'me');
      await tapAtFraction(tester, 0.8);
      expect(cubit.state.isFinished, isTrue);
    });
  });

  testWidgets('a long press pauses and fades the chrome, release resumes', (
    tester,
  ) async {
    await open(tester, 'a');
    final opacity = find.ancestor(
      of: find.byType(StoryProgressBars),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(StoryViewerView)),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    expect(cubit.state.isPaused, isTrue);
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 0);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(cubit.state.isPaused, isFalse);
    expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);
  });

  testWidgets('swipe down closes the viewer', (tester) async {
    var popped = false;
    await open(tester, 'a', onPopped: () => popped = true);
    await tester.fling(
      find.byType(StoryViewerView),
      const Offset(0, 300),
      1500,
    );
    await tester.pumpAndSettle();
    expect(popped, isTrue);
  });

  testWidgets('a short drag snaps back and the story plays on', (tester) async {
    var popped = false;
    await open(tester, 'a', onPopped: () => popped = true);
    await tester.drag(find.byType(StoryViewerView), const Offset(0, 40));
    await tester.pump(const Duration(milliseconds: 500));
    expect(popped, isFalse);
    expect(cubit.state.isPaused, isFalse);
  });

  testWidgets('the heart likes the story and is labelled', (tester) async {
    await open(tester, 'a');
    await tester.tap(find.bySemanticsLabel(l10nEn.storyLike));
    await tester.pump();
    expect(cubit.state.story!.likedByMe, isTrue);
    expect(find.bySemanticsLabel(l10nEn.storyUnlike), findsOneWidget);
    expect(stories.likes, [('a1', true)]);
  });

  testWidgets('typing swaps the heart for the send icon; clearing swaps back', (
    tester,
  ) async {
    await open(tester, 'a');
    await tester.enterText(find.byType(TextField), 'Nice');
    await tester.pump();
    expect(find.bySemanticsLabel(l10nEn.storySend), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.storyLike), findsNothing);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(find.bySemanticsLabel(l10nEn.storySend), findsNothing);
    expect(find.bySemanticsLabel(l10nEn.storyLike), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    expect(find.bySemanticsLabel(l10nEn.storyLike), findsOneWidget);
  });

  testWidgets('Send shows the coming-soon notice', (tester) async {
    await open(tester, 'a');
    await tester.enterText(find.byType(TextField), 'Nice');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10nEn.storySend));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text(l10nEn.storyReplySoon), findsOneWidget);
  });

  testWidgets('Arabic: the strings are Arabic and the layout is RTL', (
    tester,
  ) async {
    await open(tester, 'a', locale: const Locale('ar'));
    expect(find.text(l10nAr.storyReplyHint), findsOneWidget);
    expect(find.bySemanticsLabel(l10nAr.close), findsOneWidget);
    // The close button is the last of the header: at the left in RTL.
    final close = tester.getCenter(find.bySemanticsLabel(l10nAr.close));
    final more = tester.getCenter(find.bySemanticsLabel(l10nAr.storyMore));
    expect(close.dx, lessThan(more.dx));
  });

  testWidgets('1.5x text: no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester, 'a');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the tap targets are at least 44 x 44', (tester) async {
    await open(tester, 'a');
    for (final label in [l10nEn.close, l10nEn.storyMore, l10nEn.storyLike]) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width, greaterThanOrEqualTo(44), reason: label);
      expect(size.height, greaterThanOrEqualTo(44), reason: label);
    }
    await tester.enterText(find.byType(TextField), 'Nice');
    await tester.pump();
    final send = tester.getSize(find.bySemanticsLabel(l10nEn.storySend));
    expect(send.width, greaterThanOrEqualTo(44));
    expect(send.height, greaterThanOrEqualTo(44));
  });
}
