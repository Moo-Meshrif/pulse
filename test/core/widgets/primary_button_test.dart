import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  Color? fill(WidgetTester tester, Set<WidgetState> states) => tester
      .widget<FilledButton>(find.byType(FilledButton))
      .style!
      .backgroundColor!
      .resolve(states);

  const colors = AppColors.light;

  testWidgets('enabled: shows the label and calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      PrimaryButton(label: 'Continue', onPressed: () => taps++, expand: true),
    );
    expect(find.text('Continue'), findsOneWidget);
    expect(fill(tester, {}), colors.primary);
    await tester.tap(find.byType(PrimaryButton));
    expect(taps, 1);
  });

  testWidgets('disabled (null onPressed): primary @ 40% and taps ignored', (
    tester,
  ) async {
    await tester.pumpApp(
      const PrimaryButton(label: 'Continue', onPressed: null, expand: true),
    );
    expect(find.text('Continue'), findsOneWidget);
    expect(
      fill(tester, {WidgetState.disabled}),
      colors.primary.withValues(alpha: 0.4),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets(
    'loading: spinner replaces the label, fill stays primary, taps ignored',
    (tester) async {
      var taps = 0;
      await tester.pumpApp(
        PrimaryButton(
          label: 'Continue',
          onPressed: () => taps++,
          expand: true,
          loading: true,
        ),
        settle: false,
      );
      expect(find.text('Continue'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(fill(tester, {WidgetState.disabled}), colors.primary);
      await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
      expect(taps, 0);
    },
  );
}
