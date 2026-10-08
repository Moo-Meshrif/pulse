import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Widget screen() => const Scaffold(body: AppLoadingView());

  CircularProgressIndicator indicator(WidgetTester tester) =>
      tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );

  testView('a primary spinner, 32 square with a 3 stroke, centered', (
    tester,
  ) async {
    await tester.pumpApp(screen(), settle: false);

    expect(indicator(tester).color, colors.primary);
    expect(indicator(tester).strokeWidth, 3);
    expect(tester.getSize(find.byType(AppSpinner)), const Size(32, 32));
    final center = tester.getCenter(find.byType(AppSpinner));
    final body = tester.getCenter(find.byType(Scaffold));
    expect(center.dx, closeTo(body.dx, 0.5));
    expect(center.dy, closeTo(body.dy, 0.5));
  });

  testView('it is announced as Loading, in English and Arabic', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(screen(), settle: false);
    expect(find.bySemanticsLabel(l10nEn.loading), findsOneWidget);

    await tester.pumpApp(screen(), locale: const Locale('ar'), settle: false);
    expect(find.bySemanticsLabel(l10nAr.loading), findsOneWidget);
    handle.dispose();
  });

  testView('it fills a small window without overflow', (tester) async {
    setUpView(tester, size: const Size(320, 480));
    await tester.pumpApp(screen(), settle: false);
    expect(tester.takeException(), isNull);
  });

  testView('AppSpinner takes its size, stroke and color from its caller', (
    tester,
  ) async {
    await tester.pumpApp(
      const Scaffold(
        body: Center(
          child: AppSpinner(size: 20, strokeWidth: 2, color: Colors.white),
        ),
      ),
      settle: false,
    );

    expect(tester.getSize(find.byType(AppSpinner)), const Size(20, 20));
    expect(indicator(tester).strokeWidth, 2);
    expect(indicator(tester).color, Colors.white);
    expect(indicator(tester).semanticsLabel, isNull);
  });

  testView('PrimaryButton\'s loading state uses the same spinner', (
    tester,
  ) async {
    await tester.pumpApp(
      Center(
        child: PrimaryButton(
          label: 'Continue',
          onPressed: () {},
          loading: true,
        ),
      ),
      settle: false,
    );

    expect(find.byType(AppSpinner), findsOneWidget);
    expect(tester.getSize(find.byType(AppSpinner)), const Size(20, 20));
    expect(indicator(tester).color, colors.textOnPrimary);
  });
}
