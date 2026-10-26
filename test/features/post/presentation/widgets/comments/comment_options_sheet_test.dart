import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/comment_option_layout.dart';
import 'package:pulse/features/post/presentation/utils/enums/comment_option.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_options_sheet.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    CommentOptionLayout layout, {
    Locale locale = const Locale('en'),
    void Function(CommentMenuChoice?)? onResult,
  }) async {
    setUpView(tester);
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            final choice = await CommentOptionsSheet.show(context, layout);
            onResult?.call(choice);
          },
          child: const Text('open'),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets("someone else's comment shows emoji, reply, copy, report", (
    tester,
  ) async {
    await pump(
      tester,
      CommentOptionLayout.of(
        isMine: false,
        isPostOwner: false,
        commentsEnabled: true,
      ),
    );
    expect(find.text('❤️'), findsOneWidget);
    expect(find.text(l10nEn.commentReply), findsOneWidget);
    expect(find.text(l10nEn.commentsCopyText), findsOneWidget);
    expect(find.text(l10nEn.commentsReport), findsOneWidget);
    expect(find.text(l10nEn.commentsHide), findsNothing);
  });

  testWidgets('the post owner also sees Hide', (tester) async {
    await pump(
      tester,
      CommentOptionLayout.of(
        isMine: false,
        isPostOwner: true,
        commentsEnabled: true,
      ),
    );
    expect(find.text(l10nEn.commentsHide), findsOneWidget);
  });

  testWidgets('your own comment shows edit, copy, delete and no emoji', (
    tester,
  ) async {
    await pump(
      tester,
      CommentOptionLayout.of(
        isMine: true,
        isPostOwner: false,
        commentsEnabled: true,
      ),
    );
    expect(find.text(l10nEn.commentsEdit), findsOneWidget);
    expect(find.text(l10nEn.commentsCopyText), findsOneWidget);
    expect(find.text(l10nEn.commentsDelete), findsOneWidget);
    expect(find.text('❤️'), findsNothing);
    expect(find.text(l10nEn.commentReply), findsNothing);
  });

  testWidgets('a row pops with its option, an emoji with the emoji', (
    tester,
  ) async {
    CommentMenuChoice? choice;
    final layout = CommentOptionLayout.of(
      isMine: false,
      isPostOwner: false,
      commentsEnabled: true,
    );
    await pump(tester, layout, onResult: (c) => choice = c);
    await tester.tap(find.text(l10nEn.commentsCopyText));
    await tester.pumpAndSettle();
    expect(choice, (option: CommentOption.copyText, emoji: null));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🔥'));
    await tester.pumpAndSettle();
    expect(choice, (option: null, emoji: '🔥'));
  });

  testWidgets('Arabic lays out without overflow', (tester) async {
    await pump(
      tester,
      CommentOptionLayout.of(
        isMine: false,
        isPostOwner: true,
        commentsEnabled: true,
      ),
      locale: const Locale('ar'),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(l10nAr.commentsReport), findsOneWidget);
  });
}
