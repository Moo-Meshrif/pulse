import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/post/domain/entity/post_liker_entity.dart';
import 'package:pulse/features/post/presentation/widgets/post_likes/post_liker_row.dart';

import '../../../../../helpers/pump_app.dart';

PostLikerEntity liker({
  FollowStatus follow = FollowStatus.none,
  bool followsMe = false,
}) => PostLikerEntity(
  id: 'u1',
  username: 'salma.ash',
  fullName: 'Salma Ashraf',
  likedAt: DateTime.utc(2026, 10, 27),
  follow: follow,
  followsMe: followsMe,
);

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    final l10n = locale.languageCode == 'en' ? l10nEn : l10nAr;

    group('PostLikerRow ${locale.languageCode}', () {
      Future<void> pump(
        WidgetTester tester,
        PostLikerEntity person, {
        bool isMe = false,
        VoidCallback? onFollow,
      }) => tester.pumpApp(
        Scaffold(
          body: PostLikerRow(
            liker: person,
            isMe: isMe,
            onTap: () {},
            onFollow: onFollow ?? () {},
          ),
        ),
        locale: locale,
      );

      testWidgets('shows name, username and Follow', (tester) async {
        await pump(tester, liker());
        expect(find.text('Salma Ashraf'), findsOneWidget);
        expect(find.text('@salma.ash'), findsOneWidget);
        expect(find.text(l10n.postFollow), findsOneWidget);
      });

      testWidgets('someone who follows you reads Follow back', (tester) async {
        await pump(tester, liker(followsMe: true));
        expect(find.text(l10n.postLikesFollowBack), findsOneWidget);
      });

      testWidgets('a followed or requested person reads Following', (
        tester,
      ) async {
        await pump(tester, liker(follow: FollowStatus.pending));
        expect(find.text(l10n.postFollowing), findsOneWidget);
      });

      testWidgets('the button reports a tap', (tester) async {
        var taps = 0;
        await pump(tester, liker(), onFollow: () => taps++);
        await tester.tap(find.text(l10n.postFollow));
        expect(taps, 1);
      });

      testWidgets('your own row has no button', (tester) async {
        await pump(tester, liker(), isMe: true);
        expect(find.text(l10n.postFollow), findsNothing);
      });
    });
  }
}
