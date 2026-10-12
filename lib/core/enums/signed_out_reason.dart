/// Why a session ended, as Sign in words it (docs/specs/auth/screens/s14-signin-signed-out.md). The name
/// is the `reason` value of `/sign-in?reason=…`.
enum SignedOutReason {
  /// The session ran out.
  expired,

  /// It was ended elsewhere: another device, or a password change.
  revoked;

  /// An unknown or missing value is no reason at all (plain Sign in).
  static SignedOutReason? fromParam(String? value) {
    for (final reason in values) {
      if (reason.name == value) return reason;
    }
    return null;
  }
}
