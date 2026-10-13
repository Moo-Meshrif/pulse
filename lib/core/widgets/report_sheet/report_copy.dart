/// What the report sheet says about its target (a post, a story): the rest of the words are shared.
class ReportCopy {
  const ReportCopy({
    required this.title,
    required this.body,
    required this.sentBody,
    required this.notePlaceholder,
  });

  /// "Report story".
  final String title;

  /// "Why are you reporting this story? Your report is anonymous."
  final String body;

  /// Under "Thanks for letting us know".
  final String sentBody;

  /// Hint of the "Something else" field.
  final String notePlaceholder;
}
