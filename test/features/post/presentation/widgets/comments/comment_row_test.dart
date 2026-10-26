import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_row.dart';

import '../../../../../helpers/pump_app.dart';

CommentEntity comment({
  bool isPostAuthor = false,
  bool liked = false,
  int likes = 0,
  String? parentId,
}) => CommentEntity(
  id: 'c1',
  postId: 'p1',
  parentId: parentId,
  authorId: 'u1',
  username: 'karim.h',
  body: 'Where is this?',
  createdAt: DateTime.now(),
  likeCount: likes,
  likedByMe: liked,
  isPostAuthor: isPostAuthor,
  replyCount: 0,
);

void main() {
  Future<void> pump(
    WidgetTester tester,
    CommentEntity comment, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    VoidCallback? onLike,
    VoidCallback? onLikeOnce,
    Future<void> Function()? onOptions,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(
        body: CommentRow(
          comment: comment,
          onLike: onLike ?? () {},
          onLikeOnce: onLikeOnce ?? () {},
          onOptions: onOptions ?? () async {},
          onReply: () {},
        ),
      ),
      locale: locale,
    );
  }

  testWidgets('shows name, text, Reply and the likes', (tester) async {
    await pump(tester, comment(likes: 12));
    expect(find.text('karim.h'), findsOneWidget);
    expect(find.text('Where is this?'), findsOneWidget);
    expect(find.text(l10nEn.commentReply), findsOneWidget);
    expect(find.text(l10nEn.commentLikes(12)), findsOneWidget);
    expect(find.text(l10nEn.commentsAuthorBadge), findsNothing);
  });

  testWidgets('no likes text at zero; "1 like" for one', (tester) async {
    await pump(tester, comment());
    expect(find.textContaining('like'), findsNothing);
    await pump(tester, comment(likes: 1));
    expect(find.text(l10nEn.commentLikes(1)), findsOneWidget);
  });

  testWidgets('the post author gets the Author badge', (tester) async {
    await pump(tester, comment(isPostAuthor: true));
    expect(find.text(l10nEn.commentsAuthorBadge), findsOneWidget);
  });

  testWidgets('the heart taps to like', (tester) async {
    var taps = 0;
    await pump(tester, comment(liked: true), onLike: () => taps++);
    await tester.tap(find.byType(InkResponse));
    expect(taps, 1);
  });

  testWidgets('long press opens the options', (tester) async {
    var opened = 0;
    await pump(tester, comment(), onOptions: () async => opened++);
    await tester.longPress(find.text('Where is this?'));
    expect(opened, 1);
  });

  testWidgets('double tap likes', (tester) async {
    var likes = 0;
    await pump(tester, comment(), onLikeOnce: () => likes++);
    final target = tester.getCenter(find.text('Where is this?'));
    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(target);
    await tester.pump(const Duration(milliseconds: 50));
    expect(likes, 1);
  });

  testWidgets('Arabic and 1.5x text lay out without overflow', (tester) async {
    await pump(
      tester,
      comment(isPostAuthor: true, likes: 12),
      locale: const Locale('ar'),
      textScale: 1.5,
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l10nAr.commentsAuthorBadge), findsOneWidget);
  });
}
