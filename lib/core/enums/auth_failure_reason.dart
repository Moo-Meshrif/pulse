/// Why an auth request was refused. Carried by `AuthFailure`; presentation words it
/// (`failure.l10n(context)`), never core or data.
enum AuthFailureReason {
  /// Wrong email / username or password (an unknown username is the same, so it never leaks).
  invalidCredentials,

  /// The email has not been verified yet: sign-in goes to the verify step.
  emailNotConfirmed,

  /// An account with this email already exists.
  emailTaken,

  /// No account has this email (forgot password).
  accountNotFound,

  /// The verification code is wrong or expired.
  invalidCode,

  /// The password does not meet the server's rules.
  weakPassword,

  /// The new password equals the old one.
  samePassword,

  /// Too many emails or requests; try later.
  rateLimited,

  /// Too many sign-in attempts from this device or for this account: wait `AuthFailure.retryAfter`.
  tooManyAttempts,

  /// The server could not send the verification or reset email (mail provider problem).
  emailSendFailed,

  /// No valid session (signed out, expired or revoked).
  sessionExpired,
}
