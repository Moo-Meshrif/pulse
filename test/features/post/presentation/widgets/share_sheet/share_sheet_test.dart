import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/utils/story_post_args.dart';
import 'package:pulse/features/post/presentation/cubit/share_sheet/share_sheet_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/share_access.dart';
import 'package:pulse/features/post/presentation/widgets/share_sheet/share_sheet.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_status_use_case.dart';

import '../../../../../helpers/pump_app.dart';
import '../../../post_doubles.dart';

class _Status extends Fake implements GetPublishStatusUseCase {
  @override
  ContentPublishStatus call(ContentKind kind) => ContentPublishIdle(kind);
}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Account extends Mock implements GetLastAccountUseCase {}

void main() {
  late MockPostRepository posts;
  late _Privacy privacy;

  setUp(() async {
    await getIt.reset();
    posts = MockPostRepository();
    privacy = _Privacy();
    final account = _Account();
    when(account.call).thenReturn(null);
    when(privacy.call).thenAnswer(
      (_) async => const PrivacyEntity(
        isPrivate: false,
        defaultVisibility: ContentAudience.public,
      ),
    );
    when(
      () => posts.shareToFeed(
        any(),
        caption: any(named: 'caption'),
        audience: any(named: 'audience'),
        mood: any(named: 'mood'),
        location: any(named: 'location'),
        tags: any(named: 'tags'),
      ),
    ).thenReturn(true);
    getIt.registerFactoryParam<ShareSheetCubit, String, void>(
      (postId, _) =>
          ShareSheetCubit(posts, privacy, _Status(), account, postId),
    );
  });

  tearDown(getIt.reset);

  void busy() => when(
    () => posts.shareToFeed(
      any(),
      caption: any(named: 'caption'),
      audience: any(named: 'audience'),
      mood: any(named: 'mood'),
      location: any(named: 'location'),
      tags: any(named: 'tags'),
    ),
  ).thenReturn(false);

  Future<void> open(
    WidgetTester tester, {
    ShareAccess access = ShareAccess.full,
    Locale locale = const Locale('en'),
    double textScale = 1,
    Size size = const Size(390, 844),
    StoryPostArgs? story,
    RouteFactory? onGenerateRoute,
  }) async {
    setUpView(tester, textScale: textScale, size: size);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => ShareSheet.show(
              context,
              postId: 'o1',
              access: access,
              story: story,
            ),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
      onGenerateRoute: onGenerateRoute,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder tool(String label) => find.bySemanticsLabel(label);

  group('layout', () {
    testWidgets('a public post: composer, tools, Share now and four tiles', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await open(tester);

      expect(find.text(l10nEn.shareTitle), findsOneWidget);
      expect(find.text(l10nEn.shareFieldHint), findsOneWidget);
      expect(tool(l10nEn.shareTagPeople), findsOneWidget);
      expect(tool(l10nEn.shareFeeling), findsOneWidget);
      expect(tool(l10nEn.shareLocation), findsOneWidget);
      expect(find.text(l10nEn.shareNow), findsOneWidget);
      expect(find.text(l10nEn.postAudiencePublic), findsOneWidget);
      for (final label in [
        l10nEn.shareAddToStory,
        l10nEn.shareCopyLink,
        l10nEn.shareWhatsApp,
        l10nEn.shareMore,
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('SEND IN CHAT'), findsNothing);
      semantics.dispose();
    });

    testWidgets(
      'your own Followers post: composer, the audience hint and all the tiles',
      (tester) async {
        await open(tester, access: ShareAccess.ownFollowers);

        expect(find.text(l10nEn.shareNow), findsOneWidget);
        expect(find.text(l10nEn.shareAudienceLocked), findsOneWidget);
        expect(find.text(l10nEn.shareAddToStory), findsOneWidget);
        expect(find.text(l10nEn.shareCopyLink), findsOneWidget);
        expect(find.text(l10nEn.shareWhatsApp), findsOneWidget);
        expect(find.text(l10nEn.shareMore), findsOneWidget);
      },
    );

    testWidgets('the close button closes the sheet', (tester) async {
      final semantics = tester.ensureSemantics();
      await open(tester);

      await tester.tap(find.bySemanticsLabel(l10nEn.close));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.shareTitle), findsNothing);
      semantics.dispose();
    });
  });

  group('caption', () {
    testWidgets('the counter shows while writing and counts the characters', (
      tester,
    ) async {
      await open(tester);
      expect(find.text(l10nEn.shareCounter(0)), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(find.text(l10nEn.shareCounter(5)), findsOneWidget);
    });

    testWidgets('a tap outside closes the keyboard and hides the counter', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      await tester.tapAt(const Offset(10, 10));
      await tester.pump();

      expect(find.text(l10nEn.shareCounter(5)), findsNothing);
    });

    testWidgets('the field stops at 2000 characters', (tester) async {
      await open(tester);
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'x' * 2100);
      await tester.pump();

      expect(find.text(l10nEn.shareCounter(2000)), findsOneWidget);
    });
  });

  group('Share now', () {
    testWidgets('works with no words and closes the sheet at once', (
      tester,
    ) async {
      await open(tester);

      await tester.tap(find.text(l10nEn.shareNow));
      await tester.pumpAndSettle();

      verify(
        () => posts.shareToFeed(
          'o1',
          caption: null,
          audience: ContentAudience.public,
          mood: null,
          location: null,
          tags: const [],
        ),
      ).called(1);
      expect(find.text(l10nEn.shareTitle), findsNothing);
    });

    testWidgets('three posts already going out keeps the sheet and the words', (
      tester,
    ) async {
      busy();
      await open(tester);
      await tester.enterText(find.byType(TextField), 'Keep me');

      await tester.tap(find.text(l10nEn.shareNow));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.newPostPublishBusy), findsOneWidget);
      expect(find.text(l10nEn.shareTitle), findsOneWidget);
      expect(find.text('Keep me'), findsOneWidget);
    });
  });

  group('add to story', () {
    testWidgets('opens the story editor with the post', (tester) async {
      Object? received;
      String? route;
      await open(
        tester,
        story: const StoryPostArgs(postId: 'o1', username: 'nour.adel'),
        onGenerateRoute: (settings) {
          route = settings.name;
          received = settings.arguments;
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const Scaffold(body: Text('story editor')),
          );
        },
      );

      await tester.tap(find.text(l10nEn.shareAddToStory));
      await tester.pumpAndSettle();

      expect(route, AppRoutes.createStoryPost);
      expect(
        received,
        const StoryPostArgs(postId: 'o1', username: 'nour.adel'),
      );
      expect(find.text('story editor'), findsOneWidget);
    });

    testWidgets('without the post to draw it says coming soon', (tester) async {
      await open(tester);

      await tester.tap(find.text(l10nEn.shareAddToStory));
      await tester.pumpAndSettle();

      expect(find.text(l10nEn.comingSoon), findsOneWidget);
    });
  });

  group('not built yet', () {
    for (final label in [
      l10nEn.shareCopyLink,
      l10nEn.shareWhatsApp,
      l10nEn.shareMore,
    ]) {
      testWidgets('$label says coming soon', (tester) async {
        await open(tester);

        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(find.text(l10nEn.comingSoon), findsOneWidget);
        expect(find.text(l10nEn.shareTitle), findsOneWidget);
      });
    }
  });

  group('layout at other sizes', () {
    testWidgets('Arabic mirrors and reads Arabic', (tester) async {
      await open(tester, locale: const Locale('ar'));

      expect(find.text(l10nAr.shareTitle), findsOneWidget);
      expect(find.text(l10nAr.shareNow), findsOneWidget);
      expect(find.text(l10nAr.shareAddToStory), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.5x text does not overflow, EN and AR', (tester) async {
      await open(tester, textScale: 1.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Arabic at 1.5x on a 320 dp phone fits', (tester) async {
      await open(
        tester,
        locale: const Locale('ar'),
        textScale: 1.5,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
