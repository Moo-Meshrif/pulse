import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/get_follow_status_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/domain/entity/comment_page_entity.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/comment_mentions/comment_mentions_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/comments/comments_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/post_actions/post_actions_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/post_page/post_page_cubit.dart';
import 'package:pulse/features/post/presentation/utils/comment_drafts.dart';
import 'package:pulse/features/post/presentation/utils/feed_post.dart';
import 'package:pulse/features/post/presentation/utils/post_page_args.dart';
import 'package:pulse/features/post/presentation/view/post_page_view.dart';
import 'package:pulse/features/profile/domain/entity/last_account_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/report_content_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_mute_use_case.dart';

import '../../../../helpers/pump_app.dart';
import '../../post_doubles.dart';
import '../../post_fixtures.dart';

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _GetFollow extends Mock implements GetFollowStatusUseCase {}

class _Toggle extends Mock implements ToggleFollowUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

class _Account extends Mock implements GetLastAccountUseCase {}

class _CommentsDatasource extends Mock implements CommentsDatasource {}

class _Report extends Mock implements ReportContentUseCase {}

class _Mute extends Mock implements SetMuteUseCase {}

void main() {
  late MockPostRepository posts;
  late List<BlocBase<Object?>> disposables;

  setUpAll(() {
    registerFallbackValue(CommentSort.relevant);
  });

  setUp(() {
    posts = MockPostRepository();
    disposables = [];
    when(() => posts.post(any())).thenAnswer((_) async => testPost('p1'));
    when(
      () => posts.comments(
        any(),
        sort: any(named: 'sort'),
        before: any(named: 'before'),
        userId: any(named: 'userId'),
        focusCommentId: any(named: 'focusCommentId'),
      ),
    ).thenAnswer(
      (_) async => CommentPageEntity(
        comments: [
          CommentEntity(
            id: 'c1',
            postId: 'p1',
            authorId: 'u2',
            username: 'sara.k',
            body: 'Lovely light',
            createdAt: DateTime.utc(2026, 10, 25),
            likeCount: 0,
            likedByMe: false,
            isPostAuthor: false,
            replyCount: 0,
          ),
        ],
      ),
    );
  });

  tearDown(() async {
    for (final item in disposables) {
      await item.close();
    }
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    FeedPost? passed,
    bool postFound = true,
  }) async {
    if (!postFound) when(() => posts.post(any())).thenAnswer((_) async => null);
    final user = _CurrentUser();
    when(() => posts.likedByPreview(any())).thenAnswer((_) async => null);
    when(user.call).thenReturn('me');
    final sign = _Sign();
    when(() => sign(any())).thenAnswer((_) async => {});
    final follow = _GetFollow();
    when(() => follow(any())).thenAnswer((_) async => FollowStatus.none);
    final account = _Account();
    when(account.call)
        .thenReturn(const LastAccountEntity(id: 'me', username: 'me.me'));
    final page = PostPageCubit(
      posts,
      sign,
      follow,
      _Toggle(),
      EventBus(),
      user,
      'p1',
      passed,
    );
    final actions = PostActionsCubit(
      posts,
      _Report(),
      _Mute(),
      _Toggle(),
      EventBus(),
    );
    final comments = CommentsCubit(
      posts,
      _CommentsDatasource(),
      CommentDrafts(),
      _Report(),
      account,
      'p1',
      null,
    );
    final mentions = CommentMentionsCubit(posts, 'p1');
    disposables.addAll([page, actions, comments, mentions]);
    unawaited(page.load());
    unawaited(comments.load());

    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: page),
          BlocProvider.value(value: actions),
          BlocProvider.value(value: comments),
          BlocProvider.value(value: mentions),
        ],
        child: PostPageView(
          args: PostPageArgs(postId: 'p1', post: passed),
        ),
      ),
      locale: locale,
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the post, its date, the comments and the field', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text(l10nEn.postPageTitle), findsOneWidget);
    expect(find.text(l10nEn.commentsTitle), findsOneWidget);
    expect(find.text('Lovely light'), findsOneWidget);
    expect(find.text(l10nEn.postFollow), findsOneWidget);
    expect(find.textContaining('October 14, 2026'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('lays out in $locale at 1.5x', (tester) async {
      await pump(tester, locale: locale, textScale: 1.5);
      expect(find.text('Lovely light'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a post nobody can see shows the unavailable page', (
    tester,
  ) async {
    await pump(tester, postFound: false);

    expect(find.text(l10nEn.postUnavailableTitle), findsOneWidget);
    expect(find.text(l10nEn.postBackToHome), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('a passed post shows before the fresh one arrives', (
    tester,
  ) async {
    await pump(
      tester,
      passed: FeedPost(entity: testPost('p1'), media: const []),
    );
    expect(find.text(l10nEn.postPageTitle), findsOneWidget);
    expect(find.text(l10nEn.postFollow), findsOneWidget);
  });
}
