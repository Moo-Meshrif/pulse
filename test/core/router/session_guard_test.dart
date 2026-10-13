import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/signed_out_reason.dart';
import 'package:pulse/core/router/app_navigator.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/router/session_guard.dart';

void main() {
  late GlobalKey<NavigatorState> key;
  late StreamController<SignedOutReason> ended;
  late SessionGuard guard;

  setUp(() {
    key = GlobalKey<NavigatorState>();
    ended = StreamController<SignedOutReason>();
    guard = SessionGuard(key, sessionEnded: ended.stream);
  });

  tearDown(() async {
    await guard.dispose();
    unawaited(ended.close()); // awaiting it hangs once the guard has cancelled
  });

  Route<void> route(RouteSettings settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(body: Text('screen ${settings.name}')),
  );

  Future<void> pumpShell(WidgetTester tester, {String initial = '/'}) =>
      tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          navigatorObservers: [guard],
          initialRoute: initial,
          onGenerateInitialRoutes: (name) => [route(RouteSettings(name: name))],
          onGenerateRoute: route,
        ),
      );

  String? shown() => AppNavigator.currentRouteName(key.currentState!);

  Future<void> end(WidgetTester tester, SignedOutReason reason) async {
    ended.add(reason);
    await tester.pump();
    await tester.pump();
  }

  void go(String route) =>
      key.currentState!.pushNamedAndRemoveUntil(route, (_) => false);

  group('a screen that can be interrupted', () {
    testWidgets('goes to Sign in with the reason and clears the stack', (
      tester,
    ) async {
      await pumpShell(tester, initial: AppRoutes.home);
      key.currentState!.pushNamed('/profile');
      await tester.pumpAndSettle();

      await end(tester, SignedOutReason.revoked);
      await tester.pumpAndSettle();

      expect(shown(), AppRoutes.signInWith(SignedOutReason.revoked));
      expect(key.currentState!.canPop(), isFalse);
    });
  });

  group('a screen that keeps itself', () {
    for (final route in [
      AppRoutes.onboarding,
      AppRoutes.signIn,
      AppRoutes.register,
      AppRoutes.registerAt(3),
      AppRoutes.resetPassword,
    ]) {
      testWidgets(route, (tester) async {
        await pumpShell(tester, initial: route);

        await end(tester, SignedOutReason.expired);
        await tester.pumpAndSettle();

        expect(shown(), route);
      });
    }
  });

  group('while the splash is deciding', () {
    testWidgets('the ending is held, then applies to a route it picks', (
      tester,
    ) async {
      await pumpShell(tester);

      await end(tester, SignedOutReason.expired);
      expect(shown(), AppRoutes.root);

      go(AppRoutes.home);
      await tester.pumpAndSettle();

      expect(shown(), AppRoutes.signInWith(SignedOutReason.expired));
    });

    testWidgets('a route that already knows (Sign in) clears it', (
      tester,
    ) async {
      await pumpShell(tester);
      await end(tester, SignedOutReason.expired);

      go(AppRoutes.signInWith(SignedOutReason.revoked));
      await tester.pumpAndSettle();
      go(AppRoutes.home); // signed in again later
      await tester.pumpAndSettle();

      expect(shown(), AppRoutes.home);
    });
  });

  group('before the first frame', () {
    testWidgets('the ending waits for the Navigator', (tester) async {
      ended.add(SignedOutReason.revoked);
      await tester.pump();
      expect(key.currentState, isNull);

      await pumpShell(tester, initial: AppRoutes.home);
      await tester.pumpAndSettle();

      expect(shown(), AppRoutes.signInWith(SignedOutReason.revoked));
    });
  });

  testWidgets('after dispose an ending does nothing', (tester) async {
    await pumpShell(tester, initial: AppRoutes.home);
    await tester.runAsync(guard.dispose);

    ended.add(SignedOutReason.expired);
    await tester.pumpAndSettle();

    expect(shown(), AppRoutes.home);
  });
}
