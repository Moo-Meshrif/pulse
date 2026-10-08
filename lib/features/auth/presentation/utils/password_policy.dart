/// Password rules shared by the sign-up meter (S3) and the reset screen (S11)
/// (docs/specs/auth/02-components.md C8, C8b).
abstract final class PasswordPolicy {
  static const minLength = 8;

  static bool hasMinLength(String password) => password.length >= minLength;

  static bool hasDigit(String password) => RegExp(r'\d').hasMatch(password);

  static bool hasMixedCase(String password) =>
      RegExp(r'[a-z]').hasMatch(password) &&
      RegExp(r'[A-Z]').hasMatch(password);

  static bool hasSymbol(String password) =>
      RegExp(r'[^A-Za-z0-9\s]').hasMatch(password);

  /// The strength meter score: how many of length >= 8, lower + upper case, a digit and
  /// a symbol the password has (0 to 4).
  static int score(String password) => [
    hasMinLength(password),
    hasMixedCase(password),
    hasDigit(password),
    hasSymbol(password),
  ].where((met) => met).length;

  /// The reset screen's three rules (length, digit, upper + lower case) are all met.
  static bool meetsResetRules(String password) =>
      hasMinLength(password) && hasDigit(password) && hasMixedCase(password);
}
