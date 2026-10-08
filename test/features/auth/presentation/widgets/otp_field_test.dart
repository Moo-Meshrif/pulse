import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/features/auth/presentation/widgets/otp_field.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Future<TextEditingController> pump(
    WidgetTester tester, {
    String? errorText,
    ValueChanged<String>? onCompleted,
    Locale locale = const Locale('en'),
    double width = 390,
  }) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpApp(
      Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: OtpField(
                controller: controller,
                errorText: errorText,
                onCompleted: onCompleted,
              ),
            ),
          ),
        ),
      ),
      locale: locale,
      settle: false, // the autofocused field blinks its cursor forever
    );
    return controller;
  }

  PinTheme theme(WidgetTester tester, PinTheme? Function(Pinput) pick) =>
      pick(tester.widget<Pinput>(find.byType(Pinput)))!;

  testView('six boxes, numeric keyboard, one-time-code autofill', (
    tester,
  ) async {
    await pump(tester);
    final pinput = tester.widget<Pinput>(find.byType(Pinput));
    expect(pinput.length, 6);
    expect(pinput.keyboardType, TextInputType.number);
    expect(pinput.autofillHints, contains(AutofillHints.oneTimeCode));
    expect(pinput.autofocus, isTrue);
  });

  testView('boxes are 50 x 60 with an 8 gap, radius 14, white', (tester) async {
    await pump(tester);
    final idle = theme(tester, (p) => p.defaultPinTheme);
    expect(idle.width, 50);
    expect(idle.height, 60);
    final decoration = idle.decoration!;
    expect(decoration.color, colors.surface);
    expect(decoration.borderRadius, BorderRadius.circular(14));
    expect(idle.textStyle!.fontSize, 24);
    expect(idle.textStyle!.fontFamily, 'Sora');
  });

  testView(
    'borders: idle 1, filled 1.5 primary, focused 2 textPrimary, error 1.5 danger',
    (tester) async {
      await pump(tester);
      Border border(PinTheme? t) => t!.decoration!.border! as Border;
      final pinput = tester.widget<Pinput>(find.byType(Pinput));
      expect(border(pinput.defaultPinTheme).top.color, colors.border);
      expect(border(pinput.defaultPinTheme).top.width, 1);
      expect(border(pinput.submittedPinTheme).top.color, colors.primary);
      expect(border(pinput.submittedPinTheme).top.width, 1.5);
      expect(border(pinput.focusedPinTheme).top.color, colors.textPrimary);
      expect(border(pinput.focusedPinTheme).top.width, 2);
      expect(border(pinput.errorPinTheme).top.color, colors.danger);
      expect(border(pinput.errorPinTheme).top.width, 1.5);
    },
  );

  testView('typing six digits completes; the controller keeps them', (
    tester,
  ) async {
    String? done;
    final controller = await pump(tester, onCompleted: (v) => done = v);
    await tester.enterText(find.byType(EditableText), '123456');
    await tester.pump();
    expect(controller.text, '123456');
    expect(done, '123456');
  });

  testView('a wrong code shows the message below and turns the boxes danger', (
    tester,
  ) async {
    await pump(tester, errorText: l10nEn.skip);
    expect(find.text(l10nEn.skip), findsOneWidget);
    expect(tester.widget<Pinput>(find.byType(Pinput)).forceErrorState, isTrue);
  });

  testView('boxes shrink on a narrow width but stay at least 44 wide', (
    tester,
  ) async {
    await pump(tester, width: 320);
    expect(tester.takeException(), isNull);
    final idle = theme(tester, (p) => p.defaultPinTheme);
    expect(idle.width, greaterThanOrEqualTo(44));
    expect(idle.width, lessThan(50));
  });

  testView('stays left-to-right in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'));
    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.byType(Pinput),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.ltr);
  });

  testView('semantics name the box being filled: "Digit N of 6"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = await pump(tester);
    expect(find.bySemanticsLabel(l10nEn.otpDigit(1)), findsWidgets);
    controller.text = '123';
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp(RegExp.escape(l10nEn.otpDigit(4)))),
      findsWidgets,
    );
    handle.dispose();
  });
}
