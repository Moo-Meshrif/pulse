import 'package:flutter/material.dart';

import '../../features/auth/presentation/screen/forgot_password_screen.dart';
import '../../features/auth/presentation/screen/legal_placeholder_screen.dart';
import '../../features/auth/presentation/screen/sign_in_screen.dart';
import '../../features/auth/presentation/utils/enums/legal_document.dart';
import '../../features/splash/presentation/screen/splash_screen.dart';
import '../../features/onboarding/data/datasource/onboarding_datasource.dart';
import '../../features/onboarding/presentation/screen/onboarding_screen.dart';
import '../di/injection.dart';
import 'app_routes.dart';
import 'not_found_screen.dart';
import 'placeholder_screen.dart';

abstract final class AppRouter {
  /// Every route in the app is resolved here — from `pushNamed` calls and from deep links.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final path = Uri.parse(settings.name ?? AppRoutes.root).path;

    return switch (path) {
      AppRoutes.root => _root(settings),
      AppRoutes.onboarding => _page(settings, const OnboardingScreen()),
      AppRoutes.signIn => _page(settings, const SignInScreen()),
      AppRoutes.register => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.register),
      ),
      AppRoutes.forgotPassword => _page(settings, const ForgotPasswordScreen()),
      AppRoutes.resetPassword => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.resetPassword),
      ),
      AppRoutes.terms => _page(
        settings,
        const LegalPlaceholderScreen(kind: LegalDocument.terms),
      ),
      AppRoutes.privacy => _page(
        settings,
        const LegalPlaceholderScreen(kind: LegalDocument.privacy),
      ),
      AppRoutes.home => _page(
        settings,
        const PlaceholderScreen(route: AppRoutes.home),
      ),
      _ => _page(settings, const NotFoundScreen()),
    };
  }

  /// First launch shows onboarding; afterwards the splash screen picks Sign in, Home or the sign-up step
  /// to resume from the stored session (it needs a request, so it cannot be decided here).
  static Route<dynamic> _root(RouteSettings settings) {
    final seen = getIt<OnboardingDatasource>().isSeen;
    return seen
        ? _page(settings, const SplashScreen())
        : onGenerateRoute(const RouteSettings(name: AppRoutes.onboarding));
  }

  /// A deep link must open exactly that screen, not every parent route before it.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
    onGenerateRoute(RouteSettings(name: initialRoute)),
  ];

  static Route<T> _page<T>(RouteSettings settings, Widget screen) =>
      MaterialPageRoute<T>(settings: settings, builder: (_) => screen);
}
