import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/widgets/or_divider.dart';
import 'package:pulse/features/auth/presentation/widgets/social_buttons_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testView('divider: a label between two 1 px lines', (tester) async {
    await tester.pumpApp(
      const Scaffold(body: OrDivider(text: 'or continue with')),
    );
    expect(find.text('or continue with'), findsOneWidget);
    final lines = find.byWidgetPredicate(
      (w) => w is ColoredBox && w.color == AppColors.light.divider,
    );
    expect(lines, findsNWidgets(2));
    expect(tester.getSize(lines.first).height, 1);
    final leftLine = tester.getRect(lines.first);
    final label = tester.getRect(find.text('or continue with'));
    expect(label.left - leftLine.right, closeTo(12, 0.5));
  });

  testView('social row: Google and Apple, equal width, 12 apart', (
    tester,
  ) async {
    await tester.pumpApp(const Scaffold(body: SocialButtonsRow()));
    final google = tester.getRect(find.widgetWithText(FilledButton, 'Google'));
    final apple = tester.getRect(find.widgetWithText(FilledButton, 'Apple'));
    expect(google.width, closeTo(apple.width, 0.5));
    expect(apple.left - google.right, closeTo(12, 0.5));
  });

  testView('a tap shows the "Coming soon" snackbar', (tester) async {
    await tester.pumpApp(const Scaffold(body: SocialButtonsRow()));
    await tester.tap(find.text('Google'));
    await tester.pump();
    expect(find.text(l10nEn.comingSoon), findsOneWidget);
  });

  testView('Arabic: the order mirrors and the snackbar is Arabic', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(body: SocialButtonsRow()),
      locale: const Locale('ar'),
    );
    final google = tester.getRect(find.widgetWithText(FilledButton, 'Google'));
    final apple = tester.getRect(find.widgetWithText(FilledButton, 'Apple'));
    expect(google.left, greaterThan(apple.left));
    await tester.tap(find.text('Apple'));
    await tester.pump();
    expect(find.text(l10nAr.comingSoon), findsOneWidget);
  });
}
