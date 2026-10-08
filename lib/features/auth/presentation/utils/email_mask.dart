/// Masks an email for display: `dip•••@gmail.com`; a local part under 3 characters is shown whole
/// (docs/specs/auth/screens/s4-signup-verify-email.md).
String maskEmail(String email) {
  final at = email.indexOf('@');
  if (at < 0) return email;
  final local = email.substring(0, at);
  final domain = email.substring(at);
  final shown = local.length < 3 ? local : local.substring(0, 3);
  return '$shown•••$domain';
}
