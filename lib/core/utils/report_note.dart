/// The "Something else" note of a report.
abstract final class ReportNote {
  static const minLength = 5;
  static const maxLength = 500;

  /// Enough text to send: [minLength] characters once the ends are trimmed.
  static bool canSend(String text) => text.trim().length >= minLength;

  static bool isAtLimit(String text) => text.length >= maxLength;
}
