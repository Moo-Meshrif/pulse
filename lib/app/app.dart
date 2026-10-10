import 'dart:async';

import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/extensions/l10n.dart';
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

  @override
  void initState() {
    super.initState();
    // The emailed reset link opens the app (or brings it forward) with a recovery session.
    _recovery = getIt<WatchPasswordRecoveryUseCase>()().listen((_) {
      final navigator = _navigator.currentState;
      if (navigator != null) {
        AppNavigator.resetToUnlessCurrent(navigator, AppRoutes.resetPassword);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_recovery.cancel());
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
