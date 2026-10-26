import 'package:flutter/widgets.dart';

/// The `@word` being typed at the cursor of a comment field.
class MentionQuery {
  const MentionQuery({required this.start, required this.text});

  /// Where the `@` is in the field text.
  final int start;

  /// The letters after the `@`.
  final String text;

  static final _typing = RegExp(r'(?:^|\s)@([\w.]+)$');

  /// The mention under the cursor of [value]; null when the cursor is not at the end of an `@word`
  /// that starts a word, or the field has a selection.
  static MentionQuery? find(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) return null;
    final before = value.text.substring(0, selection.start);
    final match = _typing.firstMatch(before);
    if (match == null) return null;
    final word = match.group(1)!;
    return MentionQuery(start: before.length - word.length - 1, text: word);
  }

  /// [value] with this `@word` replaced by `@username ` and the cursor after it.
  TextEditingValue pick(TextEditingValue value, String username) {
    final end = value.selection.start;
    final inserted = '@$username ';
    return TextEditingValue(
      text: value.text.replaceRange(start, end, inserted),
      selection: TextSelection.collapsed(offset: start + inserted.length),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MentionQuery && other.start == start && other.text == text;

  @override
  int get hashCode => Object.hash(start, text);
}
