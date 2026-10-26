import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/comment_text.dart';

/// The quick emoji above the comment field: a tap puts one in the text.
class CommentEmojiRow extends StatelessWidget {
  const CommentEmojiRow({super.key, required this.onEmoji});

  final ValueChanged<String> onEmoji;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final emoji in CommentText.quickEmoji)
        Expanded(
          child: InkResponse(
            onTap: () => onEmoji(emoji),
            radius: CommentsDimens.emojiTarget / 2,
            child: SizedBox(
              height: CommentsDimens.emojiTarget,
              child: Center(
                child: Text(
                  emoji,
                  style: context.text.input.copyWith(
                    fontSize: CommentsDimens.emoji,
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
