import 'enums/comment_option.dart';

/// Which rows the long-press menu of a comment shows, in two cards, and whether the quick emoji show.
/// Your own comment: edit, copy, delete. Someone's: reply and copy, then hide (the post owner) and report.
/// With comments off nothing can be written, so there is no reply, no emoji and no edit.
class CommentOptionLayout {
  final bool showEmoji;
  final List<CommentOption> groupA;
  final List<CommentOption> groupB;

  const CommentOptionLayout._(this.showEmoji, this.groupA, this.groupB);

  factory CommentOptionLayout.of({
    required bool isMine,
    required bool isPostOwner,
    required bool commentsEnabled,
  }) {
    if (isMine) {
      return CommentOptionLayout._(
        false,
        [if (commentsEnabled) CommentOption.edit, CommentOption.copyText],
        const [CommentOption.delete],
      );
    }
    return CommentOptionLayout._(
      commentsEnabled,
      [if (commentsEnabled) CommentOption.reply, CommentOption.copyText],
      [if (isPostOwner) CommentOption.hide, CommentOption.report],
    );
  }
}
