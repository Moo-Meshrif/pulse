import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/comments_dimens.dart';

/// A post nobody has commented on yet.
class CommentsEmpty extends StatelessWidget {
  const CommentsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon(
            AppAssets.comment,
            size: CommentsDimens.emptyIcon,
            color: colors.textPrimary,
          ),
          SizedBox(height: CommentsDimens.emptyGap),
          AppText(
            context.l10n.commentsEmptyTitle,
            style: context.text.stat,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: CommentsDimens.emptyBodyGap),
          AppText(
            context.l10n.commentsEmptyBody,
            style: context.text.bodyXs,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
