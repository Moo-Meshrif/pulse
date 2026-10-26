import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/comment_mentions.dart';

void main() {
  test('splits words and @names', () {
    final parts = CommentMentions.split('@sara.k nice shot @omar.');
    expect(
      [for (final p in parts) p.text],
      ['@sara.k', ' nice shot ', '@omar', '.'],
    );
    expect(parts.first.username, 'sara.k');
    expect(parts[1].isMention, isFalse);
  });

  test('an email is not a mention', () {
    expect(CommentMentions.split('me@site.com').single.isMention, isFalse);
  });
}
