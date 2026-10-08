import 'package:flutter/material.dart';

import '../core/extensions/l10n.dart';
import '../core/router/app_router.dart';
import '../core/router/app_routes.dart';
import '../core/theme/app_scale.dart';
import '../core/theme/app_scroll_behavior.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/widgets.dart';

class App extends StatelessWidget {
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
  Widget build(BuildContext context) => AppScaleScope(
    builder: (context) => MaterialApp(
      // Fonts are already scaled by AppScale; cap the user's text scale so the two together stay <= 2.0x.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: AppScale.maxSystemTextScale,
        child: child!,
      ),
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: _resolveLocale,
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onGenerateInitialRoutes: AppRouter.onGenerateInitialRoutes,
    ),
  );
}
