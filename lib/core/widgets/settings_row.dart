import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// A tappable row: optional icon tile, [title], optional [value] and a chevron that mirrors in RTL.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.value,
  });

  final String title;
  final VoidCallback onTap;

  /// Asset of the icon shown in the tile; no tile when null.
  final String? icon;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppRadius.settingsTile);
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: value == null ? title : '$title, $value',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: SettingsDimens.rowMinHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SettingsDimens.rowSide),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    width: SettingsDimens.tile,
                    height: SettingsDimens.tile,
                    decoration: BoxDecoration(
                      color: colors.primarySoft,
                      borderRadius: radius,
                    ),
                    alignment: Alignment.center,
                    child: AppSvgIcon(
                      icon!,
                      size: SettingsDimens.tileIcon,
                      color: colors.primary,
                    ),
                  ),
                  SizedBox(width: SettingsDimens.rowGap),
                ],
                Expanded(
                  child: AppText(
                    title,
                    style: context.text.body,
                    color: colors.textPrimary,
                  ),
                ),
                if (value != null) ...[
                  SizedBox(width: SettingsDimens.rowGap),
                  // Not a Flexible: that would share the free width equally with the title and wrap it.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.sizeOf(context).width *
                          SettingsDimens.valueMaxWidthShare,
                    ),
                    child: AppText(
                      value!,
                      style: context.text.bodySm,
                      color: colors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                SizedBox(width: SettingsDimens.valueGap),
                AppSvgIcon(
                  AppAssets.chevronRight,
                  size: SettingsDimens.chevron,
                  color: colors.iconInactive,
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
