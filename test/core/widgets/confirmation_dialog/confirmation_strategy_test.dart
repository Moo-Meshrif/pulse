import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/confirmation_dialog/confirmation_strategy.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    return context;
  }

  testView(
    'icon styles: danger on dangerSoft, primary on primarySoft, none for stacked',
    (tester) async {
      final context = await pumpContext(tester);
      expect(const DestructiveStrategy().iconStyle(context), (
        fill: colors.dangerSoft,
        color: colors.danger,
      ));
      expect(const PrimaryStrategy().iconStyle(context), (
        fill: colors.primarySoft,
        color: colors.primary,
      ));
      expect(const InfoStrategy().iconStyle(context), (
        fill: colors.primarySoft,
        color: colors.primary,
      ));
      expect(
        const StackedStrategy(destructive: true).iconStyle(context),
        isNull,
      );
    },
  );

  testView(
    'actions: Row for destructive and primary, one button for info, Column for stacked',
    (tester) async {
      final context = await pumpContext(tester);
      Widget build(ConfirmationStrategy s) =>
          s.actions(context, confirmLabel: 'OK', cancelLabel: 'Cancel');

      expect(build(const DestructiveStrategy()), isA<Row>());
      expect(build(const PrimaryStrategy()), isA<Row>());
      expect(build(const InfoStrategy()), isA<PrimaryButton>());
      expect(build(const StackedStrategy(destructive: true)), isA<Column>());
    },
  );

  testView(
    'destructive and stacked-destructive focus the cancel action; the others do not',
    (tester) async {
      final context = await pumpContext(tester);
      bool focusesCancel(ConfirmationStrategy s) {
        final actions = s.actions(
          context,
          confirmLabel: 'OK',
          cancelLabel: 'Cancel',
        );
        final children = actions is Row
            ? (actions.children.first as Expanded).child
            : (actions as Column).children.last;
        return (children as PillButton).autofocus;
      }

      expect(focusesCancel(const DestructiveStrategy()), isTrue);
      expect(focusesCancel(const StackedStrategy(destructive: true)), isTrue);
      expect(focusesCancel(const PrimaryStrategy()), isFalse);
      expect(focusesCancel(const StackedStrategy(destructive: false)), isFalse);
    },
  );
}
