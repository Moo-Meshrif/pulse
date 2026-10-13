import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/signed_out_reason.dart';
import 'app_navigator.dart';
import 'app_routes.dart';

/// Sends the user to Sign in when the session ends by itself (expired, revoked), from any screen.
/// The app shell feeds it the stream, so `core` never imports a feature. It is also a
/// [NavigatorObserver] (add it to `MaterialApp.navigatorObservers`) to act on an ending it had to hold.
class SessionGuard extends NavigatorObserver {
  SessionGuard(
    this._navigatorKey, {
    required Stream<SignedOutReason> sessionEnded,
  }) {
    _subscription = sessionEnded.listen(_onSessionEnded);
  }

  final GlobalKey<NavigatorState> _navigatorKey;
  late final StreamSubscription<SignedOutReason> _subscription;
  bool _disposed = false;

  /// An ending that arrived while the splash was deciding the first route.
  SignedOutReason? _held;

  /// Screens that handle a dead session themselves or must not be interrupted: onboarding and the reset
  /// and sign-up flows keep their input, Sign in is where it goes. The splash (`root`) is not here: it
  /// routes to Sign in itself when its own request fails, so the ending is held until it picks a route.
  static const keepsScreen = {
    AppRoutes.root,
    AppRoutes.onboarding,
    AppRoutes.signIn,
    AppRoutes.register,
    AppRoutes.resetPassword,
  };

  static String _pathOf(String? name) => Uri.parse(name ?? AppRoutes.root).path;

  void _onSessionEnded(SignedOutReason reason) {
    if (_disposed) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // An ending reported before the first frame, when there is no Navigator yet.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _onSessionEnded(reason),
      );
      return;
    }
    final path = _pathOf(AppNavigator.currentRouteName(navigator));
    if (path == AppRoutes.root) {
      _held = reason;
    } else if (!keepsScreen.contains(path)) {
      _signIn(navigator, reason);
    }
  }

  // The splash replaced itself with a route. Sign in and the other kept screens already know the session
  // is gone; any other route (Home) was picked without knowing, so the held ending applies to it.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _onRouteShown(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _onRouteShown(newRoute);

  void _onRouteShown(Route<dynamic>? route) {
    final reason = _held;
    if (reason == null) return;
    final path = _pathOf(route?.settings.name);
    if (path == AppRoutes.root) return;
    _held = null;
    if (keepsScreen.contains(path)) return;
    // Not inside the push that is still being observed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (!_disposed && navigator != null) _signIn(navigator, reason);
    });
  }

  void _signIn(NavigatorState navigator, SignedOutReason reason) => navigator
      .pushNamedAndRemoveUntil(AppRoutes.signInWith(reason), (_) => false);

  Future<void> dispose() {
    if (_disposed) return Future<void>.value();
    _disposed = true;
    // Takes effect at once; not awaited, so a container reset never waits on it.
    unawaited(_subscription.cancel());
    return Future<void>.value();
  }
}
