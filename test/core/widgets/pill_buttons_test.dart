import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/pill_button_variant.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  variantTests();
  const colors = AppColors.light;

  Color? fill(WidgetTester tester) => tester
      .widget<FilledButton>(find.byType(FilledButton))
      .style!
      .backgroundColor!
      .resolve({});

  testWidgets('outline: white fill, 1 px border, no fixed height', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      PillButton.outline(label: 'Google', onPressed: () => taps++),
    );
    expect(fill(tester), colors.surface);
    final shape =
        tester
                .widget<FilledButton>(find.byType(FilledButton))
                .style!
                .shape!
                .resolve({})
            as StadiumBorder;
    expect(shape.side.color, colors.border);
    expect(shape.side.width, 1);
    await tester.tap(find.text('Google'));
    expect(taps, 1);
  });

  testWidgets('soft: background fill, 48 high', (tester) async {
    await tester.pumpApp(
      Center(
        child: PillButton.soft(label: 'Keep going', onPressed: () {}),
      ),
    );
    expect(fill(tester), colors.background);
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
  });

  testWidgets('danger: danger fill with a white label, 48 high', (
    tester,
  ) async {
    await tester.pumpApp(
      Center(
        child: PillButton.danger(label: 'Leave', onPressed: () {}),
      ),
    );
    expect(fill(tester), colors.danger);
    expect(tester.getSize(find.byType(FilledButton)).height, 48);
    expect(
      tester.widget<Text>(find.text('Leave')).style!.color,
      colors.textOnPrimary,
    );
  });

  testWidgets('a null onPressed disables the pill and dims it to 40%', (
    tester,
  ) async {
    await tester.pumpApp(
      const PillButton.danger(label: 'Leave', onPressed: null),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
  });

  testWidgets('pressed darkens the fill', (tester) async {
    await tester.pumpApp(PillButton.danger(label: 'Leave', onPressed: () {}));
    final style = tester.widget<FilledButton>(find.byType(FilledButton)).style!;
    final pressed = style.backgroundColor!.resolve({WidgetState.pressed})!;
    expect(pressed, isNot(colors.danger));
    expect(pressed, Color.lerp(colors.danger, colors.textPrimary, 0.06));
  });
}

void variantTests() {
  const colors = AppColors.light;

  testView('each factory picks its variant', (tester) async {
    await tester.pumpApp(
      Column(
        children: [
          PillButton.outline(label: 'a', onPressed: () {}),
          PillButton.soft(label: 'b', onPressed: () {}),
          PillButton.danger(label: 'c', onPressed: () {}),
        ],
      ),
    );
    final variants = tester
        .widgetList<PillButton>(find.byType(PillButton))
        .map((b) => b.variant);
    expect(variants, PillButtonVariant.values);
  });

  testView('the variant enum owns sizing and colors', (tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    expect(PillButtonVariant.outline.height, isNull);
    expect(PillButtonVariant.outline.verticalPadding, 15);
    expect(PillButtonVariant.soft.height, 48);
    expect(PillButtonVariant.danger.height, 48);
    expect(PillButtonVariant.outline.border(context), colors.border);
    expect(PillButtonVariant.soft.border(context), isNull);
    expect(PillButtonVariant.danger.fill(context), colors.danger);
    expect(PillButtonVariant.danger.foreground(context), colors.textOnPrimary);
    expect(PillButtonVariant.soft.fill(context), colors.background);
  });
}
