import 'dart:async';

import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/enums/signed_out_reason.dart';
import '../features/auth/domain/use_case/watch_session_ended_use_case.dart';
import '../core/extensions/l10n.dart';
import '../core/extensions/snack_bar_context.dart';
import '../features/auth/data/enums/recovery_signal.dart';
import '../features/auth/domain/use_case/watch_password_recovery_use_case.dart';
import '../core/router/app_navigator.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../core/utils/country_names_delegate.dart';
import '../core/theme/app_scale.dart';
import '../core/theme/app_scroll_behavior.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/widgets.dart';

class App extends StatefulWidget {
  const App({super.key});

  /// A device language the app does not ship falls back to English. Without this,
  /// Flutter falls back to the first supported locale, which is `ar` (alphabetical order).
  static Locale _resolveLocale(Locale? device, Iterable<Locale> supported) {
    for (final locale in supported) {
      if (locale.languageCode == device?.languageCode) return locale;
    }
    return const Locale('en');
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigator = GlobalKey<NavigatorState>();
  late final StreamSubscription<Object?> _recovery;
  late final StreamSubscription<SignedOutReason> _sessionEnded;

  @override
  void initState() {
    super.initState();
    // The emailed reset link opens the app (or brings it forward) with a recovery session, or is refused
    // (expired, already used).
    _recovery = getIt<WatchPasswordRecoveryUseCase>()().listen(_onRecovery);
    _sessionEnded = getIt<WatchSessionEndedUseCase>()().listen(_onSessionEnded);
  }

  /// Screens that handle a dead session themselves or must not be interrupted: the splash decides its own
  /// route, onboarding and the reset and sign-up flows keep their input, Sign in is where it goes.
  static const _keepsScreen = {
    AppRoutes.root,
    AppRoutes.onboarding,
    AppRoutes.signIn,
    AppRoutes.register,
    AppRoutes.resetPassword,
  };

  void _onSessionEnded(SignedOutReason reason) {
    final navigator = _navigator.currentState;
    if (navigator == null) return;
    final shown = AppNavigator.currentRouteName(navigator);
    if (_keepsScreen.contains(Uri.parse(shown ?? AppRoutes.root).path)) return;
    navigator.pushNamedAndRemoveUntil(
      AppRoutes.signInWith(reason),
      (_) => false,
    );
  }

  void _onRecovery(RecoverySignal signal) {
    final navigator = _navigator.currentState;
    if (navigator == null) return;
    switch (signal) {
      case RecoverySignal.started:
        AppNavigator.resetToUnlessCurrent(navigator, AppRoutes.resetPassword);
      case RecoverySignal.linkFailed:
        // The user stays where they are; only a message says the link no longer works.
        _showLinkExpired();
    }
  }

  /// A link that cold-starts the app is reported before the first frame, when there is no screen to
  /// show a message on yet.
  void _showLinkExpired() {
    final context = _navigator.currentContext;
    if (context != null) {
      context.showSnackBar(context.l10n.linkExpiredSnackBar);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLinkExpired());
    }
  }

  @override
  void dispose() {
    unawaited(_recovery.cancel());
    unawaited(_sessionEnded.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppScaleScope(
    builder: (context) => MaterialApp(
      navigatorKey: _navigator,
      // Fonts are already scaled by AppScale; cap the user's text scale so the two together stay <= 2.0x.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: AppScale.maxSystemTextScale,
        child: child!,
      ),
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light,
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        CountryNamesDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: App._resolveLocale,
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    ),
  );
}
