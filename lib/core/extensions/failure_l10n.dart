import 'package:flutter/widgets.dart';

import '../enums/auth_failure_reason.dart';
import '../error/failures.dart';
import '../utils/format_countdown.dart';
import 'l10n.dart';

/// The one place a [Failure] becomes words for the user (a snackbar, a caption). Reasons without
/// their own text yet fall back to the generic message.
extension FailureL10n on Failure {
  String l10n(BuildContext context) {
    final l10n = context.l10n;
    return switch (this) {
      NetworkFailure() || TimeoutFailure() => l10n.errorNetwork,
      AuthFailure(reason: AuthFailureReason.invalidCredentials) =>
        l10n.errorCredentials,
      AuthFailure(reason: AuthFailureReason.accountNotFound) =>
        l10n.errorAccountNotFound,
      AuthFailure(
        :final retryAfter,
        reason: AuthFailureReason.tooManyAttempts,
      ) =>
        l10n.errorTooManyAttempts(
          formatCountdown(retryAfter ?? const Duration(minutes: 1)),
        ),
      AuthFailure(reason: AuthFailureReason.emailSendFailed) =>
        l10n.errorEmailSend,
      AuthFailure(reason: AuthFailureReason.rateLimited) =>
        l10n.errorRateLimited,
      AuthFailure(reason: AuthFailureReason.emailTaken) =>
        l10n.errorEmailExists,
      AuthFailure(reason: AuthFailureReason.invalidCode) => l10n.errorWrongCode,
      AuthFailure(reason: AuthFailureReason.weakPassword) =>
        l10n.errorWeakPassword,
      AuthFailure(reason: AuthFailureReason.samePassword) =>
        l10n.errorSamePassword,
      AuthFailure(reason: AuthFailureReason.sessionExpired) =>
        l10n.errorSessionExpired,
      ConflictFailure() => l10n.errorUsernameTaken,
      ServerFailure() => l10n.errorServer,
      _ => l10n.errorGeneric,
    };
  }
}
