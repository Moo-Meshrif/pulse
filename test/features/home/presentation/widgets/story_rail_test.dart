import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/home/presentation/cubit/story_rail_cubit.dart';
import 'package:pulse/features/home/presentation/widgets/story_rail/story_item.dart';
import 'package:pulse/features/home/presentation/widgets/story_rail/story_rail.dart';
import 'package:pulse/features/post/domain/use_case/watch_feed_refresh_requests_use_case.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/entity/story_upload_status.dart';
import 'package:pulse/features/story/domain/entity/story_viewer_args.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/domain/use_case/retry_story_upload_use_case.dart';
import 'package:pulse/features/story/domain/use_case/watch_story_rail_changes_use_case.dart';
import 'package:pulse/features/story/domain/use_case/watch_story_upload_use_case.dart';

import '../../../../helpers/pump_app.dart';

class _GetRail extends Mock implements GetStoryRailUseCase {}

class _Changes extends Mock implements WatchStoryRailChangesUseCase {}

class _Upload extends Mock implements WatchStoryUploadUseCase {}

class _Retry extends Mock implements RetryStoryUploadUseCase {}

class _Refresh extends Mock implements WatchFeedRefreshRequestsUseCase {}

StoryRailItemEntity person(
  String id, {
  bool isMe = false,
  bool allSeen = false,
  String? username,
}) => StoryRailItemEntity(
  authorId: id,
  username: username ?? 'user.$id',
  isMe: isMe,
  storyCount: 2,
  allSeen: allSeen,
);

void main() {
  late StoryRailCubit cubit;
  late _GetRail getRail;
  late _Retry retry;
  late StreamController<StoryUploadStatus> uploadStatus;
  late List<RouteSettings> pushed;

  setUp(() {
    getRail = _GetRail();
    retry = _Retry();
    uploadStatus = StreamController<StoryUploadStatus>.broadcast();
    pushed = [];
    final changes = _Changes();
    final upload = _Upload();
    when(getRail.call).thenAnswer((_) async => []);
    when(changes.call).thenAnswer((_) => const Stream<void>.empty());
    when(upload.call).thenAnswer((_) => uploadStatus.stream);
    final refresh = _Refresh();
    when(refresh.call).thenAnswer((_) => const Stream<void>.empty());
    cubit = StoryRailCubit(getRail, changes, upload, retry, refresh);
    addTearDown(cubit.close);
    addTearDown(uploadStatus.close);
  });

  Future<void> show(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) async {
    await cubit.start();
    await tester.pumpApp(
      Scaffold(
        body: BlocProvider.value(value: cubit, child: const StoryRail()),
      ),
      locale: locale,
      onGenerateRoute: (settings) {
        pushed.add(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => Scaffold(body: Text(settings.name!)),
        );
      },
    );
  }

  group('the rail', () {
    testView('shows only "Your story" without anyone, and no title', (
      tester,
    ) async {
      await show(tester);
      expect(find.text('Stories'), findsNothing);
      expect(find.text(l10nEn.storyYourStory), findsOneWidget);
      expect(find.byType(StoryItem), findsNothing);
    });

    testView('your own story takes the "Your story" tile, not a second one', (
      tester,
    ) async {
      when(getRail.call).thenAnswer(
        (_) async => [person('me', isMe: true, username: 'me.me'), person('a')],
      );
      await show(tester);
      final yourStory = tester.getTopLeft(find.text(l10nEn.storyYourStory));
      final other = tester.getTopLeft(find.text('user.a'));
      expect(find.text('me.me'), findsNothing);
      expect(yourStory.dx, lessThan(other.dx));
    });

    testView('has no scrollbar', (tester) async {
      await show(tester);
      expect(find.byType(Scrollbar), findsNothing);
    });

    testView('a long username stays on one line', (tester) async {
      when(getRail.call).thenAnswer(
        (_) async => [person('a', username: 'a.very.long.user.name.indeed')],
      );
      await show(tester);
      final text = tester.widget<AppText>(
        find.byWidgetPredicate(
          (w) => w is AppText && w.text == 'a.very.long.user.name.indeed',
        ),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('taps', () {
    testView('"Your story" opens the camera', (tester) async {
      await show(tester);
      await tester.tap(find.text(l10nEn.storyYourStory));
      await tester.pumpAndSettle();
      expect(pushed.last.name, AppRoutes.createStory);
    });

    testView('a person opens their stories, handing over who and where', (
      tester,
    ) async {
      when(getRail.call).thenAnswer((_) async => [person('a')]);
      await show(tester);
      await tester.tap(find.text('user.a'));
      await tester.pumpAndSettle();
      expect(pushed.last.name, AppRoutes.storyOf('a'));
      final args = pushed.last.arguments! as StoryViewerArgs;
      expect(args.person?.authorId, 'a');
      expect(args.origin, isNotNull);
    });

    testView('your own story opens your stories', (tester) async {
      when(getRail.call).thenAnswer((_) async => [person('me', isMe: true)]);
      await show(tester);
      await tester.tap(find.text(l10nEn.storyYourStory));
      await tester.pumpAndSettle();
      expect(pushed.last.name, AppRoutes.storyOf('me'));
    });
  });

  group('posting', () {
    testView('shows progress, then goes back to "Your story"', (tester) async {
      await show(tester);
      uploadStatus.add(const StoryUploading(0.5));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.storyPosting), findsOneWidget);
      expect(find.text(l10nEn.storyYourStory), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is AppSvgIcon && w.asset == AppAssets.plus,
        ),
        findsNothing,
      );

      await tester.tap(find.text(l10nEn.storyPosting));
      await tester.pump();
      expect(pushed, isEmpty);

      uploadStatus.add(const StoryUploadDone());
      uploadStatus.add(const StoryUploadIdle());
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.storyYourStory), findsOneWidget);
    });

    testView('a failed post says Retry and sends it again on tap', (
      tester,
    ) async {
      await show(tester);
      uploadStatus.add(const StoryUploadFailed(NetworkFailure()));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.retry), findsOneWidget);
      await tester.tap(find.text(l10nEn.retry));
      verify(retry.call).called(1);
    });
  });

  testView('Arabic: "Your story" is at the start (right)', (tester) async {
    when(getRail.call).thenAnswer((_) async => [person('a')]);
    await show(tester, locale: const Locale('ar'));
    final yourStory = tester.getTopLeft(find.text(l10nAr.storyYourStory));
    final other = tester.getTopLeft(find.text('user.a'));
    expect(yourStory.dx, greaterThan(other.dx));
  });

  testWidgets('1.5x text on a narrow phone does not overflow', (tester) async {
    setUpView(tester, size: const Size(320, 640), textScale: 1.5);
    when(getRail.call).thenAnswer((_) async => [person('a'), person('b')]);
    await show(tester, locale: const Locale('ar'));
    expect(tester.takeException(), isNull);
  });
}
