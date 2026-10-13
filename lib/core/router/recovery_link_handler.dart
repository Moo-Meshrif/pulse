import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/recovery_signal.dart';
import '../extensions/l10n.dart';
import '../extensions/snack_bar_context.dart';
import 'app_navigator.dart';
import 'app_routes.dart';

/// Reacts to the emailed reset link from outside the widget tree: opens the reset screen, or says the link
/// no longer works.
class RecoveryLinkHandler {
  RecoveryLinkHandler(
    this._navigatorKey, {
    required Stream<RecoverySignal> recovery,
  }) {
    _subscription = recovery.listen(_onRecovery);
  }

  final GlobalKey<NavigatorState> _navigatorKey;
  late final StreamSubscription<RecoverySignal> _subscription;
  bool _disposed = false;

  void _onRecovery(RecoverySignal signal) {
    if (_disposed) return;
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      // A link that cold-starts the app is reported before the first frame, when there is no Navigator yet.
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRecovery(signal));
      return;
    }
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
    if (_disposed) return;
    final context = _navigatorKey.currentContext;
    if (context != null) {
      context.showSnackBar(context.l10n.linkExpiredSnackBar);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showLinkExpired());
    }
  }

  Future<void> dispose() {
    if (_disposed) return Future<void>.value();
    _disposed = true;
    // Takes effect at once; not awaited, so a container reset never waits on it.
    unawaited(_subscription.cancel());
    return Future<void>.value();
  }
}
