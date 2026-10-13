import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/app_config.dart';
import 'core/di/injection.dart';
import 'core/error/error_reporter.dart';
import 'core/error/guard.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/session_events.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Framework errors (build, layout, paint, gestures)
  FlutterError.onError = (details) {
    FlutterError.presentError(
      details,
    ); // keeps the red screen + console output in debug
    ErrorReporter.report(
      details.exception,
      details.stack ?? StackTrace.current,
      fatal: true,
    );
  };
  // Uncaught async and platform-channel errors
  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorReporter.report(error, stack, fatal: true);
    return true; // handled: don't crash the isolate
  };
  // Release: a neutral widget instead of the grey error box
  if (kReleaseMode) ErrorWidget.builder = (_) => const SizedBox.shrink();

  // Restores the stored session, which the start-up route reads.
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );
  await configureDependencies();
  // `Guard` is static, so DI cannot inject into it: its hooks are set here once the container is built.
  Guard.isOffline = getIt<ConnectivityService>().isOffline;
  Guard.onSessionRevoked = getIt<SessionEvents>().revoked;
  runApp(const App());
}
