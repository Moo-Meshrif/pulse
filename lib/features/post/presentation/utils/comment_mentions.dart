/// A piece of a comment: plain words or one `@username`.
class CommentPart {
  const CommentPart(this.text, {this.username});

  final String text;

  /// The username without the `@`; null for plain words.
  final String? username;

  bool get isMention => username != null;
}

/// Splits a comment into plain words and `@username`s (an `@` that starts a word). Dots at the end of a
/// name belong to the sentence.
abstract final class CommentMentions {
  static final _mention = RegExp(r'(?<![\w@])@(\w[\w.]*\w|\w)');

  static List<CommentPart> split(String body) {
    final parts = <CommentPart>[];
    var from = 0;
    for (final match in _mention.allMatches(body)) {
      if (match.start > from) {
        parts.add(CommentPart(body.substring(from, match.start)));
      }
      parts.add(CommentPart(match.group(0)!, username: match.group(1)));
      from = match.end;
    }
    if (from < body.length) parts.add(CommentPart(body.substring(from)));
    return parts;
  }
}
