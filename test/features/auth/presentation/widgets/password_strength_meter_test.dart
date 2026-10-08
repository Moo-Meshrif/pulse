import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/widgets/password_strength_meter.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  List<Color?> segmentColors(WidgetTester tester) => [
    for (final c in tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    ))
      (c.decoration! as BoxDecoration).color,
  ];

  Future<void> pump(
    WidgetTester tester,
    String password, {
    bool compact = false,
    Locale locale = const Locale('en'),
  }) => tester.pumpApp(
    Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: PasswordStrengthMeter(password: password, compact: compact),
      ),
    ),
    locale: locale,
  );

  testView('hidden until the password has a score', (tester) async {
    await pump(tester, '');
    expect(find.byType(AnimatedContainer), findsNothing);
    await pump(tester, 'abc');
    expect(find.byType(AnimatedContainer), findsNothing);
  });

  testView('Good: 3 primary segments, 1 grey, and the word', (tester) async {
    await pump(tester, 'abcdefH1');
    expect(segmentColors(tester), [
      colors.primary,
      colors.primary,
      colors.primary,
      colors.switchOff,
    ]);
    expect(find.text(l10nEn.strengthGood), findsOneWidget);
  });

  testView('Weak is danger, Fair is warning, Strong fills all four', (
    tester,
  ) async {
    await pump(tester, 'abcdefgh');
    expect(segmentColors(tester).first, colors.danger);
    expect(find.text(l10nEn.strengthWeak), findsOneWidget);

    await pump(tester, 'abcdefgH');
    expect(segmentColors(tester).take(2), everyElement(colors.warning));
    expect(find.text(l10nEn.strengthFair), findsOneWidget);

    await pump(tester, 'abcdefH1!');
    expect(segmentColors(tester), everyElement(colors.primary));
    expect(find.text(l10nEn.strengthStrong), findsOneWidget);
  });

  testView('the segments are 4 high with a 6 gap and span the width', (
    tester,
  ) async {
    await pump(tester, 'abcdefH1');
    final rects = tester
        .widgetList(find.byType(AnimatedContainer))
        .map((w) => tester.getRect(find.byWidget(w)))
        .toList();
    expect(rects.first.height, 4);
    expect(rects[1].left - rects[0].right, closeTo(6, 0.5));
  });

  testView('semantics: "Password strength: Good"', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, 'abcdefH1');
    expect(
      find.bySemanticsLabel(l10nEn.passwordStrength(l10nEn.strengthGood)),
      findsOneWidget,
    );
    handle.dispose();
  });

  testView('Arabic: Arabic word and label', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, 'abcdefH1', locale: const Locale('ar'));
    expect(find.text(l10nAr.strengthGood), findsOneWidget);
    expect(
      find.bySemanticsLabel(l10nAr.passwordStrength(l10nAr.strengthGood)),
      findsOneWidget,
    );
    handle.dispose();
  });

  testView('compact: always 4 short segments (68 wide, gap 4), no word', (
    tester,
  ) async {
    await pump(tester, '', compact: true);
    expect(segmentColors(tester), everyElement(colors.switchOff));
    final rects = tester
        .widgetList(find.byType(AnimatedContainer))
        .map((w) => tester.getRect(find.byWidget(w)))
        .toList();
    expect(rects, hasLength(4));
    expect(rects.first.width, 68);
    expect(rects[1].left - rects[0].right, closeTo(4, 0.5));

    await pump(tester, 'abcdefH1', compact: true);
    expect(find.text(l10nEn.strengthGood), findsNothing);
    expect(segmentColors(tester).first, colors.primary);
  });
}
