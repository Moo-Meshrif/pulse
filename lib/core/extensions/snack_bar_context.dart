import 'package:flutter/material.dart';

import '../error/failures.dart';
import '../widgets/app_text.dart';
import 'failure_l10n.dart';

/// The app's one way to show a transient message: replaces any snackbar already on screen.
extension SnackBarContext on BuildContext {
  /// Does nothing when [message] is null. With [actionLabel] and [onAction] the notice carries one action
  /// ("Undo", "Retry").
  void showSnackBar(
    String? message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(this)
        .showNotice(message, actionLabel: actionLabel, onAction: onAction);
  }

  /// Words [failure] with `Failure.l10n` and shows it; does nothing when it is null.
  void showFailure(Failure? failure) => showSnackBar(failure?.l10n(this));
}

/// The same notice from a messenger kept before an `await`, for a screen that may be gone by then.
extension NoticeMessenger on ScaffoldMessengerState {
  void showNotice(
    String? message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (message == null) return;
    this
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(message),
          action: actionLabel == null || onAction == null
              ? null
              : SnackBarAction(label: actionLabel, onPressed: onAction),
        ),
      );
  }
}
