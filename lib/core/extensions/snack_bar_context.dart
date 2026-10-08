import 'package:flutter/material.dart';

import '../error/failures.dart';
import '../widgets/app_text.dart';
import 'failure_l10n.dart';

/// The app's one way to show a transient message: replaces any snackbar already on screen.
extension SnackBarContext on BuildContext {
  /// Does nothing when [message] is null.
  void showSnackBar(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: AppText(message)));
  }

  /// Words [failure] with `Failure.l10n` and shows it; does nothing when it is null.
  void showFailure(Failure? failure) => showSnackBar(failure?.l10n(this));
}
