import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_text.dart';
import '../dimens/post_card_dimens.dart';

/// The line under the action bar of a post with comments turned off.
class PostCommentsOffLine extends StatelessWidget {
  const PostCommentsOffLine({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: PostCardDimens.commentsOffLinePadding,
      child: Row(
        children: [
          AppSvgIcon(
            AppAssets.commentOff,
            size: PostCardDimens.commentsOffLineIcon,
            color: colors.textSecondary,
          ),
          SizedBox(width: PostCardDimens.actionIconGap),
          Expanded(
            child: AppText(
              context.l10n.postCommentsOffLine,
              style: context.text.caption,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
