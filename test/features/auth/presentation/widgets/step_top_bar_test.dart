import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/widgets/step_top_bar.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Widget bar({
    int step = 3,
    bool isRequired = true,
    VoidCallback? onBack,
    VoidCallback? onSkip,
  }) => Scaffold(
    body: StepTopBar(
      step: step,
      isRequired: isRequired,
      onBack: onBack ?? () {},
      onSkip: onSkip,
    ),
  );

  List<Color?> segmentColors(WidgetTester tester) => [
    for (final c in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    ))
      (c.decoration! as BoxDecoration).color,
  ];

  testView('shows "Step N of 6" and Required in primary', (tester) async {
    await tester.pumpApp(bar(step: 3));
    expect(find.text(l10nEn.stepOf(3)), findsOneWidget);
    final required = tester.widget<Text>(find.text(l10nEn.required));
    expect(required.style!.color, colors.primary);
  });

  testView('Optional is textSecondary and a Skip button follows', (
    tester,
  ) async {
    var skipped = 0;
    await tester.pumpApp(
      bar(step: 4, isRequired: false, onSkip: () => skipped++),
    );
    expect(
      tester.widget<Text>(find.text(l10nEn.optional)).style!.color,
      colors.textSecondary,
    );
    await tester.tap(find.text(l10nEn.skip));
    expect(skipped, 1);
    expect(
      tester.getSize(find.byType(TextButton)).height,
      greaterThanOrEqualTo(44),
    );
  });

  testView('no Skip without onSkip', (tester) async {
    await tester.pumpApp(bar());
    expect(find.text(l10nEn.skip), findsNothing);
  });

  testView('6 segments: the first N primary, the rest grey; 4 high, 4 apart', (
    tester,
  ) async {
    await tester.pumpApp(bar(step: 2));
    expect(segmentColors(tester), [
      colors.primary,
      colors.primary,
      colors.switchOff,
      colors.switchOff,
      colors.switchOff,
      colors.switchOff,
    ]);
    final rects = tester
        .widgetList(find.byType(AnimatedContainer))
        .map((w) => tester.getRect(find.byWidget(w)))
        .toList();
    expect(rects.first.height, 4);
    expect(rects[1].left - rects[0].right, closeTo(4, 0.5));
  });

  testView('progress animates to the next step', (tester) async {
    final step = ValueNotifier(1);
    addTearDown(step.dispose);
    await tester.pumpApp(
      Scaffold(
        body: ValueListenableBuilder(
          valueListenable: step,
          builder: (context, value, _) =>
              StepTopBar(step: value, isRequired: true, onBack: () {}),
        ),
      ),
    );
    expect(segmentColors(tester)[1], colors.switchOff);
    step.value = 2;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // The widget's decoration is the target; the painted box holds the in-between value.
    final painted = find
        .descendant(
          of: find.byType(AnimatedContainer).at(1),
          matching: find.byType(DecoratedBox),
        )
        .first;
    final midway =
        (tester.widget<DecoratedBox>(painted).decoration as BoxDecoration)
            .color;
    expect(midway, isNot(colors.switchOff));
    expect(midway, isNot(colors.primary));
    await tester.pump(const Duration(milliseconds: 150));
    expect(segmentColors(tester)[1], colors.primary);
  });

  testView('the back arrow is a 44 target that calls onBack', (tester) async {
    var backs = 0;
    await tester.pumpApp(bar(onBack: () => backs++));
    final back = find.bySemanticsLabel(l10nEn.back);
    final handle = tester.ensureSemantics();
    expect(back, findsOneWidget);
    expect(tester.getSize(back).width, greaterThanOrEqualTo(44));
    await tester.tap(back);
    expect(backs, 1);
    handle.dispose();
  });

  testView('RTL: the bar fills from the right and the arrow is on the right', (
    tester,
  ) async {
    await tester.pumpApp(bar(step: 1), locale: const Locale('ar'));
    final rects = tester
        .widgetList(find.byType(AnimatedContainer))
        .map((w) => tester.getRect(find.byWidget(w)))
        .toList();
    // The filled first segment is the right-most one.
    expect(rects.first.left, greaterThan(rects.last.left));
    expect(find.text(l10nAr.stepOf(1)), findsOneWidget);
  });

  testView('Skip sits outside the bar, after it (end side)', (tester) async {
    await tester.pumpApp(bar(onSkip: () {}));
    final segments = tester
        .widgetList(find.byType(AnimatedContainer))
        .map((w) => tester.getRect(find.byWidget(w)))
        .toList();
    final skip = tester.getRect(find.byType(TextButton));
    expect(skip.left, greaterThanOrEqualTo(segments.last.right));
  });

  testView('semantics: the step label with its progress value', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(bar(step: 5));
    expect(find.bySemanticsLabel(l10nEn.stepOf(5)), findsOneWidget);
    handle.dispose();
  });
}
