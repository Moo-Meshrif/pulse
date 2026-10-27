import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/get_follow_status_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/post_page/post_page_cubit.dart';
import 'package:pulse/features/post/presentation/utils/feed_post.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_follow_chip.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_notification_chip.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_page_date.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_page_top_bar.dart';
import 'package:pulse/features/post/presentation/widgets/post_page/post_page_unavailable.dart';
import 'package:pulse/features/profile/domain/use_case/get_current_user_id_use_case.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../post_doubles.dart';
import '../../../post_fixtures.dart';

class _Sign extends Mock implements SignPostMediaUrlsUseCase {}

class _GetFollow extends Mock implements GetFollowStatusUseCase {}

class _Toggle extends Mock implements ToggleFollowUseCase {}

class _CurrentUser extends Mock implements GetCurrentUserIdUseCase {}

void main() {
  const locales = [Locale('en'), Locale('ar')];

  group('PostFollowChip', () {
    late _GetFollow getFollow;
    late _Toggle toggle;

    PostPageCubit cubit({String authorId = 'author'}) {
      final user = _CurrentUser();
      final posts = MockPostRepository();
      when(() => posts.likedByPreview(any())).thenAnswer((_) async => null);
      when(user.call).thenReturn('me');
      final sign = _Sign();
      when(() => sign(any())).thenAnswer((_) async => {});
      return PostPageCubit(
        posts,
        sign,
        getFollow,
        toggle,
        EventBus(),
        user,
        'p1',
        FeedPost(
          entity: testPost('p1', authorId: authorId),
          media: const [],
        ),
      );
    }

    setUp(() {
      getFollow = _GetFollow();
      toggle = _Toggle();
      when(() => getFollow(any())).thenAnswer((_) async => FollowStatus.none);
    });

    Future<PostPageCubit> pump(
      WidgetTester tester, {
      String authorId = 'author',
      Locale locale = const Locale('en'),
      double textScale = 1,
    }) async {
      final page = cubit(authorId: authorId);
      addTearDown(page.close);
      setUpView(tester, textScale: textScale);
      await tester.pumpApp(
        Scaffold(
          body: Row(
            children: [
              BlocProvider.value(value: page, child: const PostFollowChip()),
            ],
          ),
        ),
        locale: locale,
      );
      return page;
    }

    testWidgets('your own post has no chip', (tester) async {
      await pump(tester, authorId: 'me');
      expect(find.text(l10nEn.postFollow), findsNothing);
      expect(find.text(l10nEn.postFollowing), findsNothing);
    });

    testWidgets('Follow turns into Following and back on taps', (tester) async {
      when(() => toggle('author', follow: true))
          .thenAnswer((_) async => FollowStatus.accepted);
      when(() => toggle('author', follow: false))
          .thenAnswer((_) async => FollowStatus.none);
      await pump(tester);
      expect(find.text(l10nEn.postFollow), findsOneWidget);

      await tester.tap(find.text(l10nEn.postFollow));
      await tester.pump();
      expect(find.text(l10nEn.postFollowing), findsOneWidget);

      await tester.tap(find.text(l10nEn.postFollowing));
      await tester.pump();
      expect(find.text(l10nEn.postFollow), findsOneWidget);
      verify(() => toggle('author', follow: false)).called(1);
    });

    for (final locale in locales) {
      testWidgets('draws in $locale at 1.5x without overflow', (tester) async {
        await pump(tester, locale: locale, textScale: 1.5);
        final l10n = locale.languageCode == 'ar' ? l10nAr : l10nEn;
        expect(find.text(l10n.postFollow), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('PostPageUnavailable', () {
    for (final locale in locales) {
      testWidgets('says the post is not available in $locale at 1.5x', (
        tester,
      ) async {
        setUpView(tester, textScale: 1.5);
        await tester.pumpApp(
          const Scaffold(body: PostPageUnavailable()),
          locale: locale,
        );
        final l10n = locale.languageCode == 'ar' ? l10nAr : l10nEn;
        expect(find.text(l10n.postUnavailableTitle), findsOneWidget);
        expect(find.text(l10n.postPageUnavailableBody), findsOneWidget);
        expect(find.text(l10n.postBackToHome), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('PostPageTopBar', () {
    Future<void> pump(WidgetTester tester, {required bool showAuthor}) async {
      setUpView(tester);
      await tester.pumpApp(
        Scaffold(
          body: PostPageTopBar(
            onBack: () {},
            onOptions: () {},
            showAuthor: showAuthor,
            authorId: 'a1',
            authorName: 'Nour Adel',
          ),
        ),
      );
    }

    testWidgets('shows the title, then the author once scrolled', (
      tester,
    ) async {
      await pump(tester, showAuthor: false);
      expect(find.text(l10nEn.postPageTitle), findsOneWidget);
      expect(find.text('Nour Adel'), findsNothing);

      await pump(tester, showAuthor: true);
      await tester.pump();
      expect(find.text(l10nEn.postPageTitle), findsNothing);
      expect(find.text('Nour Adel'), findsOneWidget);
    });

    testWidgets('without options only back stays', (tester) async {
      setUpView(tester);
      await tester.pumpApp(
        Scaffold(
          body: PostPageTopBar(
            onBack: () {},
            onOptions: null,
            showAuthor: false,
          ),
        ),
      );
      expect(find.bySemanticsLabel(l10nEn.postOptions), findsNothing);
    });
  });

  testWidgets('the date line reads date and time', (tester) async {
    setUpView(tester);
    await tester.pumpApp(
      Scaffold(body: PostPageDate(createdAt: DateTime(2026, 10, 25, 18, 42))),
    );
    expect(find.textContaining('October 25, 2026'), findsOneWidget);
    expect(find.textContaining('6:42'), findsOneWidget);
  });

  testWidgets('the notification chip names its source', (tester) async {
    setUpView(tester);
    await tester.pumpApp(const Scaffold(body: PostNotificationChip()));
    expect(find.text(l10nEn.postFromNotification), findsOneWidget);
  });
}
