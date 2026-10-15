import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/presentation/utils/post_options_actions.dart';
import 'package:pulse/features/post/presentation/utils/post_options_data.dart';
import 'package:pulse/features/post/presentation/widgets/post_options/post_options_flow.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late List<String> calls;
  Failure? failure;

  Future<void> step(String name) async {
    calls.add(name);
    if (failure != null) throw failure!;
  }

  PostOptionsActions actions() => PostOptionsActions(
    onSave: () => step('save'),
    onNotInterested: () => step('notInterested'),
    onUnfollow: () => step('unfollow'),
    onUndoUnfollow: () => step('undoUnfollow'),
    onMute: () => step('mute'),
    onUndoMute: () => step('undoMute'),
    onReport: (reason, note) => step('report ${reason.name} $note'),
    onToggleComments: () => step('toggleComments'),
    onDelete: () => step('delete'),
    onAudienceChanged: (audience) => calls.add('audience ${audience.wire}'),
    onEdit: () => calls.add('edit'),
  );

  Future<void> open(
    WidgetTester tester,
    PostOptionsData data, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    Size size = const Size(390, 844),
  }) async {
    calls = [];
    failure = null;
    setUpView(tester, textScale: textScale, size: size);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                PostOptionsFlow.show(context, data: data, actions: actions()),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  const others = PostOptionsData(postId: 'p1', isMine: false, username: 'sara');
  const mine = PostOptionsData(postId: 'p1', isMine: true, username: 'me');

  group('the sheet', () {
    testWidgets("someone else's post shows its rows and the red report", (
      tester,
    ) async {
      await open(tester, others);
      for (final text in [
        l10nEn.postSave,
        l10nEn.postCopyLink,
        l10nEn.postShare,
        l10nEn.postNotInterested,
        l10nEn.postUnfollow('sara'),
        l10nEn.postMute('sara'),
        l10nEn.postReportTitle,
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.text(l10nEn.postDelete), findsNothing);
    });

    testWidgets('your post shows its rows and the red delete', (tester) async {
      await open(tester, mine);
      for (final text in [
        l10nEn.postEditPost,
        l10nEn.postChangeWhoCanSee,
        l10nEn.postCommentsOff,
        l10nEn.postDelete,
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      expect(find.text(l10nEn.postReportTitle), findsNothing);
    });

    testWidgets('Copy link and Share are hidden when the post is not public', (
      tester,
    ) async {
      await open(
        tester,
        const PostOptionsData(
          postId: 'p1',
          isMine: false,
          username: 'sara',
          visibility: ContentAudience.followers,
        ),
      );
      expect(find.text(l10nEn.postSave), findsOneWidget);
      expect(find.text(l10nEn.postCopyLink), findsNothing);
      expect(find.text(l10nEn.postShare), findsNothing);
    });

    testWidgets('a saved post says Saved; comments off says turn on', (
      tester,
    ) async {
      await open(
        tester,
        const PostOptionsData(
          postId: 'p1',
          isMine: true,
          username: 'me',
          isSaved: true,
          commentsEnabled: false,
        ),
      );
      expect(find.text(l10nEn.postSaved), findsOneWidget);
      expect(find.text(l10nEn.postCommentsOn), findsOneWidget);
    });

    testWidgets('Arabic at 1.5x text does not overflow', (tester) async {
      await open(tester, others, locale: const Locale('ar'), textScale: 1.5);
      expect(find.text(l10nAr.postNotInterested), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('own post on a 320 dp phone at 2.0x text, EN and AR, fits', (
      tester,
    ) async {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        await tester.pumpWidget(const SizedBox());
        await open(
          tester,
          mine,
          locale: locale,
          textScale: 2,
          size: const Size(320, 640),
        );
        expect(tester.takeException(), isNull, reason: locale.languageCode);
      }
    });
  });

  group('the options', () {
    testWidgets('Save and Not interested call the list', (tester) async {
      await open(tester, others);
      await tester.tap(find.text(l10nEn.postSave));
      await tester.pumpAndSettle();
      expect(calls, ['save']);

      await open(tester, others);
      await tester.tap(find.text(l10nEn.postNotInterested));
      await tester.pumpAndSettle();
      expect(calls, ['notInterested']);
    });

    testWidgets('Edit post opens the editor', (tester) async {
      await open(tester, mine);
      await tester.tap(find.text(l10nEn.postEditPost));
      await tester.pumpAndSettle();
      expect(calls, ['edit']);
    });

    testWidgets('Copy link says coming soon and calls nothing', (tester) async {
      await open(tester, others);
      await tester.tap(find.text(l10nEn.postCopyLink));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.comingSoon), findsOneWidget);
      expect(calls, isEmpty);
    });

    testWidgets('Unfollow shows the notice, and Undo calls the list', (
      tester,
    ) async {
      await open(tester, others);
      await tester.tap(find.text(l10nEn.postUnfollow('sara')));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.postUnfollowed('sara')), findsOneWidget);
      await tester.tap(find.text(l10nEn.undo));
      await tester.pumpAndSettle();
      expect(calls, ['unfollow', 'undoUnfollow']);
    });

    testWidgets('a failure is shown and no success notice follows', (
      tester,
    ) async {
      await open(tester, others);
      failure = const UnexpectedFailure();
      await tester.tap(find.text(l10nEn.postMute('sara')));
      await tester.pumpAndSettle();
      expect(calls, ['mute']);
      expect(find.text(l10nEn.postMuted('sara')), findsNothing);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Delete asks first; Cancel calls nothing', (tester) async {
      await open(tester, mine);
      await tester.tap(find.text(l10nEn.postDelete));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.postDeleteTitle), findsOneWidget);
      await tester.tap(find.text(l10nEn.cancel));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
    });

    testWidgets('Delete confirmed calls the list and says Post deleted', (
      tester,
    ) async {
      await open(tester, mine);
      await tester.tap(find.text(l10nEn.postDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.delete));
      await tester.pumpAndSettle();
      expect(calls, ['delete']);
      expect(find.text(l10nEn.postDeleted), findsOneWidget);
    });
  });

  group('report', () {
    testWidgets('a reason is sent, then Mute on the thanks step', (
      tester,
    ) async {
      await open(tester, others);
      await tester.tap(find.text(l10nEn.postReportTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.reportReasonSpam));
      await tester.pumpAndSettle();
      expect(calls, ['report ${ReportReason.spam.name} null']);
      expect(find.text(l10nEn.postMute('sara')), findsOneWidget);
      expect(find.text(l10nEn.postUnfollow('sara')), findsOneWidget);

      await tester.tap(find.text(l10nEn.postMute('sara')));
      await tester.pumpAndSettle();
      expect(calls.last, 'mute');
      expect(find.text(l10nEn.postMuted('sara')), findsOneWidget);
    });
  });
}
