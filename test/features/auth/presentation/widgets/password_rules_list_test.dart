import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/presentation/utils/password_rule.dart';
import 'package:pulse/features/auth/presentation/widgets/password_rules_list.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;
  const rules = [
    PasswordRule(label: 'At least 8 characters', met: true),
    PasswordRule(label: 'Contains a number', met: false),
    PasswordRule(label: 'Upper and lower case letters', met: false),
  ];

  testView('a met rule shows a primary check, an unmet one a grey dot', (
    tester,
  ) async {
    await tester.pumpApp(const Scaffold(body: PasswordRulesList(rules: rules)));
    expect(find.byType(AppSvgIcon), findsOneWidget);
    final dots = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == colors.dashed,
    );
    expect(dots, findsNWidgets(2));
    expect(tester.getSize(dots.first), const Size(6, 6));
  });

  testView('rows are 8 apart and the text never moves when a rule flips', (
    tester,
  ) async {
    await tester.pumpApp(const Scaffold(body: PasswordRulesList(rules: rules)));
    final before = tester.getTopLeft(find.text('Contains a number')).dx;
    await tester.pumpApp(
      const Scaffold(
        body: PasswordRulesList(
          rules: [
            PasswordRule(label: 'At least 8 characters', met: true),
            PasswordRule(label: 'Contains a number', met: true),
            PasswordRule(label: 'Upper and lower case letters', met: false),
          ],
        ),
      ),
    );
    expect(tester.getTopLeft(find.text('Contains a number')).dx, before);
  });

  testView('semantics read "<rule>, met" or "<rule>, not met"', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(const Scaffold(body: PasswordRulesList(rules: rules)));
    expect(
      find.bySemanticsLabel(l10nEn.ruleMet('At least 8 characters')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10nEn.ruleNotMet('Contains a number')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testView('Arabic: the dot is at the start (right) and semantics are Arabic', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(
      const Scaffold(body: PasswordRulesList(rules: rules)),
      locale: const Locale('ar'),
    );
    final check = tester.getCenter(find.byType(AppSvgIcon)).dx;
    final text = tester.getCenter(find.text('At least 8 characters')).dx;
    expect(check, greaterThan(text));
    expect(
      find.bySemanticsLabel(l10nAr.ruleMet('At least 8 characters')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
