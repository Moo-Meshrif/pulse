import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A language: its own name, the English name under it and a check on the selected one.
class LanguageRow extends StatelessWidget {
  const LanguageRow({
    super.key,
    required this.nativeName,
    required this.englishName,
    required this.selected,
    required this.onTap,
  });

  final String nativeName;
  final String englishName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      excludeSemantics: true,
      label: '$nativeName, $englishName',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.settingsTile),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: SettingsDimens.rowMinHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SettingsDimens.rowSide,
              vertical: AppSpacing.s8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        nativeName,
                        style: context.text.name,
                        color: colors.textPrimary,
                      ),
                      AppText(
                        englishName,
                        style: context.text.bodyXs,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  AppSvgIcon(
                    AppAssets.check,
                    size: SettingsDimens.chevron,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
