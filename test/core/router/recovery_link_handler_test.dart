import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/enums/recovery_signal.dart';
import 'package:pulse/core/router/app_navigator.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/router/recovery_link_handler.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../helpers/pump_app.dart';

void main() {
  late GlobalKey<NavigatorState> key;
  late StreamController<RecoverySignal> signals;
  late RecoveryLinkHandler handler;

  setUp(() {
    key = GlobalKey<NavigatorState>();
    signals = StreamController<RecoverySignal>();
    handler = RecoveryLinkHandler(key, recovery: signals.stream);
  });

  tearDown(() async {
    await handler.dispose();
    unawaited(
      signals.close(),
    ); // awaiting it hangs once the handler has cancelled
  });

  Route<void> route(RouteSettings settings) => MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(body: Text('screen ${settings.name}')),
  );

  Future<void> pumpShell(WidgetTester tester, {String initial = '/home'}) =>
      tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          initialRoute: initial,
          onGenerateInitialRoutes: (name) => [route(RouteSettings(name: name))],
          onGenerateRoute: route,
        ),
      );

  String? shown() => AppNavigator.currentRouteName(key.currentState!);

  Future<void> send(WidgetTester tester, RecoverySignal signal) async {
    signals.add(signal);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('started opens the reset screen on a clean stack', (
    tester,
  ) async {
    await pumpShell(tester);

    await send(tester, RecoverySignal.started);
    await tester.pumpAndSettle();

    expect(shown(), AppRoutes.resetPassword);
    expect(key.currentState!.canPop(), isFalse);
  });

  testWidgets('started on the reset screen does not open it again', (
    tester,
  ) async {
    await pumpShell(tester, initial: AppRoutes.resetPassword);

    await send(tester, RecoverySignal.started);
    await tester.pumpAndSettle();

    expect(shown(), AppRoutes.resetPassword);
    expect(key.currentState!.canPop(), isFalse);
  });

  testWidgets('linkFailed keeps the screen and shows the message', (
    tester,
  ) async {
    await pumpShell(tester);

    await send(tester, RecoverySignal.linkFailed);
    await tester.pump();

    expect(shown(), AppRoutes.home);
    expect(find.text(l10nEn.linkExpiredSnackBar), findsOneWidget);
  });

  group('before the first frame', () {
    testWidgets('started waits for the Navigator', (tester) async {
      signals.add(RecoverySignal.started);
      await tester.pump();
      expect(key.currentState, isNull);

      await pumpShell(tester);
      await tester.pumpAndSettle();

      expect(shown(), AppRoutes.resetPassword);
    });

    testWidgets('linkFailed waits for a screen to show the message on', (
      tester,
    ) async {
      signals.add(RecoverySignal.linkFailed);
      await tester.pump();

      await pumpShell(tester);
      await tester.pump();
      await tester.pump();

      expect(find.text(l10nEn.linkExpiredSnackBar), findsOneWidget);
    });
  });

  testWidgets('after dispose a signal does nothing', (tester) async {
    await pumpShell(tester);
    await tester.runAsync(handler.dispose);

    signals.add(RecoverySignal.started);
    await tester.pumpAndSettle();

    expect(shown(), AppRoutes.home);
  });
}
