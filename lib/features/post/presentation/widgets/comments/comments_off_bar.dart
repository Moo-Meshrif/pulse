import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// Takes the place of the comment field on a post with comments turned off.
class CommentsOffBar extends StatelessWidget {
  const CommentsOffBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: CommentsDimens.offBarPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppSvgIcon(
            AppAssets.commentOff,
            size: CommentsDimens.stateIcon,
            color: colors.textSecondary,
          ),
          SizedBox(width: CommentsDimens.stateGap),
          Flexible(
            child: AppText(
              context.l10n.commentsOff,
              style: context.text.caption,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
