import 'package:flutter/material.dart';

/// The one navigation helper: screens never call `Navigator.of(context)` directly.
abstract final class AppNavigator {
  /// Opens [route] on the nearest Navigator. [rootNavigator] opens it on the app's root Navigator instead:
  /// from inside a tab of the main shell it then covers the shell and its nav bar (story viewer, create
  /// flows) instead of opening inside the tab.
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String route, {
    bool rootNavigator = false,
    Object? arguments,
  }) => Navigator.of(
    context,
    rootNavigator: rootNavigator,
  ).pushNamed<T>(route, arguments: arguments);

  static Future<T?> replace<T extends Object?, R extends Object?>(
    BuildContext context,
    String route,
  ) => Navigator.of(context).pushReplacementNamed<T, R>(route);

  /// Clears the stack (e.g. after onboarding ends). [rootNavigator] clears the app's root Navigator, for
  /// leaving from inside a tab of the main shell (log out).
  static Future<T?> resetTo<T extends Object?>(
    BuildContext context,
    String route, {
    bool rootNavigator = false,
  }) => Navigator.of(
    context,
    rootNavigator: rootNavigator,
  ).pushNamedAndRemoveUntil<T>(route, (_) => false);

  static void back<T extends Object?>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop<T>(result);

  /// Closes screens until the one named [route] shows (or the first one).
  static void backTo(BuildContext context, String route) =>
      Navigator.of(context)
          .popUntil((r) => r.settings.name == route || r.isFirst);

  /// There is a screen below this one to go back to.
  static bool canBack(BuildContext context) => Navigator.of(context).canPop();

  /// The route shown now, from outside the widget tree.
  static String? currentRouteName(NavigatorState navigator) {
    String? name;
    navigator.popUntil((current) {
      name = current.settings.name;
      return true;
    });
    return name;
  }

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
