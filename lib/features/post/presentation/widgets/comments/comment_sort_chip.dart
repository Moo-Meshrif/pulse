import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/comment_sort.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/comment_sort_label.dart';

/// The sort chip of the header; it opens a small popup with the two orders, the current one checked.
class CommentSortChip extends StatelessWidget {
  const CommentSortChip({
    super.key,
    required this.sort,
    required this.onChanged,
  });

  final CommentSort sort;
  final ValueChanged<CommentSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return PopupMenuButton<CommentSort>(
      tooltip: l10n.commentsSortLabel,
      onSelected: onChanged,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CommentsDimens.sortMenuRadius),
      ),
      itemBuilder: (_) => [
        for (final option in CommentSort.values)
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    commentSortLabel(l10n, option),
                    style: context.text.bodySm,
                    color: colors.textPrimary,
                  ),
                ),
                if (option == sort)
                  AppSvgIcon(
                    AppAssets.check,
                    size: CommentsDimens.sortCheck,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
      ],
      child: Container(
        height: CommentsDimens.sortChipHeight,
        padding: EdgeInsets.symmetric(horizontal: CommentsDimens.sortChipSide),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(
            CommentsDimens.sortChipHeight / 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              commentSortLabel(l10n, sort),
              style: context.text.chip,
              color: colors.textPrimary,
            ),
            SizedBox(width: CommentsDimens.sortChipGap),
            AppSvgIcon(
              AppAssets.chevronDown,
              size: CommentsDimens.sortChipIcon,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
