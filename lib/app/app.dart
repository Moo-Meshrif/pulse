import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/di/injection.dart';
import '../core/extensions/l10n.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../core/router/recovery_link_handler.dart';
import '../core/router/session_guard.dart';
import '../core/theme/app_scale.dart';
import '../core/theme/app_scroll_behavior.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/country_names_delegate.dart';
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
  final _navigator = getIt<GlobalKey<NavigatorState>>();
  // A session that ends by itself (expired, revoked) sends the user to Sign in from any screen, except
  // the ones in `SessionGuard.keepsScreen`.
  final _sessionGuard = getIt<SessionGuard>();

  @override
  void initState() {
    super.initState();
    // Created here so it listens before the first frame: the emailed reset link opens the app (or brings
    // it forward) with a recovery session, or is refused (expired, already used).
    getIt<RecoveryLinkHandler>();
  }

  @override
  Widget build(BuildContext context) => AppScaleScope(
    builder: (context) => MaterialApp(
      navigatorKey: _navigator,
      navigatorObservers: [_sessionGuard],
      // Fonts are already scaled by AppScale; cap the user's text scale so the two together stay <= 2.0x.
      // Dark status bar icons by default (light theme); dark screens override with their own region.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: AppScale.maxSystemTextScale,
          child: child!,
        ),
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
