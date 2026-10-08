/// One line of the reset screen's rules list: its text and whether the password meets it.
class PasswordRule {
  const PasswordRule({required this.label, required this.met});

  final String label;
  final bool met;
}
