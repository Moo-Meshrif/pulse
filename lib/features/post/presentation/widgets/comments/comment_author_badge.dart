import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// "Author" next to the name of the person who wrote the post.
class CommentAuthorBadge extends StatelessWidget {
  const CommentAuthorBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // widthFactor 1 keeps the badge as wide as its text; a plain centered Container fills the row.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(CommentsDimens.badgeRadius),
      ),
      child: SizedBox(
        height: CommentsDimens.badgeHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: CommentsDimens.badgeSide),
          child: Center(
            widthFactor: 1,
            child: AppText(
              context.l10n.commentsAuthorBadge,
              style: context.text.badge,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
