import 'package:flutter/material.dart';

import '../../features/onboarding/data/datasource/onboarding_datasource.dart';
import '../../features/onboarding/presentation/screen/onboarding_screen.dart';
import '../di/injection.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';
import 'placeholder_screen.dart';

abstract final class AppRouter {
  /// Every route in the app is resolved here — from `pushNamed` calls and from deep links.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? AppRoutes.root);

    return switch (uri.pathSegments) {
      [] => _startup(settings),
      ['onboarding'] => _page(settings, const OnboardingScreen()),
      ['sign-in'] => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.signIn),
      ),
      ['register'] => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.register),
      ),
      _ => _page(settings, const NotFoundScreen()),
    };
  }

  /// First launch shows onboarding; once it has been finished, the app starts at Sign in.
  static Route<dynamic> _startup(RouteSettings settings) {
    final seen = getIt<OnboardingDatasource>().isSeen;
    return onGenerateRoute(
      RouteSettings(name: seen ? AppRoutes.signIn : AppRoutes.onboarding),
    );
  }

  /// A deep link must open exactly that screen, not every parent route before it.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(RouteSettings(name: initialRoute)),
  ];

  static Route<T> _page<T>(RouteSettings settings, Widget screen) =>
      MaterialPageRoute<T>(settings: settings, builder: (_) => screen);
}
