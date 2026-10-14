import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// One row of the "Add to your post" card: an icon tile, a title, an optional value and a chevron, or a
/// [trailing] widget (the comments switch) instead of the chevron.
class NewPostOptionRow extends StatelessWidget {
  const NewPostOptionRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: onTap != null,
      container: true,
      label: value == null ? title : '$title, $value',
      excludeSemantics: trailing == null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: PostComposerDimens.optionRowPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  PostComposerDimens.optionRowHeight -
                  PostComposerDimens.optionRowPadding.vertical,
            ),
            child: Row(
              children: [
                Container(
                  width: PostComposerDimens.optionTile,
                  height: PostComposerDimens.optionTile,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(
                      PostComposerDimens.optionTileRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    icon,
                    size: PostComposerDimens.optionTileIcon,
                    color: colors.primary,
                  ),
                ),
                SizedBox(width: PostComposerDimens.optionGap),
                Expanded(
                  child: AppText(
                    title,
                    style: context.text.optionTitle,
                    color: colors.textPrimary,
                  ),
                ),
                if (value != null) ...[
                  Flexible(
                    child: AppText(
                      value!,
                      style: context.text.bodySm,
                      color: colors.textSecondary,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8),
                ],
                trailing ??
                    AppSvgIcon(
                      AppAssets.chevronRight,
                      size: PostComposerDimens.optionChevron,
                      color: colors.textSecondary,
                      directional: true,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
