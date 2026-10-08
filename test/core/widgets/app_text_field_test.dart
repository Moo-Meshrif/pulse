import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  OutlineInputBorder enabledBorder(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).decoration!.enabledBorder
          as OutlineInputBorder;

  Widget host(Widget child) => Scaffold(
    body: Padding(padding: const EdgeInsets.all(24), child: child),
  );

  testView('shows the label and hint; a required label has a red *', (
    tester,
  ) async {
    await tester.pumpApp(
      host(
        const AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          required: true,
        ),
      ),
    );
    expect(find.text('you@example.com'), findsOneWidget);
    final label = tester.widget<RichText>(
      find.text('Email *', findRichText: true),
    );
    final spans = ((label.text as TextSpan).children!.first as TextSpan)
        .children!
        .cast<TextSpan>();
    expect(spans.first.text, 'Email');
    expect(spans.last.text, ' *');
    expect(spans.last.style!.color, colors.danger);
  });

  testView('field: white, radius 14, 1 px border; focus is primary 1.5', (
    tester,
  ) async {
    await tester.pumpApp(host(const AppTextField(label: 'Email')));
    final decoration = tester
        .widget<TextField>(find.byType(TextField))
        .decoration!;
    expect(decoration.fillColor, colors.surface);
    final border = enabledBorder(tester);
    expect(border.borderSide.color, colors.border);
    expect(border.borderSide.width, 1);
    expect(border.borderRadius, BorderRadius.circular(14));
    final focused = decoration.focusedBorder! as OutlineInputBorder;
    expect(focused.borderSide.color, colors.primary);
    expect(focused.borderSide.width, 1.5);
  });

  testView('an error replaces the helper and turns the border danger', (
    tester,
  ) async {
    await tester.pumpApp(
      host(
        const AppTextField(
          label: 'Username',
          helperText: 'Letters and numbers',
        ),
      ),
    );
    expect(find.text('Letters and numbers'), findsOneWidget);

    await tester.pumpApp(
      host(
        const AppTextField(
          label: 'Username',
          helperText: 'Letters and numbers',
          errorText: 'Username is taken',
        ),
      ),
    );
    expect(find.text('Letters and numbers'), findsNothing);
    expect(find.text('Username is taken'), findsOneWidget);
    expect(enabledBorder(tester).borderSide.color, colors.danger);
    expect(enabledBorder(tester).borderSide.width, 1.5);
  });

  testView('password: hidden by default, the eye toggles it, 44 tap target', (
    tester,
  ) async {
    await tester.pumpApp(
      host(const AppTextField(label: 'Password', isPassword: true)),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
    expect(find.bySemanticsLabel(l10nEn.showPassword), findsOneWidget);
    final eye = find.bySemanticsLabel(l10nEn.showPassword);
    expect(tester.getSize(eye).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(eye).height, greaterThanOrEqualTo(44));

    await tester.tap(eye);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    expect(find.bySemanticsLabel(l10nEn.hidePassword), findsOneWidget);
  });

  testView('the eye label is Arabic in Arabic', (tester) async {
    await tester.pumpApp(
      host(const AppTextField(label: 'كلمة المرور', isPassword: true)),
      locale: const Locale('ar'),
    );
    expect(find.bySemanticsLabel(l10nAr.showPassword), findsOneWidget);
  });

  testView('the eye is at the end: right in English, left in Arabic', (
    tester,
  ) async {
    await tester.pumpApp(
      host(const AppTextField(label: 'P', isPassword: true)),
    );
    final en = tester.getCenter(find.bySemanticsLabel(l10nEn.showPassword)).dx;
    expect(en, greaterThan(tester.view.physicalSize.width / 2));
    await tester.pumpApp(
      host(const AppTextField(label: 'P', isPassword: true)),
      locale: const Locale('ar'),
    );
    final ar = tester.getCenter(find.bySemanticsLabel(l10nAr.showPassword)).dx;
    expect(ar, lessThan(tester.view.physicalSize.width / 2));
  });

  testView('a prefix is shown before the hint', (tester) async {
    await tester.pumpApp(
      host(
        const AppTextField(
          label: 'Username',
          hint: 'username',
          prefixText: '@',
        ),
      ),
    );
    expect(find.text('@'), findsOneWidget);
    expect(find.text('username'), findsOneWidget);
  });

  testView('counter shows length/max and blocks input at the max', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpApp(
      host(
        AppTextField(
          label: 'Bio',
          controller: controller,
          counterMax: 5,
          minLines: 3,
          maxLines: 3,
        ),
      ),
    );
    expect(find.text('0/5'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abcdefgh');
    await tester.pump();
    expect(controller.text, 'abcde');
    expect(find.text('5/5'), findsOneWidget);
  });

  testView('a read-only field still reports taps (the birthday picker)', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      host(
        AppTextField(label: 'Birthday', readOnly: true, onTap: () => taps++),
      ),
    );
    await tester.tap(find.byType(TextField));
    expect(taps, 1);
  });

  testView('forceLtr keeps the text left-to-right in Arabic', (tester) async {
    await tester.pumpApp(
      host(const AppTextField(label: 'Email', forceLtr: true)),
      locale: const Locale('ar'),
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).textDirection,
      TextDirection.ltr,
    );
  });

  testView('keyboard type, action and autofill hints pass through', (
    tester,
  ) async {
    await tester.pumpApp(
      host(
        const AppTextField(
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: [AutofillHints.email],
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.keyboardType, TextInputType.emailAddress);
    expect(field.textInputAction, TextInputAction.next);
    expect(field.autofillHints, [AutofillHints.email]);
  });
}
