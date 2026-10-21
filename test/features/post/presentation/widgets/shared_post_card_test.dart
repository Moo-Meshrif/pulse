import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/presentation/utils/post_card_callbacks.dart';
import 'package:pulse/features/post/presentation/utils/post_card_data.dart';
import 'package:pulse/features/post/presentation/utils/post_card_media.dart';
import 'package:pulse/features/post/presentation/widgets/post_action_bar.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/post/presentation/widgets/post_unavailable_embed.dart';
import 'package:pulse/features/post/presentation/widgets/post_video_scope.dart';
import 'package:pulse/features/post/presentation/widgets/shared_post_embed.dart';

import '../../../../helpers/png_http_overrides.dart';
import '../../../../helpers/pump_app.dart';

final now = DateTime(2026, 10, 21, 12);

const photo = PostCardMedia(
  isVideo: false,
  url: 'https://x.test/p.jpg',
  cacheKey: 'u/p/0.jpg',
  width: 1080,
  height: 1350,
);

PostCardData original({String name = 'Nour Adel'}) => PostCardData(
  id: 'o1',
  authorId: 'a2',
  authorName: name,
  city: 'Zamalek, Cairo',
  createdAt: now.subtract(const Duration(hours: 2)),
  caption: 'Sunset run by the Nile',
  media: const [photo],
  mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
);

PostCardData share({
  String? caption = 'This is the best spot in Cairo',
  PostCardData? embedded,
  bool unavailable = false,
  String sharer = 'Dipprokash Sardar',
  PostMoodEntity? mood,
}) => PostCardData(
  id: 's1',
  authorId: 'a1',
  authorName: sharer,
  createdAt: now.subtract(const Duration(hours: 1)),
  caption: caption,
  likeCount: 14,
  commentCount: 2,
  isShare: true,
  original: unavailable ? null : (embedded ?? original()),
  mood: mood,
);

Finder rich(String text) => find.textContaining(text, findRichText: true);

void main() {
  HttpOverrides? previous;

  setUpAll(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = PngHttpOverrides();
  });
  tearDownAll(() => HttpOverrides.global = previous);

  Future<void> show(
    WidgetTester tester,
    PostCardData post, {
    PostCardCallbacks callbacks = const PostCardCallbacks(),
    Locale locale = const Locale('en'),
  }) => withClock(
    Clock.fixed(now),
    () => tester.pumpApp(
      PostVideoScope(
        child: ListView(
          children: [PostCard(data: post, callbacks: callbacks)],
        ),
      ),
      locale: locale,
    ),
  );

  group('share with its original', () {
    testView('header names both people, the words and the framed original', (
      tester,
    ) async {
      await show(tester, share());

      expect(rich('Dipprokash Sardar'), findsOneWidget);
      expect(rich("shared Nour Adel's post"), findsOneWidget);
      expect(find.text('This is the best spot in Cairo'), findsOneWidget);
      expect(find.byType(SharedPostEmbed), findsOneWidget);
      expect(find.text('Sunset run by the Nile'), findsOneWidget);
      expect(find.byType(PostUnavailableEmbed), findsNothing);
    });

    testView('the share has one action bar; the framed post has none', (
      tester,
    ) async {
      await show(tester, share());

      expect(find.byType(PostActionBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SharedPostEmbed),
          matching: find.byType(PostActionBar),
        ),
        findsNothing,
      );
      expect(find.text('14'), findsOneWidget);
    });

    testView('the share\'s feeling goes in the headline', (tester) async {
      await show(
        tester,
        share(
          mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
        ),
      );

      expect(rich("shared Nour Adel's post is feeling"), findsOneWidget);
    });

    testView('without words the original follows the header', (tester) async {
      await show(tester, share(caption: null));

      expect(find.byType(SharedPostEmbed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testView(
      'a tap on the framed post opens it, the name of the author opens their profile',
      (tester) async {
        var opened = 0;
        var profiles = 0;
        await show(
          tester,
          share(),
          callbacks: PostCardCallbacks(
            onOriginal: () => opened++,
            onOriginalProfile: () => profiles++,
          ),
        );

        await tester.tap(find.text('Sunset run by the Nile'));
        expect(opened, 1);

        final headline = tester.widget<RichText>(
          find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().contains('shared'),
          ),
        );
        headline.text.visitChildren((span) {
          if (span is TextSpan && span.text == 'Nour Adel') {
            (span.recognizer! as TapGestureRecognizer).onTap!();
          }
          return true;
        });
        expect(profiles, 1);
      },
    );

    testView('the framed post is one labelled button', (tester) async {
      final semantics = tester.ensureSemantics();
      await show(
        tester,
        share(),
        callbacks: PostCardCallbacks(onOriginal: () {}),
      );

      expect(
        find.bySemanticsLabel(l10nEn.postSharedSemantics('Nour Adel')),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('send icon', () {
    PostCardData plain({required bool canShare}) => PostCardData(
      id: 'p1',
      authorId: 'a1',
      authorName: 'Nour Adel',
      createdAt: now.subtract(const Duration(hours: 1)),
      caption: 'Hello',
      canShare: canShare,
    );

    testView('is drawn when the post can be shared', (tester) async {
      final semantics = tester.ensureSemantics();
      await show(tester, plain(canShare: true));

      expect(find.bySemanticsLabel(l10nEn.postShare), findsOneWidget);
      semantics.dispose();
    });

    testView('is left out when the post can not be shared', (tester) async {
      final semantics = tester.ensureSemantics();
      await show(tester, plain(canShare: false));

      expect(find.bySemanticsLabel(l10nEn.postShare), findsNothing);
      expect(find.bySemanticsLabel(l10nEn.postSave), findsOneWidget);
      semantics.dispose();
    });
  });

  group('original unavailable', () {
    testView('shows the tile, keeps the words and the actions', (tester) async {
      await show(tester, share(unavailable: true));

      expect(find.byType(PostUnavailableEmbed), findsOneWidget);
      expect(find.text(l10nEn.postUnavailableTitle), findsOneWidget);
      expect(find.text(l10nEn.postUnavailableBody), findsOneWidget);
      expect(find.text('This is the best spot in Cairo'), findsOneWidget);
      expect(find.byType(PostActionBar), findsOneWidget);
      expect(find.byType(SharedPostEmbed), findsNothing);
    });

    testView('the header says "shared a post"', (tester) async {
      await show(tester, share(unavailable: true));

      expect(rich('shared a post'), findsOneWidget);
      expect(rich("'s post"), findsNothing);
    });

    testView('the tile reads "Post unavailable"', (tester) async {
      final semantics = tester.ensureSemantics();
      await show(tester, share(unavailable: true));

      expect(
        find.bySemanticsLabel(l10nEn.postUnavailableSemantics),
        findsOneWidget,
      );
      semantics.dispose();
    });
  });

  group('layout', () {
    final longNames = share(
      sharer: 'A very long sharer name that cannot fit on one line at all',
      embedded: original(
        name: 'An equally long author name that goes past two lines too',
      ),
    );

    testView('a long header stops at two lines', (tester) async {
      await show(tester, longNames);

      final headline = tester.widget<RichText>(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('shared'),
        ),
      );
      expect(headline.maxLines, 2);
      expect(headline.overflow, TextOverflow.ellipsis);
      expect(tester.takeException(), isNull);
    });

    testWidgets('1.5x text does not overflow', (tester) async {
      setUpView(tester, textScale: 1.5);
      await show(tester, longNames);
      expect(tester.takeException(), isNull);

      await show(tester, share(unavailable: true));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a narrow phone does not overflow', (tester) async {
      setUpView(tester, size: const Size(320, 640));
      await show(tester, longNames);
      expect(tester.takeException(), isNull);
    });
  });

  group('Arabic', () {
    testView('header reads sharer, "شارك منشور", author', (tester) async {
      await show(tester, share(), locale: const Locale('ar'));

      expect(rich('شارك منشور'), findsOneWidget);
      expect(find.byType(SharedPostEmbed), findsOneWidget);
    });

    testView('the unavailable tile and header are Arabic', (tester) async {
      await show(tester, share(unavailable: true), locale: const Locale('ar'));

      expect(find.text(l10nAr.postUnavailableTitle), findsOneWidget);
      expect(rich('شارك منشورًا'), findsOneWidget);
    });

    testWidgets('1.5x text does not overflow', (tester) async {
      setUpView(tester, textScale: 1.5);
      await show(tester, share(), locale: const Locale('ar'));
      expect(tester.takeException(), isNull);
    });
  });
}
