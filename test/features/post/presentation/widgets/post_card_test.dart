import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/post/presentation/utils/post_card_callbacks.dart';
import 'package:pulse/features/post/presentation/utils/post_card_data.dart';
import 'package:pulse/features/post/presentation/utils/post_card_media.dart';
import 'package:pulse/features/post/presentation/utils/post_media_aspect.dart';
import 'package:pulse/features/post/presentation/widgets/expandable_caption.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/post/presentation/widgets/post_media.dart';
import 'package:pulse/features/post/presentation/widgets/post_video_scope.dart';

import '../../../../helpers/png_http_overrides.dart';
import '../../../../helpers/pump_app.dart';

PostCardMedia photo({int width = 1080, int height = 1350}) => PostCardMedia(
  isVideo: false,
  url: 'https://x.test/p.jpg',
  cacheKey: 'u/p/0.jpg',
  width: width,
  height: height,
);

final now = DateTime(2026, 10, 14, 12);

PostCardData data({
  String? caption = 'Woke up to this view.',
  List<PostCardMedia>? media,
  int likeCount = 7500,
  int commentCount = 425,
  bool isLiked = false,
  bool isSaved = false,
  String? city = 'Kolkata',
  String? audienceIcon,
}) => PostCardData(
  id: 'p1',
  authorId: 'a1',
  authorName: 'Dipprokash Sardar',
  city: city,
  createdAt: now.subtract(const Duration(hours: 2)),
  caption: caption,
  media: media ?? [photo()],
  likeCount: likeCount,
  commentCount: commentCount,
  isLiked: isLiked,
  isSaved: isSaved,
  audienceIcon: audienceIcon,
);

Finder icon(String asset) =>
    find.byWidgetPredicate((w) => w is AppSvgIcon && w.asset == asset);

/// A test at the design frame with the semantics tree on, so labels can be found.
void postTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) => testView(description, (tester) async {
  final semantics = tester.ensureSemantics();
  try {
    await body(tester);
  } finally {
    semantics.dispose();
  }
});

void main() {
  HttpOverrides? previous;

  setUpAll(() {
    registerFallbackValue(Uri());
    previous = HttpOverrides.current;
    HttpOverrides.global = PngHttpOverrides();
  });
  tearDownAll(() => HttpOverrides.global = previous);

  Future<void> show(
    WidgetTester tester,
    PostCardData post, {
    PostCardCallbacks callbacks = const PostCardCallbacks(),
    bool isOptionsOpen = false,
    Locale locale = const Locale('en'),
  }) {
    return withClock(
      Clock.fixed(now),
      () => tester.pumpApp(
        PostVideoScope(
          child: ListView(
            children: [
              PostCard(
                data: post,
                callbacks: callbacks,
                isOptionsOpen: isOptionsOpen,
              ),
            ],
          ),
        ),
        locale: locale,
      ),
    );
  }

  postTest('draws the author, city and time, the caption and the counts', (
    tester,
  ) async {
    await show(tester, data());

    expect(find.text('Dipprokash Sardar'), findsOneWidget);
    expect(find.text('Kolkata · 2h'), findsOneWidget);
    expect(find.text('Woke up to this view.'), findsOneWidget);
    expect(find.text('7.5K'), findsOneWidget);
    expect(find.text('425'), findsOneWidget);
    expect(icon(AppAssets.heart), findsOneWidget);
    expect(icon(AppAssets.bookmark), findsOneWidget);
  });

  postTest('no city leaves just the time; zero counts show no number', (
    tester,
  ) async {
    await show(tester, data(city: null, likeCount: 0, commentCount: 0));

    expect(find.text('2h'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  postTest('liked shows the red filled heart, saved the filled bookmark', (
    tester,
  ) async {
    await show(tester, data(isLiked: true, isSaved: true));

    expect(icon(AppAssets.heartFilled), findsOneWidget);
    expect(icon(AppAssets.heart), findsNothing);
    expect(icon(AppAssets.bookmarkFilled), findsOneWidget);
    expect(find.bySemanticsLabel(l10nEn.postUnlike), findsOneWidget);
  });

  postTest('the audience icon shows only for a post that is not public', (
    tester,
  ) async {
    await show(tester, data());
    expect(icon(AppAssets.lock), findsNothing);

    await show(tester, data(audienceIcon: AppAssets.lock));
    expect(icon(AppAssets.lock), findsOneWidget);
  });

  group('caption', () {
    postTest('a short caption has no more control', (tester) async {
      await show(tester, data());
      expect(find.text(l10nEn.postMore), findsNothing);
    });

    postTest('a long one folds to three lines; more opens, less closes', (
      tester,
    ) async {
      final long = List.filled(60, 'caption').join(' ');
      await show(tester, data(caption: long));

      expect(find.text(l10nEn.postMore), findsOneWidget);
      expect(tester.widget<Text>(find.text(long)).maxLines, 3);

      await tester.tap(find.text(l10nEn.postMore));
      await tester.pump();
      expect(tester.widget<Text>(find.text(long)).maxLines, isNull);
      expect(find.text(l10nEn.postLess), findsOneWidget);

      await tester.tap(find.text(l10nEn.postLess));
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(find.text(long)).maxLines, 3);
      expect(find.text(l10nEn.postMore), findsOneWidget);
    });

    postTest('no caption draws no caption widget', (tester) async {
      await show(tester, data(caption: null));
      expect(find.byType(ExpandableCaption), findsNothing);
    });
  });

  group('callbacks', () {
    postTest('every control calls its own callback', (tester) async {
      final calls = <String>[];
      await show(
        tester,
        data(),
        callbacks: PostCardCallbacks(
          onProfile: () => calls.add('profile'),
          onOptions: () => calls.add('options'),
          onLike: () => calls.add('like'),
          onComment: () => calls.add('comment'),
          onShare: () => calls.add('share'),
          onSave: () => calls.add('save'),
        ),
      );

      await tester.tap(find.text('Dipprokash Sardar'));
      await tester.tap(find.bySemanticsLabel(l10nEn.postOptions));
      await tester.tap(find.bySemanticsLabel(l10nEn.postLike));
      await tester.tap(find.bySemanticsLabel(l10nEn.postComment));
      await tester.tap(find.bySemanticsLabel(l10nEn.postShare));
      await tester.tap(find.bySemanticsLabel(l10nEn.postSave));

      expect(calls, ['profile', 'options', 'like', 'comment', 'share', 'save']);
    });

    postTest('double tap on the media likes, once, and only when not liked', (
      tester,
    ) async {
      var likes = 0;
      final callbacks = PostCardCallbacks(onDoubleTapLike: () => likes++);

      await show(tester, data(), callbacks: callbacks);
      final media = find.byType(PostMedia);
      await tester.tap(media);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(media);
      await tester.pumpAndSettle();
      expect(likes, 1);

      await show(tester, data(isLiked: true), callbacks: callbacks);
      await tester.tap(media);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(media);
      await tester.pumpAndSettle();
      expect(likes, 1, reason: 'a double tap never unlikes');
    });

    postTest(
      'the options button has a soft background while the sheet is open',
      (tester) async {
        await show(tester, data(), isOptionsOpen: true);
        final button = tester.widget<Container>(
          find
              .descendant(
                of: find.bySemanticsLabel(l10nEn.postOptions),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          (button.decoration! as BoxDecoration).color,
          isNot(Colors.transparent),
        );
      },
    );
  });

  group('media', () {
    test('the shape of the first item is kept between 4:5 and 1.91:1', () {
      expect(postMediaAspect(photo(width: 1000, height: 1000)), 1);
      expect(postMediaAspect(photo(width: 1000, height: 3000)), 0.8);
      expect(postMediaAspect(photo(width: 4000, height: 1000)), 1.91);
      expect(postMediaAspect(photo(width: 0, height: 0)), 1);
    });

    postTest('several items show a counter and one dot each', (tester) async {
      await show(tester, data(media: [photo(), photo(), photo()]));

      expect(find.text('1/3'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
              w.constraints?.maxWidth == 6,
        ),
        findsNWidgets(3),
      );

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('2/3'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp(l10nEn.postMediaCounter(2, 3))),
        findsOneWidget,
      );
    });

    postTest('one item has no counter and no dots', (tester) async {
      await show(tester, data());
      expect(find.text('1/1'), findsNothing);
    });

    postTest('a post without media draws no media', (tester) async {
      await show(tester, data(media: const []));
      expect(find.byType(PostMedia), findsNothing);
    });
  });

  group('video', () {
    const video = PostCardMedia(
      isVideo: true,
      url: 'https://x.test/v.mp4',
      posterUrl: 'https://x.test/v.jpg',
      cacheKey: 'u/p/0.mp4',
      width: 720,
      height: 1280,
      durationMs: 12000,
    );

    postTest('shows the duration and a mute button that starts muted', (
      tester,
    ) async {
      await show(tester, data(media: const [video]));

      expect(find.text('0:12'), findsOneWidget);
      expect(icon(AppAssets.volumeOff), findsOneWidget);
      expect(find.bySemanticsLabel(l10nEn.postUnmuteVideo), findsOneWidget);
    });

    postTest('the mute button switches the sound for the list', (tester) async {
      await show(tester, data(media: const [video]));

      await tester.tap(find.bySemanticsLabel(l10nEn.postUnmuteVideo));
      await tester.pump();

      expect(icon(AppAssets.volume), findsOneWidget);
      expect(find.bySemanticsLabel(l10nEn.postMuteVideo), findsOneWidget);
    });
  });

  group('layout', () {
    postTest('RTL: the options button is on the left, the name on the right', (
      tester,
    ) async {
      await show(tester, data(), locale: const Locale('ar'));

      final name = tester.getCenter(find.text('Dipprokash Sardar')).dx;
      final more = tester
          .getCenter(find.bySemanticsLabel(l10nAr.postOptions))
          .dx;
      expect(more, lessThan(name));
    });

    testWidgets('1.5x text does not overflow', (tester) async {
      setUpView(tester, textScale: 1.5);
      final long = List.filled(40, 'caption').join(' ');
      await show(tester, data(caption: long, media: [photo(), photo()]));

      expect(tester.takeException(), isNull);
    });

    testWidgets('a narrow phone does not overflow', (tester) async {
      setUpView(tester, size: const Size(320, 640));
      await show(tester, data(audienceIcon: AppAssets.audience));

      expect(tester.takeException(), isNull);
    });
  });
}
