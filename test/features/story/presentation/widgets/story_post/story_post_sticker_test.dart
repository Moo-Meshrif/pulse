import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/story_post_args.dart';
import 'package:pulse/features/story/data/enums/story_post_sticker_style.dart';
import 'package:pulse/features/story/presentation/widgets/story_post/story_post_sticker.dart';

import '../../../../../helpers/pump_app.dart';

const _post = StoryPostArgs(
  postId: 'p1',
  username: 'nour.adel',
  caption: 'Sunset run by the Nile with the crew',
);

void main() {
  for (final style in StoryPostStickerStyle.values) {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      testWidgets('${style.name} draws the author and the words in $locale', (
        tester,
      ) async {
        setUpView(tester);
        await tester.pumpApp(
          Center(
            child: StoryPostSticker(post: _post, style: style),
          ),
          locale: locale,
        );
        expect(tester.takeException(), isNull);
        final l10n = locale.languageCode == 'ar' ? l10nAr : l10nEn;
        expect(
          find.bySemanticsLabel(
            l10n.storyPostSemantics(_post.username, _post.caption!),
          ),
          findsOneWidget,
        );
      });
    }
  }

  testWidgets('a post without words is labelled by its author only', (
    tester,
  ) async {
    setUpView(tester);
    await tester.pumpApp(
      const Center(
        child: StoryPostSticker(
          post: StoryPostArgs(postId: 'p', username: 'omar'),
          style: StoryPostStickerStyle.card,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(l10nEn.storyPostSemanticsNoCaption('omar')),
      findsOneWidget,
    );
  });

  testWidgets('the card is 72 percent of a 390 wide screen', (tester) async {
    setUpView(tester);
    await tester.pumpApp(
      const Center(
        child: StoryPostSticker(post: _post, style: StoryPostStickerStyle.card),
      ),
    );
    final width = tester.getSize(find.byType(StoryPostSticker)).width;
    expect(width, closeTo(390 * 0.72, 0.5));
  });
}
