import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/onboarding/presentation/widgets/sign_in_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/pump_app.dart';

String? _route(WidgetTester t) =>
    ModalRoute.of(t.element(find.byType(Scaffold).first))?.settings.name;

Future<bool> _seenFlag() async =>
    (await SharedPreferences.getInstance()).getBool('onboarding_seen') ?? false;

/// The footer is part of each page's scroll view and is built lazily: scroll until it exists and is visible.
Future<void> _reveal(WidgetTester t, Finder finder) async {
  await t.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await t.pumpAndSettle();
}

Future<void> _next(WidgetTester t) async {
  await _reveal(t, find.text(l10nEn.next));
  await t.tap(find.text(l10nEn.next));
  await t.pumpAndSettle();
}

void main() {
  group('start-up', () {
    testWidgets('a first launch shows onboarding', (t) async {
      setUpView(t);
      await t.bootApp();

      expect(_route(t), AppRoutes.onboarding);
      expect(find.text(l10nEn.onboarding1Title), findsOneWidget);
    });

    testWidgets('once onboarding was seen the app starts at Sign in', (
      t,
    ) async {
      setUpView(t);
      await t.bootApp(prefs: {'onboarding_seen': true});

      expect(_route(t), AppRoutes.signIn);
      expect(find.text(l10nEn.onboarding1Title), findsNothing);
    });

    testWidgets(
      'a device language the app does not ship falls back to English, left to right',
      (t) async {
        setUpView(t, deviceLocale: const Locale('fr'));
        await t.bootApp();

        expect(find.text(l10nEn.skip), findsOneWidget);
        expect(
          Directionality.of(t.element(find.byType(Scaffold).first)),
          TextDirection.ltr,
        );
      },
    );

    testWidgets('an Arabic device shows the Arabic strings, right to left', (
      t,
    ) async {
      setUpView(t, deviceLocale: const Locale('ar'));
      await t.bootApp();

      expect(find.text(l10nAr.onboarding1Title), findsOneWidget);
      expect(find.text(l10nAr.skip), findsOneWidget);
      expect(
        Directionality.of(t.element(find.byType(Scaffold).first)),
        TextDirection.rtl,
      );
    });
  });

  group('leaving onboarding', () {
    testWidgets(
      'Skip on S1 goes to Sign in and records the flag; a relaunch skips onboarding',
      (t) async {
        setUpView(t);
        await t.bootApp();

        await t.tap(find.text(l10nEn.skip));
        await t.pumpAndSettle();
        expect(_route(t), AppRoutes.signIn);
        expect(await _seenFlag(), isTrue);

        await t.bootApp(prefs: {'onboarding_seen': true});
        expect(_route(t), AppRoutes.signIn);
      },
    );

    testWidgets('Skip on S2 goes to Sign in', (t) async {
      setUpView(t);
      await t.bootApp();
      await _next(t);

      await t.tap(find.text(l10nEn.skip));
      await t.pumpAndSettle();

      expect(_route(t), AppRoutes.signIn);
      expect(await _seenFlag(), isTrue);
    });

    testWidgets('Get started goes to Registration and records the flag', (
      t,
    ) async {
      setUpView(t);
      await t.bootApp();
      await _next(t);
      await _next(t);

      await _reveal(t, find.text(l10nEn.getStarted));

      await t.tap(find.text(l10nEn.getStarted));
      await t.pumpAndSettle();

      expect(_route(t), AppRoutes.register);
      expect(await _seenFlag(), isTrue);
    });

    testWidgets('the Sign in link goes to Sign in and records the flag', (
      t,
    ) async {
      setUpView(t);
      await t.bootApp();
      await _next(t);
      await _next(t);

      await _reveal(t, find.byType(SignInLink));
      await t.tap(find.byType(SignInLink));
      await t.pumpAndSettle();

      expect(_route(t), AppRoutes.signIn);
      expect(await _seenFlag(), isTrue);
    });

    testWidgets('Back after leaving onboarding does not return to it', (
      t,
    ) async {
      setUpView(t);
      await t.bootApp();
      await t.tap(find.text(l10nEn.skip));
      await t.pumpAndSettle();

      await t.binding.handlePopRoute();
      await t.pumpAndSettle();

      expect(find.text(l10nEn.onboarding1Title), findsNothing);
    });
  });
}
