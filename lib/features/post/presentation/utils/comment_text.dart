import 'package:flutter/widgets.dart';

/// The rules of the comment field.
abstract final class CommentText {
  static const maxLength = 1000;

  /// The counter shows from this length.
  static const counterFrom = 900;

  /// How long typing pauses before people are suggested for an `@word`.
  static const mentionDelay = Duration(milliseconds: 300);

  /// The quick emoji above the field.
  static const quickEmoji = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂'];

  /// The six emoji of the long-press menu.
  static const menuEmoji = ['❤️', '🙌', '🔥', '👏', '😢', '😍'];

  /// What a reply starts with.
  static String mention(String username) => '@$username ';

  /// [existing] starting with the `@name` of a reply: a field that is empty or holds only a mention gets
  /// just this one; typed text is kept after it.
  static String withMention(String existing, String username) {
    final words = existing.trim();
    final onlyMention = words.isEmpty || RegExp(r'^@\S+$').hasMatch(words);
    return onlyMention ? mention(username) : '${mention(username)}$existing';
  }

  /// Whether [text] can be sent: words beyond the `@name` of a reply, within the limit.
  static bool canSend(String text, {String? replyUsername}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) return false;
    return trimmed != '@$replyUsername';
  }

  /// [value] with [emoji] at the cursor (at the end when the field has none); the same value when it would
  /// pass the limit.
  static TextEditingValue insert(TextEditingValue value, String emoji) {
    if (value.text.length + emoji.length > maxLength) return value;
    final selection = value.selection;
    final at = selection.isValid ? selection.start : value.text.length;
    final end = selection.isValid ? selection.end : value.text.length;
    final text = value.text.replaceRange(at, end, emoji);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: at + emoji.length),
    );
  }
}
