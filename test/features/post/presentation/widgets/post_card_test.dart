import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
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
  String authorName = 'Dipprokash Sardar',
  String? viewerId,
  bool isMine = false,
  bool commentsEnabled = true,
  PostMoodEntity? mood,
  List<PostTagEntity> tags = const [],
  int? tagCount,
}) => PostCardData(
  id: 'p1',
  authorId: 'a1',
  authorName: authorName,
  city: city,
  createdAt: now.subtract(const Duration(hours: 2)),
  caption: caption,
  media: media ?? [photo()],
  likeCount: likeCount,
  commentCount: commentCount,
  isLiked: isLiked,
  isSaved: isSaved,
  audienceIcon: audienceIcon,
  isMine: isMine,
  viewerId: viewerId,
  commentsEnabled: commentsEnabled,
  mood: mood,
  tags: tags,
  tagCount: tagCount ?? tags.length,
);

/// Text inside the headline's rich text.
Finder rich(String text) => find.textContaining(text, findRichText: true);

const happy = PostMoodEntity(kind: MoodKind.feeling, key: 'happy');
const omar = PostTagEntity(
  userId: 'u2',
  username: 'omarkh',
  fullName: 'Omar Khaled',
);
const laila = PostTagEntity(
  userId: 'u3',
  username: 'laila',
  fullName: 'Laila Fouad',
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

    expect(rich('Dipprokash Sardar'), findsOneWidget);
    expect(find.text('Kolkata'), findsOneWidget);
    expect(find.text('2h'), findsOneWidget);
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

  postTest('the audience icon shows after the time when the post has one', (
    tester,
  ) async {
    await show(tester, data());
    expect(icon(AppAssets.lock), findsNothing);

    await show(tester, data(audienceIcon: AppAssets.lock));
    expect(icon(AppAssets.lock), findsOneWidget);
  });

  group('headline', () {
    postTest('names the author alone, also for your own post', (tester) async {
      await show(tester, data());
      expect(rich('Dipprokash Sardar'), findsOneWidget);

      await show(tester, data(isMine: true));
      expect(rich('Dipprokash Sardar'), findsOneWidget);
      expect(rich('You'), findsNothing);
    });

    postTest('a feeling reads "is feeling" with the emoji and the word', (
      tester,
    ) async {
      await show(tester, data(mood: happy));

      expect(rich('is feeling 😊happy'), findsOneWidget);
    });

    postTest('one tag, two tags, and more than two', (tester) async {
      await show(tester, data(tags: [omar]));
      expect(rich('with Omar Khaled'), findsOneWidget);

      await show(tester, data(tags: [omar, laila]));
      expect(rich('with Omar Khaled and Laila Fouad'), findsOneWidget);

      await show(tester, data(tags: [omar, laila], tagCount: 3));
      expect(rich('with Omar Khaled and 2 others'), findsOneWidget);
      expect(rich('Laila'), findsNothing);
    });

    postTest('the headline stops at two lines', (tester) async {
      await show(
        tester,
        data(
          mood: happy,
          tags: const [
            PostTagEntity(
              userId: 'u2',
              username: 'a',
              fullName: 'A very long name that needs more than one line',
            ),
          ],
          tagCount: 40,
        ),
      );

      final headline = tester.widget<RichText>(rich('with').first);
      expect(headline.maxLines, 2);
      expect(headline.overflow, TextOverflow.ellipsis);
    });

    postTest('Arabic uses the noun with no "is feeling" and no verb', (
      tester,
    ) async {
      await show(
        tester,
        data(mood: happy, tags: [omar, laila], tagCount: 3),
        locale: const Locale('ar'),
      );

      expect(rich('😊 ${l10nAr.postFeelingHappy}'), findsOneWidget);
      expect(rich(l10nAr.postHeadlineOthers(2)), findsOneWidget);
      expect(rich('is feeling'), findsNothing);
    });

    postTest('a name opens that profile and "others" the tagged people', (
      tester,
    ) async {
      final calls = <String>[];
      await show(
        tester,
        data(
          authorName: 'Di',
          tags: const [
            PostTagEntity(userId: 'u2', username: 'om', fullName: 'Om'),
            laila,
          ],
          tagCount: 3,
        ),
        callbacks: PostCardCallbacks(
          onProfile: () => calls.add('author'),
          onTaggedPerson: calls.add,
          onTaggedPeople: () => calls.add('others'),
        ),
      );

      Future<void> tapSpan(String text) =>
          tester.tapOnText(find.textRange.ofSubstring(text));

      await tapSpan('Di');
      await tapSpan('Om');
      await tapSpan('2 others');

      expect(calls, ['author', 'u2', 'others']);
    });
  });

  group('meta line', () {
    postTest('place, time and audience icon, or just the time', (tester) async {
      await show(tester, data(audienceIcon: AppAssets.globe));
      expect(icon(AppAssets.location), findsOneWidget);
      expect(find.text('Kolkata'), findsOneWidget);
      expect(find.text('2h'), findsOneWidget);
      expect(icon(AppAssets.globe), findsOneWidget);

      await show(tester, data(city: ' '));
      expect(icon(AppAssets.location), findsNothing);
      expect(find.text('2h'), findsOneWidget);
    });

    postTest('the place calls onLocation', (tester) async {
      var opened = 0;
      await show(
        tester,
        data(),
        callbacks: PostCardCallbacks(onLocation: () => opened++),
      );

      await tester.tap(find.text('Kolkata'));

      expect(opened, 1);
    });
  });

  group('tags on the media', () {
    const onFirst = PostTagEntity(
      userId: 'u2',
      username: 'omarkh',
      mediaPosition: 0,
      x: 0.5,
      y: 0.6,
    );
    const onSecond = PostTagEntity(
      userId: 'u3',
      username: 'laila',
      mediaPosition: 1,
      x: 0.2,
      y: 0.1,
    );
    const postOnly = PostTagEntity(userId: 'u4', username: 'yousef');

    Finder badge() => find.bySemanticsLabel(l10nEn.postTagBadge);

    postTest(
      'the badge shows on a photo of a tagged post, not an untagged one',
      (tester) async {
        await show(tester, data());
        expect(badge(), findsNothing);

        await show(tester, data(tags: [postOnly]));
        expect(badge(), findsOneWidget);
      },
    );

    postTest('a tap shows the labels of that photo only, then they hide', (
      tester,
    ) async {
      await show(
        tester,
        data(tags: [onFirst, onSecond, postOnly], media: [photo(), photo()]),
      );
      expect(find.text('omarkh'), findsNothing);

      await tester.tap(badge());
      await tester.pump();

      expect(find.text('omarkh'), findsOneWidget);
      expect(find.text('laila'), findsNothing);
      expect(find.text('yousef'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(find.text('omarkh'), findsNothing);
    });

    postTest(
      'a tap on the media toggles them, a double tap leaves them as they were',
      (tester) async {
        var likes = 0;
        await show(
          tester,
          data(tags: [onFirst]),
          callbacks: PostCardCallbacks(onDoubleTapLike: () => likes++),
        );
        final media = find.byType(PostMedia);

        await tester.tapAt(tester.getCenter(media) - const Offset(0, 60));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('omarkh'), findsOneWidget);

        await tester.tapAt(tester.getCenter(media) - const Offset(0, 60));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('omarkh'), findsNothing);

        await tester.tapAt(tester.getCenter(media) - const Offset(0, 60));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tapAt(tester.getCenter(media) - const Offset(0, 60));
        await tester.pump(const Duration(seconds: 1));
        expect(likes, 1);
        expect(find.text('omarkh'), findsNothing);
        Notices.clear();
      },
    );

    postTest('a label opens that profile', (tester) async {
      final opened = <String>[];
      await show(
        tester,
        data(tags: [onFirst]),
        callbacks: PostCardCallbacks(onTaggedPerson: opened.add),
      );
      await tester.tap(badge());
      await tester.pump();

      await tester.tap(find.text('omarkh'));

      expect(opened, ['u2']);
    });

    postTest('your own label is a card that removes your tag', (tester) async {
      var removed = 0;
      await show(
        tester,
        data(tags: [onFirst], viewerId: 'u2'),
        callbacks: PostCardCallbacks(onRemoveMyTag: () => removed++),
      );
      await tester.tap(badge());
      await tester.pump();

      expect(find.text('omarkh'), findsNothing);
      expect(find.text(l10nEn.postHeadlineYou), findsOneWidget);
      await tester.tap(find.text(l10nEn.postTagRemoveLabel));

      expect(removed, 1);
    });

    postTest('a long press on the badge opens the tagged people', (
      tester,
    ) async {
      var opened = 0;
      await show(
        tester,
        data(tags: [onFirst]),
        callbacks: PostCardCallbacks(onTaggedPeople: () => opened++),
      );

      await tester.longPress(badge());

      expect(opened, 1);
    });

    postTest('a label near the top edge stays inside the photo', (
      tester,
    ) async {
      await show(tester, data(tags: [onSecond], media: [photo(), photo()]));
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.tap(badge());
      await tester.pump();

      final media = tester.getRect(find.byType(PostMedia));
      final label = tester.getRect(find.text('laila'));
      expect(label.top, greaterThanOrEqualTo(media.top));
      expect(label.left, greaterThanOrEqualTo(media.left));
    });

    postTest('Arabic: the labels keep their spot, not mirrored', (
      tester,
    ) async {
      await show(tester, data(tags: [onFirst]), locale: const Locale('ar'));
      await tester.tap(find.bySemanticsLabel(l10nAr.postTagBadge));
      await tester.pump();

      final media = tester.getRect(find.byType(PostMedia));
      final label = tester.getCenter(find.text('omarkh'));
      expect(label.dx, closeTo(media.left + media.width * 0.5, 2));
    });

    testWidgets('1.5x text does not overflow with labels shown', (
      tester,
    ) async {
      setUpView(tester, textScale: 1.5);
      await show(tester, data(tags: [onFirst, onSecond], viewerId: 'u3'));
      await tester.tap(
        find.bySemanticsLabel(l10nEn.postTagBadge).first,
        warnIfMissed: false,
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('comments off', () {
    postTest('dims the icon, drops the count and adds the line', (
      tester,
    ) async {
      await show(tester, data(commentsEnabled: false));

      expect(icon(AppAssets.commentOff), findsNWidgets(2));
      expect(icon(AppAssets.comment), findsNothing);
      expect(find.text('425'), findsNothing);
      expect(find.text(l10nEn.postCommentsOffLine), findsOneWidget);
    });

    postTest('tapping it shows the notice and does not open comments', (
      tester,
    ) async {
      var opened = 0;
      await show(
        tester,
        data(commentsEnabled: false),
        callbacks: PostCardCallbacks(onComment: () => opened++),
      );

      await tester.tap(find.bySemanticsLabel(l10nEn.postComment));

      expect(opened, 0);
      final notice = Notices.current.value!;
      expect(notice.title, l10nEn.postCommentsOffTitle);
      expect(notice.message, l10nEn.postCommentsOffNotice('Dipprokash Sardar'));
      Notices.clear();
    });
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

      expect(
        find.textContaining(l10nEn.postMore, findRichText: true),
        findsOneWidget,
      );
      expect(find.text(long), findsNothing);

      await tester.tap(find.byType(ExpandableCaption));
      await tester.pump();
      expect(find.text(long), findsOneWidget);
      expect(find.text(l10nEn.postLess), findsOneWidget);

      await tester.tap(find.byType(ExpandableCaption));
      await tester.pumpAndSettle();
      expect(find.text(long), findsNothing);
      expect(
        find.textContaining(l10nEn.postMore, findRichText: true),
        findsOneWidget,
      );
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

      await tester.tap(rich('Dipprokash Sardar'));
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

      final name = tester.getCenter(rich('Dipprokash Sardar')).dx;
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
