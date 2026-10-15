import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/compact_count.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_text.dart';
import '../dimens/post_card_dimens.dart';
import 'post_like_pop.dart';
import 'post_tap_button.dart';

/// Like, comment, share, then save at the end. Counts are compact (1.2K) and a zero shows no number.
class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.isSaved,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(top: PostCardDimens.actionBarTop),
      child: SizedBox(
        height: PostCardDimens.actionBarHeight,
        child: Row(
          children: [
            PostLikePop(
              isLiked: isLiked,
              child: _ActionButton(
                label: isLiked ? l10n.postUnlike : l10n.postLike,
                icon: isLiked ? AppAssets.heartFilled : AppAssets.heart,
                iconColor: isLiked ? colors.like : colors.textPrimary,
                count: likeCount,
                onTap: onLike,
              ),
            ),
            SizedBox(width: PostCardDimens.actionGap),
            _ActionButton(
              label: l10n.postComment,
              icon: AppAssets.comment,
              iconColor: colors.textPrimary,
              count: commentCount,
              onTap: onComment,
            ),
            SizedBox(width: PostCardDimens.actionGap),
            _ActionButton(
              label: l10n.postShare,
              icon: AppAssets.share,
              iconColor: colors.textPrimary,
              iconSize: PostCardDimens.shareIcon,
              onTap: onShare,
            ),
            const Spacer(),
            _ActionButton(
              label: isSaved ? l10n.postUnsave : l10n.postSave,
              icon: isSaved ? AppAssets.bookmarkFilled : AppAssets.bookmark,
              iconColor: colors.textPrimary,
              iconSize: PostCardDimens.saveIcon,
              onTap: onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.iconSize,
    this.count,
    this.onTap,
  });

  final String label;
  final String icon;
  final Color iconColor;
  final double? iconSize;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = count == null ? '' : compactCount(count!);
    return PostTapButton(
      label: label,
      value: text.isEmpty ? null : text,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: PostCardDimens.actionTapTarget,
          minHeight: PostCardDimens.actionTapTarget,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: PostCardDimens.actionHorizontal,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSvgIcon(
                icon,
                size: iconSize ?? PostCardDimens.actionIcon,
                color: iconColor,
              ),
              if (text.isNotEmpty) ...[
                SizedBox(width: PostCardDimens.actionIconGap),
                AppText(
                  text,
                  style: context.text.meta,
                  color: context.appColors.textPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
