import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/comment_option_layout.dart';
import 'package:pulse/features/post/presentation/utils/enums/comment_option.dart';

void main() {
  CommentOptionLayout layout({
    bool isMine = false,
    bool isPostOwner = false,
    bool commentsEnabled = true,
  }) => CommentOptionLayout.of(
    isMine: isMine,
    isPostOwner: isPostOwner,
    commentsEnabled: commentsEnabled,
  );

  test("someone's comment: reply, copy, then report", () {
    final l = layout();
    expect(l.showEmoji, isTrue);
    expect(l.groupA, [CommentOption.reply, CommentOption.copyText]);
    expect(l.groupB, [CommentOption.report]);
  });

  test('the post owner can also hide', () {
    expect(layout(isPostOwner: true).groupB, [
      CommentOption.hide,
      CommentOption.report,
    ]);
  });

  test('your own comment: edit, copy, delete; never hide, report or emoji', () {
    final l = layout(isMine: true, isPostOwner: true);
    expect(l.showEmoji, isFalse);
    expect(l.groupA, [CommentOption.edit, CommentOption.copyText]);
    expect(l.groupB, [CommentOption.delete]);
  });

  test('comments off: no reply, emoji or edit', () {
    final other = layout(commentsEnabled: false);
    expect(other.showEmoji, isFalse);
    expect(other.groupA, [CommentOption.copyText]);
    expect(other.groupB, [CommentOption.report]);
    expect(layout(isMine: true, commentsEnabled: false).groupA, [
      CommentOption.copyText,
    ]);
  });
}
