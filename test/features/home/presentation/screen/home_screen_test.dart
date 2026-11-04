import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/core/widgets/notice/notice_card.dart';
import 'package:pulse/core/widgets/paged_scroll_view/refresh_icon.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/activity/domain/use_case/get_unread_activity_count_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/home/presentation/cubit/bell_dot/bell_dot_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/feed/feed_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/post_publish/post_line_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/post_publish/post_publish_cubit.dart';
import 'package:pulse/features/home/presentation/cubit/story_rail/story_rail_cubit.dart';
import 'package:pulse/features/home/presentation/screen/home_screen.dart';
import 'package:pulse/features/home/presentation/widgets/feed/feed_skeleton.dart';
import 'package:pulse/features/home/presentation/widgets/home_header.dart';
import 'package:pulse/features/home/presentation/widgets/story_rail/rail_skeleton.dart';
import 'package:pulse/features/home/presentation/widgets/story_rail/story_rail.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';
import 'package:pulse/features/post/domain/entity/comment_page_entity.dart';
import 'package:pulse/features/post/domain/entity/feed_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/feed_page_entity.dart';
import 'package:pulse/features/post/domain/entity/liked_by_preview_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';
import 'package:pulse/features/post/domain/use_case/get_home_feed_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/comment_mentions/comment_mentions_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/comments/comments_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/post_actions/post_actions_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/share_sheet/share_sheet_cubit.dart';
import 'package:pulse/features/post/presentation/utils/comment_drafts.dart';
import 'package:pulse/features/post/presentation/widgets/hidden_post_row.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_liked_by_row.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/profile/presentation/cubit/own_author/own_author_cubit.dart';
import 'package:pulse/features/profile/presentation/cubit/own_author/own_author_state.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_line.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/discard_publish_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_line_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_status_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/retry_publish_use_case.dart';

import '../../../../helpers/content_mocks.dart';
import '../../../../helpers/pump_app.dart';
import '../../../post/post_doubles.dart';
import '../../../post/post_fixtures.dart';
import '../../home_doubles.dart';

class _Status extends Fake implements GetPublishStatusUseCase {
  @override
  ContentPublishStatus call(ContentKind kind) => ContentPublishIdle(kind);
}

class _GetFeed extends Mock implements GetHomeFeedUseCase {}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Account extends Mock implements GetLastAccountUseCase {}

class _OwnAuthor extends MockCubit<OwnAuthorState> implements OwnAuthorCubit {}

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

class _RequestCount extends Mock implements GetUnreadActivityCountUseCase {}

class _GetRail extends Mock implements GetStoryRailUseCase {}

class _RetryUpload extends Mock implements RetryPublishUseCase {}

class _RetryPublish extends Mock implements RetryPublishUseCase {}

class _DiscardPublish extends Mock implements DiscardPublishUseCase {}

class _Follow extends Mock implements ToggleFollowUseCase {}

class _CommentsData extends Mock implements CommentsDatasource {}

class _ReportContent extends Mock implements ReportContentUseCase {}

/// The empty and failed pages float forever; with reduced motion they hold still, so the test can settle.
void reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
}

Finder _icon(String asset) =>
    find.byWidgetPredicate((w) => w is AppSvgIcon && w.asset == asset);

void main() {
  late _GetFeed getFeed;
  late MockGetLikedByPreviews likedBy;
  late _RequestCount requestCount;
  late _GetRail getRail;
  late MockPostRepository posts;
  late _RetryUpload retryUpload;
  late EventBus bus;
  late _RetryPublish retryPublish;
  late _DiscardPublish discardPublish;

  final now = DateTime(2026, 10, 14, 12);
  final cursor = FeedCursorEntity(createdAt: DateTime(2026, 10, 13), id: 'p3');

  PostEntity post(String id, {String caption = 'Hello'}) {
    final base = testPost(id);
    return PostEntity(
      id: id,
      authorId: base.authorId,
      username: base.username,
      fullName: 'Nour $id',
      caption: caption,
      likeCount: base.likeCount,
      commentCount: base.commentCount,
      commentsEnabled: true,
      visibility: base.visibility,
      createdAt: now.subtract(const Duration(hours: 2)),
      likedByMe: false,
      savedByMe: false,
      media: const [],
    );
  }

  late _OwnAuthor ownAuthor;

  setUpAll(() {
    registerFallbackValue(cursor);
    registerFallbackValue(CommentSort.relevant);
    registerContentFallbacks();
  });

  setUp(() async {
    await getIt.reset();
    ownAuthor = _OwnAuthor();
    when(() => ownAuthor.state).thenReturn(const OwnAuthorState());
    getFeed = _GetFeed();
    likedBy = quietLikedBy();
    requestCount = _RequestCount();
    posts = MockPostRepository();
    getRail = _GetRail();
    when(getRail.call).thenAnswer((_) async => []);
    retryUpload = _RetryUpload();
    bus = EventBus();
    retryPublish = _RetryPublish();
    discardPublish = _DiscardPublish();
    final sign = _Sign();
    final currentUser = _CurrentUser();
    when(currentUser.call).thenReturn('me');
    when(() => sign(any())).thenAnswer((_) async => {});
    when(requestCount.call).thenAnswer((_) async => 0);
    when(
      () => getFeed(cursor: null),
    ).thenAnswer((_) async => FeedPageEntity(posts: [post('p1'), post('p2')]));
    when(() => posts.setLike(any(), liked: any(named: 'liked')))
        .thenAnswer((_) async => 11);
    when(() => posts.hidePost(any(), hidden: any(named: 'hidden')))
        .thenAnswer((_) async {});
    getIt
      ..registerSingleton<ConnectivityService>(FakeConnectivity())
      ..registerFactory(() {
        final changes = quietChangeDoubles();
        return FeedCubit(
          getFeed,
          sign,
          bus,
          currentUser,
          changes.check,
          changes.postsByIds,
          changes.counts,
          changes.startLive,
          changes.stopLive,
          MockSaveHomeFeed(),
          likedBy,
        );
      })
      ..registerFactory(
        () => PostActionsCubit(
          posts,
          MockReportContent(),
          MockSetMute(),
          _Follow(),
          EventBus(),
        ),
      )
      ..registerFactory(
        () => PostPublishCubit(
          bus,
          GetPublishStatusUseCase(
            ContentPublishRepositoryImpl(
              bus,
              FakeContentDiscards(),
              FakeConnectivity(),
            ),
          ),
          retryPublish,
          discardPublish,
          okResumeContent(),
          okResumeSharedPosts(),
          currentUser,
          hasOpenPostDraft(),
        ),
      )
      ..registerFactory(
        () => PostLineCubit(
          bus,
          GetPublishLineUseCase(
            ContentPublishRepositoryImpl(
              bus,
              FakeContentDiscards(),
              FakeConnectivity(),
            ),
          ),
        ),
      )
      ..registerFactory(() => BellDotCubit(requestCount, bus))
      ..registerFactory(
        () => StoryRailCubit(
          getRail,
          bus,
          GetPublishStatusUseCase(
            ContentPublishRepositoryImpl(
              bus,
              FakeContentDiscards(),
              FakeConnectivity(),
            ),
          ),
          retryUpload,
          FakeLastAccount(),
          quietChangeDoubles().check,
        ),
      )
      ..registerFactoryParam<ShareSheetCubit, String, void>((postId, _) {
        final privacy = _Privacy();
        when(privacy.call).thenAnswer(
          (_) async => const PrivacyEntity(
            isPrivate: false,
            defaultVisibility: ContentAudience.public,
          ),
        );
        final account = _Account();
        when(account.call).thenReturn(null);
        return ShareSheetCubit(posts, privacy, _Status(), account, postId);
      })
      ..registerFactoryParam<CommentsCubit, String, String?>((postId, focus) {
        when(
          () => posts.comments(
            any(),
            sort: any(named: 'sort'),
            before: any(named: 'before'),
            focusCommentId: any(named: 'focusCommentId'),
          ),
        ).thenAnswer((_) async => const CommentPageEntity(comments: []));
        return CommentsCubit(
          posts,
          _CommentsData(),
          CommentDrafts(),
          _ReportContent(),
          FakeLastAccount(),
          postId,
          focus,
        );
      })
      ..registerFactoryParam<CommentMentionsCubit, String, void>(
        (postId, _) => CommentMentionsCubit(posts, postId),
      );
    addTearDown(getIt.reset);
  });

  /// The control shell provides this cubit above Home; here it is empty (no profile read).
  Widget withOwnAuthor(Widget child) =>
      BlocProvider<OwnAuthorCubit>.value(value: ownAuthor, child: child);

  Future<void> show(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool settle = true,
  }) => withClock(
    Clock.fixed(now),
    () => tester.pumpApp(
      withOwnAuthor(const HomeScreen()),
      locale: locale,
      settle: settle,
      onGenerateRoute: AppRouter.onGenerateRoute,
    ),
  );

  group('content', () {
    testView('shows the header and a card per post', (tester) async {
      await show(tester);
      expect(find.text('pulse'), findsOneWidget);
      expect(find.byType(PostCard), findsNWidgets(2));
      expect(find.text('Nour p1'), findsOneWidget);
      expect(find.text('Nour p2'), findsOneWidget);
      expect(find.byKey(bellDotKey), findsNothing);
    });

    testView('the bell shows its dot while anything waits in Activity', (
      tester,
    ) async {
      when(requestCount.call).thenAnswer((_) async => 3);
      await show(tester);
      expect(find.byKey(bellDotKey), findsOneWidget);
    });

    testView('Search and the bell open their pages', (tester) async {
      await show(tester);
      await tester.tap(find.bySemanticsLabel(l10nEn.homeSearch));
      await tester.pumpAndSettle();
      expect(find.text(AppRoutes.search), findsOneWidget);

      Navigator.of(tester.element(find.text(AppRoutes.search))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(l10nEn.homeActivity));
      await tester.pumpAndSettle();
      expect(find.text(AppRoutes.activity), findsOneWidget);
    });

    testView('the comment button opens the comments sheet', (tester) async {
      await show(tester);
      await tester.tap(_icon(AppAssets.comment).first);
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.commentsTitle), findsOneWidget);
      expect(find.text(AppRoutes.commentsOf('p1')), findsNothing);
    });

    testView('Share opens the share sheet of the post', (tester) async {
      await show(tester);
      await tester.tap(_icon(AppAssets.share).first);
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.shareTitle), findsOneWidget);
      expect(find.text(l10nEn.shareNow), findsOneWidget);
      expect(find.text(l10nEn.comingSoon), findsNothing);
    });
  });

  group('story posting', () {
    testView('a failed post says so and Retry sends it again', (tester) async {
      await show(tester);
      bus.fire(
        const ContentPublishFailed(ContentKind.story, failure: ServerFailure()),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // the notice slides in
      expect(find.text(l10nEn.storyPostFailed), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NoticeCard),
          matching: find.text(l10nEn.retry),
        ),
      );
      verify(() => retryUpload(ContentKind.story)).called(1);
    });
  });

  group('story posting offline', () {
    testView('a lost connection says it posts by itself, with no Retry', (
      tester,
    ) async {
      await show(tester);
      bus.fire(
        const ContentPublishFailed(
          ContentKind.story,
          failure: NetworkFailure(),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(l10nEn.storyPostOffline), findsOneWidget);
      expect(find.text(l10nEn.storyPostFailed), findsNothing);
    });
  });

  group('post publishing', () {
    void line(List<ContentLineItem> items) =>
        bus.fire(ContentPublishLine(ContentKind.post, items));

    ContentLineItem item(
      ContentLineState state, {
      String id = 'p1',
      double progress = 0,
      Failure? failure,
    }) => ContentLineItem(
      id: id,
      state: state,
      progress: progress,
      failure: failure,
    );

    testView('several posts are one card with the line, opened to a row each', (
      tester,
    ) async {
      await show(tester);
      line([
        item(ContentLineState.done, id: 'a', progress: 1),
        item(ContentLineState.sending, id: 'b', progress: 0.5),
        item(ContentLineState.waiting, id: 'c'),
      ]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishingMany(3)), findsOneWidget);
      expect(find.text(l10nEn.postPublishProgress(1, 3, 50)), findsOneWidget);
      expect(find.text(l10nEn.postPublishRowPosted), findsNothing);

      await tester.tap(find.byTooltip(l10nEn.postPublishShowAll));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.postPublishRowPosted), findsOneWidget);
      expect(find.text(l10nEn.postPublishRowWaiting), findsOneWidget);
    });

    testView('with one failed post, Retry and Discard name that post', (
      tester,
    ) async {
      await show(tester);
      line([
        item(ContentLineState.done, id: 'a', progress: 1),
        item(ContentLineState.failed, id: 'b', failure: const ServerFailure()),
      ]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishSomePosted(1, 2)), findsOneWidget);

      await tester.tap(find.text(l10nEn.retry));
      verify(() => retryPublish(ContentKind.post, id: 'b')).called(1);
    });

    testView('posts waiting for the connection say so', (tester) async {
      await show(tester);
      line([
        item(ContentLineState.failed, id: 'a', failure: const NetworkFailure()),
        item(ContentLineState.failed, id: 'b', failure: const NetworkFailure()),
      ]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishOffline), findsOneWidget);
    });

    testView('a post going out shows the banner, done shows the notice', (
      tester,
    ) async {
      await show(tester);
      line([item(ContentLineState.sending)]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishing), findsOneWidget);

      bus
        ..fire(const ContentPublishDone(ContentKind.post))
        ..fire(const ContentPublishLine(ContentKind.post, []));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // the notice slides in
      expect(find.text(l10nEn.postPublishing), findsNothing);
      expect(find.text(l10nEn.newPostShared), findsOneWidget);
    });

    testView('the banner line moves, then shows how much is sent', (
      tester,
    ) async {
      await show(tester);
      LinearProgressIndicator bar() => tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );

      line([item(ContentLineState.sending)]);
      await tester.pump();
      await tester.pump();
      expect(bar().value, isNull);

      line([item(ContentLineState.sending, progress: 0.4)]);
      await tester.pump();
      expect(bar().value, 0.4);
    });

    testView('a story going out does not show the post banner', (tester) async {
      await show(tester);
      bus.fire(const ContentPublishing(ContentKind.story, progress: 0.5));
      await tester.pump();
      await tester.pump();
      // The rail says "Posting…" too; the banner is the one with the line.
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testView('an empty feed shows the banner too', (tester) async {
      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => const FeedPageEntity(posts: []));
      await show(tester, settle: false);
      await tester.pump();
      await tester.pump();
      line([item(ContentLineState.sending)]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.homeEmptyTitle), findsOneWidget);
      expect(find.text(l10nEn.postPublishing), findsOneWidget);
    });

    testView('a failed post offers Retry and Discard', (tester) async {
      await show(tester);
      line([item(ContentLineState.failed, failure: const ServerFailure())]);
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishFailed), findsOneWidget);

      await tester.tap(find.text(l10nEn.retry));
      verify(() => retryPublish(ContentKind.post, id: 'p1')).called(1);
      await tester.tap(find.text(l10nEn.postPublishDiscard));
      verify(() => discardPublish(ContentKind.post, id: 'p1')).called(1);
    });
  });

  group('post discarding', () {
    testView('a post the server rejected offers Discard only', (tester) async {
      await show(tester);
      bus.fire(
        const ContentPublishLine(ContentKind.post, [
          ContentLineItem(
            id: 'p1',
            state: ContentLineState.failed,
            failure: RejectedFailure(),
          ),
        ]),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text(l10nEn.postPublishFailed), findsOneWidget);
      expect(find.text(l10nEn.postPublishDiscard), findsOneWidget);
      expect(find.text(l10nEn.retry), findsNothing);
    });

    testView('a discard that came too late says so and reloads the feed', (
      tester,
    ) async {
      await show(tester);
      clearInteractions(getFeed);
      bus
        ..fire(const ContentDiscardRefused(ContentKind.post))
        ..fire(const ContentPublishIdle(ContentKind.post));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // the notice slides in
      expect(find.text(l10nEn.postDiscardTooLate), findsOneWidget);
      verify(() => getFeed(cursor: null)).called(1);
    });
  });

  group('actions', () {
    testView('Like shows at once and sends the like', (tester) async {
      await show(tester);
      await tester.tap(_icon(AppAssets.heart).first);
      await tester.pumpAndSettle();
      expect(_icon(AppAssets.heartFilled), findsOneWidget);
      verify(() => posts.setLike('p1', liked: true)).called(1);
    });

    testView('a like that fails is taken back with a notice', (tester) async {
      when(() => posts.setLike(any(), liked: any(named: 'liked')))
          .thenAnswer((_) async => throw const NetworkFailure());
      await show(tester);
      await tester.tap(_icon(AppAssets.heart).first);
      await tester.pump();
      await tester.pump();
      expect(_icon(AppAssets.heartFilled), findsNothing);
      expect(find.byType(NoticeCard), findsOneWidget);
    });

    testView(
      'Not interested turns the card into the hidden row, Undo brings it back',
      (tester) async {
        await show(tester);
        await tester.tap(_icon(AppAssets.moreHorizontal).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.postNotInterested));
        await tester.pumpAndSettle();
        expect(find.byType(HiddenPostRow), findsOneWidget);
        expect(find.byType(PostCard), findsOneWidget);

        await tester.tap(find.text(l10nEn.undo));
        await tester.pumpAndSettle();
        expect(find.byType(HiddenPostRow), findsNothing);
        expect(find.byType(PostCard), findsNWidgets(2));
        verify(() => posts.hidePost('p1', hidden: false)).called(1);
      },
    );
  });

  group('paging', () {
    testView('asks for the next page near the end, once', (tester) async {
      when(() => getFeed(cursor: null)).thenAnswer(
        (_) async => FeedPageEntity(
          posts: [post('p1'), post('p2'), post('p3')],
          nextCursor: cursor,
        ),
      );
      when(() => getFeed(cursor: cursor))
          .thenAnswer((_) async => FeedPageEntity(posts: [post('p4')]));
      await show(tester);
      verify(() => getFeed(cursor: cursor)).called(1);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      verifyNever(() => getFeed(cursor: cursor)); // not asked again
      expect(find.text('Nour p4', skipOffstage: false), findsOneWidget);
    });

    testView('pull to refresh loads the first page again', (tester) async {
      await show(tester);
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => getFeed(cursor: null)).called(2);
      verify(requestCount.call).called(2);
    });

    testView('a refresh that fails keeps the posts and says so', (
      tester,
    ) async {
      await show(tester);
      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => throw const NetworkFailure());
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.byType(PostCard), findsNWidgets(2));
      expect(find.byType(NoticeCard), findsOneWidget);
    });

    testView('a refresh forgets what was done to the old posts', (
      tester,
    ) async {
      await show(tester);
      await tester.tap(_icon(AppAssets.heart).first);
      await tester.pumpAndSettle();
      expect(_icon(AppAssets.heartFilled), findsOneWidget);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
      expect(_icon(AppAssets.heartFilled), findsNothing);
    });
  });

  group('first load', () {
    testView('shows the skeleton under the real header, then the posts', (
      tester,
    ) async {
      final page = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer((_) => page.future);
      await show(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FeedSkeleton), findsOneWidget);
      expect(find.byType(PostCard), findsNothing);
      expect(find.byType(StoryRail), findsOneWidget);
      expect(find.byType(RailSkeletonZone), findsNothing);
      expect(find.text('pulse'), findsOneWidget);

      page.complete(FeedPageEntity(posts: [post('p1')]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(FeedSkeleton), findsNothing);
      expect(find.byType(PostCard), findsOneWidget);
      expect(find.byType(StoryRail), findsOneWidget);
    });

    testView('the rail shows its own skeleton until it has answered', (
      tester,
    ) async {
      final rail = Completer<List<StoryRailItemEntity>>();
      when(getRail.call).thenAnswer((_) => rail.future);
      final page = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer((_) => page.future);
      await show(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RailSkeletonZone), findsOneWidget);
      expect(find.byType(FeedSkeleton), findsOneWidget);

      rail.complete([]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(RailSkeletonZone), findsNothing);
      expect(find.byType(FeedSkeleton), findsOneWidget);
    });

    testView('stands still when the system reduces motion', (tester) async {
      reduceMotion(tester);
      final page = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer((_) => page.future);
      await show(tester, settle: false);
      // Settles only when nothing animates.
      await tester.pumpAndSettle();
      expect(find.byType(FeedSkeleton), findsOneWidget);
    });

    testView('a failure shows the page with Try again, which loads again', (
      tester,
    ) async {
      reduceMotion(tester);
      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => throw const ServerFailure());
      await show(tester);
      expect(find.text(l10nEn.failedPageTitle), findsOneWidget);
      expect(find.text('pulse'), findsOneWidget);

      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => FeedPageEntity(posts: [post('p1')]));
      await tester.tap(find.text(l10nEn.tryAgain));
      await tester.pumpAndSettle();
      expect(find.byType(PostCard), findsOneWidget);
      expect(find.text(l10nEn.failedPageTitle), findsNothing);
    });

    testView('no connection says so', (tester) async {
      reduceMotion(tester);
      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => throw const NetworkFailure());
      await show(tester);
      expect(find.text(l10nEn.offlinePageTitle), findsOneWidget);
    });
  });

  group('empty feed', () {
    setUp(() {
      when(() => getFeed(cursor: null))
          .thenAnswer((_) async => const FeedPageEntity(posts: []));
    });

    testView('says the feed is quiet, with the rail above', (tester) async {
      reduceMotion(tester);
      await show(tester);
      expect(find.text(l10nEn.homeEmptyTitle), findsOneWidget);
      expect(find.text(l10nEn.homeEmptyBody), findsOneWidget);
      expect(find.text(l10nEn.storyYourStory), findsOneWidget);
      expect(find.byType(PostCard), findsNothing);
    });

    testView('the page is centered on the whole screen, not under the rail', (
      tester,
    ) async {
      reduceMotion(tester);
      await show(tester);
      final top = tester.getTopLeft(find.text(l10nEn.homeEmptyTitle)).dy;
      final button = tester.getBottomLeft(find.text(l10nEn.homeFindPeople)).dy;
      final center = (top + button) / 2;
      // The safe area of the test frame runs from 47 to 844 - 34; the rail ends near 150.
      expect(center, closeTo((47 + 810) / 2, 60));
    });

    testView('Find people opens search', (tester) async {
      reduceMotion(tester);
      await show(tester);
      await tester.tap(find.text(l10nEn.homeFindPeople));
      await tester.pumpAndSettle();
      expect(find.text(AppRoutes.search), findsOneWidget);
    });

    testView('Arabic copy', (tester) async {
      reduceMotion(tester);
      await show(tester, locale: const Locale('ar'));
      expect(find.text(l10nAr.homeEmptyTitle), findsOneWidget);
      expect(find.text(l10nAr.homeFindPeople), findsOneWidget);
    });
  });

  group('end of the feed', () {
    testView('the last page ends with "all caught up"', (tester) async {
      await show(tester);
      expect(
        find.text(l10nEn.homeCaughtUp, skipOffstage: false),
        findsOneWidget,
      );
    });

    testView('shows the loader while the next page comes', (tester) async {
      final next = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer(
        (_) async => FeedPageEntity(
          posts: [post('p1'), post('p2'), post('p3')],
          nextCursor: cursor,
        ),
      );
      when(() => getFeed(cursor: cursor)).thenAnswer((_) => next.future);
      await show(tester, settle: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pump();
      expect(
        find.byWidgetPredicate(
          (w) => w is FeedMoreSkeleton,
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text(l10nEn.homeCaughtUp, skipOffstage: false), findsNothing);
    });

    testView('a failed next page can be retried', (tester) async {
      when(() => getFeed(cursor: null)).thenAnswer(
        (_) async => FeedPageEntity(
          posts: [post('p1'), post('p2'), post('p3')],
          nextCursor: cursor,
        ),
      );
      when(() => getFeed(cursor: cursor))
          .thenAnswer((_) async => throw const NetworkFailure());
      await show(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.homeLoadMoreError), findsOneWidget);

      when(() => getFeed(cursor: cursor))
          .thenAnswer((_) async => FeedPageEntity(posts: [post('p4')]));
      await tester.tap(find.text(l10nEn.homeLoadMoreError));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.homeLoadMoreError), findsNothing);
      expect(find.text('Nour p4', skipOffstage: false), findsOneWidget);
    });
  });

  group('refresh requests', () {
    testView('a request from the shell or a shared post loads the feed again', (
      tester,
    ) async {
      await show(tester);
      when(() => getFeed(cursor: null)).thenAnswer(
        (_) async => FeedPageEntity(posts: [post('p9'), post('p1')]),
      );
      bus.fire(const FeedRefreshRequested());
      await tester.pumpAndSettle();
      expect(find.text('Nour p9'), findsOneWidget);
      verify(requestCount.call).called(2);
    });
  });

  group('refreshing', () {
    testView('shows the nav icon under the header while the posts stay', (
      tester,
    ) async {
      await show(tester);
      final again = Completer<FeedPageEntity>();
      when(() => getFeed(cursor: null)).thenAnswer((_) => again.future);
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RefreshIcon), findsOneWidget);
      expect(find.byType(PostCard), findsNWidgets(2));

      again.complete(FeedPageEntity(posts: [post('p9')]));
      await tester.pumpAndSettle();
      expect(find.byType(RefreshIcon), findsNothing);
      expect(find.text('Nour p9'), findsOneWidget);
    });
  });

  group('Arabic', () {
    testView('the header mirrors and the cards show', (tester) async {
      await show(tester, locale: const Locale('ar'));
      final logo = tester.getTopLeft(find.byType(LogoTile));
      final search = tester.getTopLeft(
        find.bySemanticsLabel(l10nAr.homeSearch),
      );
      expect(logo.dx, greaterThan(search.dx));
      expect(find.byType(PostCard), findsNWidgets(2));
    });

    testWidgets('survives 1.5x text on a narrow phone', (tester) async {
      setUpView(tester, size: const Size(320, 640), textScale: 1.5);
      await show(tester, locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
      expect(find.byType(PostCard), findsWidgets);
    });
  });
  testWidgets('the skeleton and the empty page survive 1.5x text in Arabic', (
    tester,
  ) async {
    setUpView(tester, size: const Size(320, 640), textScale: 1.5);
    reduceMotion(tester);
    final page = Completer<FeedPageEntity>();
    when(() => getFeed(cursor: null)).thenAnswer((_) => page.future);
    await show(tester, locale: const Locale('ar'), settle: false);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(FeedSkeleton), findsOneWidget);

    page.complete(const FeedPageEntity(posts: []));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(l10nAr.homeEmptyTitle), findsOneWidget);
  });

  group('polish', () {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      testWidgets(
        '${locale.languageCode}: 320 dp at 2x text does not overflow',
        (tester) async {
          setUpView(tester, size: const Size(320, 640), textScale: 2);
          reduceMotion(tester);
          when(() => getFeed(cursor: null)).thenAnswer(
            (_) async => FeedPageEntity(
              posts: [
                post(
                  'p1',
                  caption:
                      'A caption that is long enough to wrap onto '
                          'several lines at a large text size ' *
                      3,
                ),
                post('p2'),
              ],
            ),
          );
          await show(tester, locale: locale);
          expect(tester.takeException(), isNull);
          expect(find.byType(PostCard), findsWidgets);
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -3000),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }

    testView(
      'the "Liked by" line shows under a post that has a line, in EN and AR',
      (tester) async {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          when(() => likedBy(any())).thenAnswer(
            (_) async => {
              'p1': const LikedByPreviewEntity(
                firstName: 'salma.ash',
                others: 3,
                avatars: [],
              ),
            },
          );
          await show(tester, locale: locale);
          final l10n = locale.languageCode == 'ar' ? l10nAr : l10nEn;
          expect(
            find.bySemanticsLabel(
              l10n.postLikedBy('salma.ash', l10n.postLikedByOthers(3)),
            ),
            findsOneWidget,
          );
        }
      },
    );

    testView('no "Liked by" line without a line from the server', (
      tester,
    ) async {
      await show(tester);
      expect(find.text(l10nEn.postLikesOpen), findsNothing);
      expect(find.byType(LikedByRow), findsNothing);
    });

    testWidgets('a wide window keeps the feed at the content width, centered', (
      tester,
    ) async {
      setUpView(tester, size: const Size(1200, 900));
      await show(tester);
      final card = tester.getRect(find.byType(PostCard).first);
      expect(card.width, lessThan(AppBreakpoints.maxContentWidth));
      expect(card.center.dx, closeTo(600, 1));
    });

    testView('the last card scrolls clear of the nav bar', (tester) async {
      const nav = 138.0;
      await withClock(
        Clock.fixed(now),
        () => tester.pumpApp(
          withOwnAuthor(const NavClearance(bottom: nav, child: HomeScreen())),
          onGenerateRoute: AppRouter.onGenerateRoute,
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();
      final last = tester.getRect(find.byType(PostCard).last);
      expect(last.bottom, lessThanOrEqualTo(844 - nav));
    });

    testView('the header buttons are at least 44 square and labelled', (
      tester,
    ) async {
      await show(tester);
      for (final label in [l10nEn.homeSearch, l10nEn.homeActivity]) {
        final size = tester.getSize(find.bySemanticsLabel(label));
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
      }
    });

    testView('the action bar mirrors in Arabic: Save at the left', (
      tester,
    ) async {
      await show(tester, locale: const Locale('ar'));
      final save = tester.getCenter(_icon(AppAssets.bookmark).first);
      final like = tester.getCenter(_icon(AppAssets.heart).first);
      expect(save.dx, lessThan(like.dx));
    });
  });
}
