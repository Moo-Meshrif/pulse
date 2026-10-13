import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/core/enums/sheet_tone.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

const _copy = ReportCopy(
  title: 'Report story',
  body: 'Why are you reporting this story?',
  sentBody: "We'll review this story.",
  notePlaceholder: 'Tell us what is wrong',
);

typedef _Call = (ReportReason, String?);

void main() {
  late List<_Call> calls;
  bool? result;
  Object? submitError;

  Future<void> open(
    WidgetTester tester, {
    SheetTone tone = SheetTone.dark,
    Locale locale = const Locale('en'),
  }) async {
    calls = [];
    result = null;
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await ReportSheet.show(
              context,
              copy: _copy,
              tone: tone,
              onSubmit: (reason, note) async {
                calls.add((reason, note));
                if (submitError != null) throw submitError!;
              },
            );
          },
          child: const Text('open'),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  setUp(() => submitError = null);

  for (final tone in SheetTone.values) {
    testWidgets('$tone: a reason is sent at once, then the thanks step', (
      tester,
    ) async {
      setUpView(tester);
      await open(tester, tone: tone);
      expect(find.text('Report story'), findsOneWidget);
      for (final label in [
        l10nEn.reportReasonSpam,
        l10nEn.reportReasonNudity,
        l10nEn.reportReasonHate,
        l10nEn.reportReasonBullying,
        l10nEn.reportReasonViolence,
        l10nEn.reportReasonFalseInfo,
        l10nEn.reportReasonOther,
      ]) {
        expect(find.text(label), findsOneWidget);
      }

      await tester.tap(find.text(l10nEn.reportReasonBullying));
      await tester.pumpAndSettle();

      expect(calls, [(ReportReason.bullying, null)]);
      expect(find.text(l10nEn.reportSentTitle), findsOneWidget);
      expect(find.text("We'll review this story."), findsOneWidget);

      await tester.tap(find.text(l10nEn.reportDone));
      await tester.pumpAndSettle();
      expect(result, isTrue);
    });
  }

  testWidgets('closing the reasons step sends nothing and resolves false', (
    tester,
  ) async {
    setUpView(tester);
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pumpAndSettle();
    expect(calls, isEmpty);
    expect(result, isFalse);
  });

  testWidgets('dismissing the thanks step still resolves true', (tester) async {
    setUpView(tester);
    await open(tester);
    await tester.tap(find.text(l10nEn.reportReasonSpam));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // the scrim
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  group('Something else', () {
    Finder send() => find.byType(FilledButton);

    testWidgets('opens the note step; Send needs 5 characters', (tester) async {
      setUpView(tester);
      await open(tester);
      await tester.tap(find.text(l10nEn.reportReasonOther));
      await tester.pumpAndSettle();

      expect(calls, isEmpty);
      expect(find.text(l10nEn.reportElseBody), findsOneWidget);
      expect(find.text(_copy.notePlaceholder), findsOneWidget);
      expect(find.text('0 / 500'), findsOneWidget);
      expect(tester.widget<FilledButton>(send()).onPressed, isNull);

      await tester.enterText(find.byType(TextField), '  abcd ');
      await tester.pump();
      expect(tester.widget<FilledButton>(send()).onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'abcde');
      await tester.pump();
      expect(tester.widget<FilledButton>(send()).onPressed, isNotNull);
    });

    testWidgets('sends the trimmed note as "other"', (tester) async {
      setUpView(tester);
      await open(tester);
      await tester.tap(find.text(l10nEn.reportReasonOther));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '  rude words  ');
      await tester.pump();
      await tester.tap(send());
      await tester.pumpAndSettle();

      expect(calls, [(ReportReason.other, 'rude words')]);
      expect(find.text(l10nEn.reportSentTitle), findsOneWidget);
    });

    testWidgets('the counter turns danger at 500 and input stops there', (
      tester,
    ) async {
      setUpView(tester);
      await open(tester);
      await tester.tap(find.text(l10nEn.reportReasonOther));
      await tester.pumpAndSettle();

      Color? counterColor() =>
          tester.widget<Text>(find.textContaining(' / 500')).style?.color;
      await tester.enterText(find.byType(TextField), 'a' * 499);
      await tester.pump();
      final before = counterColor();
      await tester.enterText(find.byType(TextField), 'a' * 600);
      await tester.pump();
      expect(find.text('500 / 500'), findsOneWidget);
      expect(counterColor(), isNot(before));
    });

    testWidgets('back returns to the reasons', (tester) async {
      setUpView(tester);
      await open(tester);
      await tester.tap(find.text(l10nEn.reportReasonOther));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(l10nEn.back));
      await tester.pumpAndSettle();
      expect(find.text(l10nEn.reportReasonSpam), findsOneWidget);
    });
  });

  testWidgets('a failed send shows the error and lets the user try again', (
    tester,
  ) async {
    setUpView(tester);
    submitError = const NetworkFailure();
    await open(tester);
    await tester.tap(find.text(l10nEn.reportReasonSpam));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.errorNetwork), findsOneWidget);
    expect(find.text(l10nEn.reportSentTitle), findsNothing);

    submitError = null;
    await tester.tap(find.text(l10nEn.reportReasonSpam));
    await tester.pumpAndSettle();
    expect(calls, hasLength(2));
    expect(find.text(l10nEn.reportSentTitle), findsOneWidget);
  });

  testWidgets('Arabic: RTL, reasons and thanks in Arabic', (tester) async {
    setUpView(tester);
    await open(tester, locale: const Locale('ar'));
    expect(find.text(l10nAr.reportReasonSpam), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text(l10nAr.reportReasonSpam))),
      TextDirection.rtl,
    );
    await tester.tap(find.text(l10nAr.reportReasonSpam));
    await tester.pumpAndSettle();
    expect(find.text(l10nAr.reportSentTitle), findsOneWidget);
  });

  testWidgets('1.5x text: no overflow on the reasons and note steps', (
    tester,
  ) async {
    setUpView(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(l10nEn.reportReasonOther));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
