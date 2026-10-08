import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/widgets/labeled_checkbox.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Widget host({
    required bool checked,
    ValueChanged<bool>? onChanged,
    bool compact = false,
  }) => Scaffold(
    body: LabeledCheckbox(
      checked: checked,
      compact: compact,
      onChanged: onChanged ?? (_) {},
      label: const Text('I agree'),
    ),
  );

  BoxDecoration boxDecoration(WidgetTester tester) =>
      tester
              .widget<AnimatedContainer>(find.byType(AnimatedContainer))
              .decoration!
          as BoxDecoration;

  testView('unchecked: white, 1 px border, no check, 24 square', (
    tester,
  ) async {
    await tester.pumpApp(host(checked: false));
    final decoration = boxDecoration(tester);
    expect(decoration.color, colors.surface);
    expect(decoration.border, isNotNull);
    expect(find.byType(AppSvgIcon), findsNothing);
    expect(tester.getSize(find.byType(AnimatedContainer)), const Size(24, 24));
    expect(decoration.borderRadius, BorderRadius.circular(6));
  });

  testView('checked: primary with a white check', (tester) async {
    await tester.pumpApp(host(checked: true));
    expect(boxDecoration(tester).color, colors.primary);
    expect(find.byType(AppSvgIcon), findsOneWidget);
  });

  testView('compact is the 20 box', (tester) async {
    await tester.pumpApp(host(checked: true, compact: true));
    expect(tester.getSize(find.byType(AnimatedContainer)), const Size(20, 20));
  });

  testView('tapping the label toggles it; the row is at least 44 high', (
    tester,
  ) async {
    bool? value;
    await tester.pumpApp(host(checked: false, onChanged: (v) => value = v));
    expect(
      tester.getSize(find.byType(InkWell)).height,
      greaterThanOrEqualTo(44),
    );
    await tester.tap(find.text('I agree'));
    expect(value, isTrue);
  });

  testView('the label starts 12 after the box', (tester) async {
    await tester.pumpApp(host(checked: false));
    final box = tester.getRect(find.byType(AnimatedContainer));
    final label = tester.getRect(find.text('I agree'));
    expect(label.left - box.right, closeTo(12, 0.5));
  });

  testView('semantics report the checked state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(host(checked: true));
    final node = tester.getSemantics(find.byType(LabeledCheckbox));
    expect(node.flagsCollection.isChecked.name, anyOf('isTrue', 'trueState'));
    handle.dispose();
  });

  testView('Arabic: the box is on the right', (tester) async {
    await tester.pumpApp(host(checked: false), locale: const Locale('ar'));
    final box = tester.getCenter(find.byType(AnimatedContainer)).dx;
    final label = tester.getCenter(find.text('I agree')).dx;
    expect(box, greaterThan(label));
  });
}
