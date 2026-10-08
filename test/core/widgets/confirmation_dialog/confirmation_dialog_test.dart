import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  bool? result;
  var finished = false;

  Future<void> open(
    WidgetTester tester,
    Future<bool?> Function(BuildContext) show, {
    Locale locale = const Locale('en'),
  }) async {
    result = null;
    finished = false;
    setUpView(tester);
    await tester.pumpApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                result = await show(context);
                finished = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<bool?> destructive(BuildContext c) => ConfirmationDialog.destructive(
    c,
    icon: AppAssets.warning,
    title: 'Leave sign-up?',
    message: 'Your progress is saved.',
    confirmLabel: 'Leave',
    cancelLabel: 'Keep going',
  );

  group('destructive', () {
    testWidgets('shows title, message and both actions; Leave returns true', (
      tester,
    ) async {
      await open(tester, destructive);
      expect(find.text('Leave sign-up?'), findsOneWidget);
      expect(find.text('Your progress is saved.'), findsOneWidget);
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
      expect(find.text('Leave sign-up?'), findsNothing);
    });

    testWidgets('Keep going returns false', (tester) async {
      await open(tester, destructive);
      await tester.tap(find.text('Keep going'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('a barrier tap closes it with null', (tester) async {
      await open(tester, destructive);
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
      expect(result, isNull);
    });

    testWidgets('cancel is first (start) and confirm last in English', (
      tester,
    ) async {
      await open(tester, destructive);
      final cancel = tester.getTopLeft(find.text('Keep going')).dx;
      final confirm = tester.getTopLeft(find.text('Leave')).dx;
      expect(cancel, lessThan(confirm));
    });

    testWidgets('the row mirrors in Arabic: cancel on the right', (
      tester,
    ) async {
      await open(tester, destructive, locale: const Locale('ar'));
      final cancel = tester.getTopLeft(find.text('Keep going')).dx;
      final confirm = tester.getTopLeft(find.text('Leave')).dx;
      expect(cancel, greaterThan(confirm));
    });

    testWidgets('focus starts on the cancel action', (tester) async {
      await open(tester, destructive);
      final cancelButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Keep going'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(cancelButton.autofocus, isTrue);
    });

    testWidgets(
      'actions are at least 44 high; the dialog is named by its title',
      (tester) async {
        await open(tester, destructive);
        for (final label in ['Keep going', 'Leave']) {
          final button = find.ancestor(
            of: find.text(label),
            matching: find.byType(FilledButton),
          );
          expect(tester.getSize(button).height, greaterThanOrEqualTo(44));
        }
        expect(tester.getSemantics(find.text('Leave sign-up?')), isNotNull);
        expect(find.bySemanticsLabel('Leave sign-up?'), findsWidgets);
      },
    );
  });

  testWidgets('primary: soft cancel + primary confirm', (tester) async {
    await open(
      tester,
      (c) => ConfirmationDialog.primary(
        c,
        icon: AppAssets.bookmark,
        title: 'Save as draft?',
        message: 'Keep it for later.',
        confirmLabel: 'Save',
        cancelLabel: 'Discard',
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  group('info', () {
    Future<bool?> info(BuildContext c, {bool dismissible = true}) =>
        ConfirmationDialog.info(
          c,
          icon: AppAssets.check,
          title: 'Password updated',
          message: 'You can now sign in.',
          okLabel: 'Sign in',
          dismissible: dismissible,
        );

    testWidgets('one full-width action returns true', (tester) async {
      await open(tester, info);
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('dismissible: false ignores the barrier and Android back', (
      tester,
    ) async {
      await open(tester, (c) => info(c, dismissible: false));
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(find.text('Password updated'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Password updated'), findsOneWidget);
      expect(finished, isFalse);
    });
  });

  testWidgets('stacked: no icon, confirm above cancel', (tester) async {
    await open(
      tester,
      (c) => ConfirmationDialog.stacked(
        c,
        title: 'Discard changes?',
        message: 'They will be lost.',
        confirmLabel: 'Discard changes',
        cancelLabel: 'Keep editing',
      ),
    );
    expect(find.byType(AppSvgIcon), findsNothing);
    final confirm = tester.getTopLeft(find.text('Discard changes')).dy;
    final cancel = tester.getTopLeft(find.text('Keep editing')).dy;
    expect(confirm, lessThan(cancel));
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('the card is at most 342 wide and the screen has a blur', (
    tester,
  ) async {
    await open(tester, destructive);
    final card = find.byType(SingleChildScrollView).last;
    expect(tester.getSize(card).width, lessThanOrEqualTo(342));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
