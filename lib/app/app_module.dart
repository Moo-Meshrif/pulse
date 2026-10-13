import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/router/recovery_link_handler.dart';
import '../core/router/session_guard.dart';
import '../features/auth/domain/use_case/watch_password_recovery_use_case.dart';
import '../features/auth/domain/use_case/watch_session_ended_use_case.dart';

/// Registers third-party / app-level instances that can't be annotated directly.
@module
abstract class AppModule {
  /// Resolved before the first frame: the start-up route depends on the "seen onboarding" flag.
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// The Supabase client. `main()` initializes Supabase (which restores the stored session) before the
  /// container is built; tests that do not touch the backend never resolve this.
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// The app's one Navigator, so code outside the widget tree can navigate. `App` hands it to `MaterialApp`.
  @lazySingleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  /// Sends the user to Sign in when the session ends by itself. Built here, not in `core`, because it
  /// reads an `auth` use case.
  @LazySingleton(dispose: disposeSessionGuard)
  SessionGuard sessionGuard(
    GlobalKey<NavigatorState> navigatorKey,
    WatchSessionEndedUseCase sessionEnded,
  ) => SessionGuard(navigatorKey, sessionEnded: sessionEnded());

  /// Opens the reset screen from the emailed link, or says the link no longer works.
  @LazySingleton(dispose: disposeRecoveryLinkHandler)
  RecoveryLinkHandler recoveryLinkHandler(
    GlobalKey<NavigatorState> navigatorKey,
    WatchPasswordRecoveryUseCase recovery,
  ) => RecoveryLinkHandler(navigatorKey, recovery: recovery());
}

Future<void> disposeSessionGuard(SessionGuard guard) => guard.dispose();

Future<void> disposeRecoveryLinkHandler(RecoveryLinkHandler handler) =>
    handler.dispose();
