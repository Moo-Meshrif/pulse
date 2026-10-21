import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_text.dart';
import '../dimens/post_card_dimens.dart';

/// Replaces the original inside a share when it was deleted or you can't see it any more.
class PostUnavailableEmbed extends StatelessWidget {
  const PostUnavailableEmbed({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.postUnavailableSemantics,
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.all(PostCardDimens.unavailablePadding),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PostCardDimens.unavailableRadius),
        ),
        child: Row(
          children: [
            Container(
              width: PostCardDimens.unavailableLock,
              height: PostCardDimens.unavailableLock,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
              ),
              child: AppSvgIcon(
                AppAssets.lock,
                size: PostCardDimens.unavailableLockIcon,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(width: PostCardDimens.unavailableGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    l10n.postUnavailableTitle,
                    style: context.text.action,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    l10n.postUnavailableBody,
                    style: context.text.caption,
                    color: colors.textSecondary,
                    maxLines: PostCardDimens.unavailableBodyLines,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
