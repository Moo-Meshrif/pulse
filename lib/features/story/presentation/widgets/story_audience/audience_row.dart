import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import 'audience_check.dart';

/// One row: an icon tile, the title with "N people" under it, and at the end a check ([selected] given),
/// an Edit pill ([onEdit]) before it, or a chevron (no [selected]).
class AudienceRow extends StatelessWidget {
  const AudienceRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.selected,
    this.onEdit,
    this.tileColor,
    this.tileIconColor,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool? selected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final Color? tileColor;
  final Color? tileIconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final label = subtitle == null ? title : '$title, $subtitle';
    final tile = Container(
      width: StoryPermissionDimens.tile,
      height: StoryPermissionDimens.tile,
      decoration: BoxDecoration(
        color:
            tileColor ??
            colors.storyOnDark.withValues(alpha: StoryOpacity.tileFill),
        borderRadius: BorderRadius.circular(StoryPermissionDimens.tileRadius),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        icon,
        size: StorySheetDimens.rowIcon,
        color: tileIconColor ?? colors.storyOnDark,
      ),
    );
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(title, style: text.name, color: colors.storyOnDark),
        if (subtitle != null)
          AppText(
            subtitle!,
            style: text.caption,
            color: colors.storyOnDark.withValues(alpha: StoryOpacity.subtitle),
          ),
      ],
    );
    final end = selected != null
        ? AudienceCheck(selected: selected!)
        : AppSvgIcon(
            AppAssets.chevronRight,
            size: StorySheetDimens.chevron,
            color: colors.storyOnDark.withValues(alpha: StoryOpacity.chevron),
            directional: true,
          );
    final padding = EdgeInsets.symmetric(
      horizontal: StorySheetDimens.rowPaddingH,
      vertical: StorySheetDimens.rowPaddingV,
    );
    const minHeight = BoxConstraints(minHeight: StorySheetDimens.rowMinHeight);

    Widget tappable(Widget child) => Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(onTap: onTap, child: child),
    );

    if (onEdit == null) {
      return tappable(
        ConstrainedBox(
          constraints: minHeight,
          child: Padding(
            padding: padding,
            child: Row(
              children: [
                tile,
                SizedBox(width: StorySheetDimens.rowGap),
                Expanded(child: words),
                end,
              ],
            ),
          ),
        ),
      );
    }
    // A row with an Edit button: the button must not sit inside the row's own tap target, or a screen
    // reader would read the two as one.
    return ConstrainedBox(
      constraints: minHeight,
      child: Row(
        children: [
          Expanded(
            child: tappable(
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: StorySheetDimens.rowPaddingH,
                  top: StorySheetDimens.rowPaddingV,
                  bottom: StorySheetDimens.rowPaddingV,
                ),
                child: Row(
                  children: [
                    tile,
                    SizedBox(width: StorySheetDimens.rowGap),
                    Expanded(child: words),
                  ],
                ),
              ),
            ),
          ),
          TintedChip(
            label: context.l10n.storyAudienceEdit,
            color: colors.storyOnDark,
            onTap: onEdit!,
          ),
          tappable(
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.s8,
                end: StorySheetDimens.rowPaddingH,
                top: StorySheetDimens.rowPaddingV,
                bottom: StorySheetDimens.rowPaddingV,
              ),
              child: end,
            ),
          ),
        ],
      ),
    );
  }
}
