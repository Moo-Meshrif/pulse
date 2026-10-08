import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Color? fillOf(WidgetTester tester) => tester
      .widget<Material>(
        find
            .descendant(
              of: find.byType(SelectableChip),
              matching: find.byType(Material),
            )
            .first,
      )
      .color;

  Widget chip({
    bool selected = false,
    bool dark = false,
    double height = 44,
    VoidCallback? onTap,
  }) => Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SelectableChip(
        label: 'Travel',
        selected: selected,
        dark: dark,
        height: height,
        onTap: onTap ?? () {},
      ),
    ),
  );

  testView('unselected: white with a border and no check', (tester) async {
    await tester.pumpApp(chip());
    expect(fillOf(tester), colors.surface);
    expect(find.byType(AppSvgIcon), findsNothing);
  });

  testView('selected: primary fill, white label, check first', (tester) async {
    await tester.pumpApp(chip(selected: true));
    expect(fillOf(tester), colors.primary);
    expect(find.byType(AppSvgIcon), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Travel')).style!.color,
      colors.textOnPrimary,
    );
    final check = tester.getCenter(find.byType(AppSvgIcon)).dx;
    final label = tester.getCenter(find.text('Travel')).dx;
    expect(check, lessThan(label));
  });

  testView('dark variant: textPrimary fill, no check', (tester) async {
    await tester.pumpApp(chip(selected: true, dark: true, height: 40));
    expect(fillOf(tester), colors.textPrimary);
    expect(find.byType(AppSvgIcon), findsNothing);
  });

  testView('a 40 high chip still has a 44 tap target', (tester) async {
    var taps = 0;
    await tester.pumpApp(chip(height: 40, onTap: () => taps++));
    final box = tester.getSize(find.byType(SelectableChip));
    expect(box.height, greaterThanOrEqualTo(44));
    await tester.tapAt(
      tester.getTopLeft(find.byType(SelectableChip)) + const Offset(20, 2),
    );
    expect(taps, 1);
  });

  testView('semantics: a selectable button that reports its state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(chip(selected: true));
    final node = tester.getSemantics(find.byType(SelectableChip));
    expect(node.label, 'Travel');
    expect(node.flagsCollection.isSelected, Tristate.isTrue);
    expect(node.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testView('the label is never truncated: the chip grows', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SelectableChip(
            label: 'A very long interest label that keeps going',
            selected: false,
            height: 44,
            onTap: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
