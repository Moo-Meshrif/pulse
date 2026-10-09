import 'package:flutter/material.dart';

/// The one navigation helper: screens never call `Navigator.of(context)` directly.
abstract final class AppNavigator {
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String route,
  ) => Navigator.of(context).pushNamed<T>(route);

  static Future<T?> replace<T extends Object?, R extends Object?>(
    BuildContext context,
    String route,
  ) => Navigator.of(context).pushReplacementNamed<T, R>(route);

  /// Clears the stack (e.g. after onboarding ends).
  static Future<T?> resetTo<T extends Object?>(
    BuildContext context,
    String route,
  ) => Navigator.of(context).pushNamedAndRemoveUntil<T>(route, (_) => false);

  static void back<T extends Object?>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop<T>(result);

  /// There is a screen below this one to go back to.
  static bool canBack(BuildContext context) => Navigator.of(context).canPop();

  /// Opens [route] on a clean stack from outside the widget tree (a deep link), unless it is already the
  /// screen being shown.
  static void resetToUnlessCurrent(NavigatorState navigator, String route) {
    var alreadyThere = false;
    navigator.popUntil((current) {
      alreadyThere = current.settings.name == route;
      return true;
    });
    if (!alreadyThere) {
      navigator.pushNamedAndRemoveUntil(route, (_) => false);
    }
  }
}
