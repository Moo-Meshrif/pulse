import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
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
      width: CameraPermissionDimens.tile,
      height: CameraPermissionDimens.tile,
      decoration: BoxDecoration(
        color:
            tileColor ?? colors.onDark.withValues(alpha: DarkOpacity.tileFill),
        borderRadius: BorderRadius.circular(CameraPermissionDimens.tileRadius),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        icon,
        size: OptionSheetDimens.rowIcon,
        color: tileIconColor ?? colors.onDark,
      ),
    );
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(title, style: text.name, color: colors.onDark),
        if (subtitle != null)
          AppText(
            subtitle!,
            style: text.caption,
            color: colors.onDark.withValues(alpha: DarkOpacity.subtitle),
          ),
      ],
    );
    final end = selected != null
        ? AudienceCheck(selected: selected!)
        : AppSvgIcon(
            AppAssets.chevronRight,
            size: OptionSheetDimens.chevron,
            color: colors.onDark.withValues(alpha: DarkOpacity.chevron),
            directional: true,
          );
    final padding = EdgeInsets.symmetric(
      horizontal: OptionSheetDimens.rowPaddingH,
      vertical: OptionSheetDimens.rowPaddingV,
    );
    const minHeight = BoxConstraints(minHeight: OptionSheetDimens.rowMinHeight);

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
                SizedBox(width: OptionSheetDimens.rowGap),
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
                  start: OptionSheetDimens.rowPaddingH,
                  top: OptionSheetDimens.rowPaddingV,
                  bottom: OptionSheetDimens.rowPaddingV,
                ),
                child: Row(
                  children: [
                    tile,
                    SizedBox(width: OptionSheetDimens.rowGap),
                    Expanded(child: words),
                  ],
                ),
              ),
            ),
          ),
          TintedChip(
            label: context.l10n.storyAudienceEdit,
            color: colors.onDark,
            onTap: onEdit!,
          ),
          tappable(
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.s8,
                end: OptionSheetDimens.rowPaddingH,
                top: OptionSheetDimens.rowPaddingV,
                bottom: OptionSheetDimens.rowPaddingV,
              ),
              child: end,
            ),
          ),
        ],
      ),
    );
  }
}
