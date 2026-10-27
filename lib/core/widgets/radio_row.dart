import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_text.dart';

/// A title with a radio circle on the end side. The group decides which row is [selected].
class RadioRow extends StatelessWidget {
  const RadioRow({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      excludeSemantics: true,
      label: title,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.settingsTile),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: SettingsDimens.rowMinHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: SettingsDimens.rowSide),
            child: Row(
              children: [
                Expanded(child: AppText(title, style: context.text.body)),
                SizedBox(width: SettingsDimens.rowGap),
                Container(
                  width: SettingsDimens.radio,
                  height: SettingsDimens.radio,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? colors.primary : colors.dashed,
                      width: SettingsDimens.radioRing,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: SettingsDimens.radioDot,
                          height: SettingsDimens.radioDot,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
