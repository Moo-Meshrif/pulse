import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_text.dart';

/// A title with an optional [subtitle] and a switch. A null [onChanged] disables the row (40% opacity);
/// [onDisabledTap] still runs on tap, for a "coming soon" notice.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.onDisabledTap,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onChanged != null;
    final onTap = enabled ? () => onChanged!(!value) : onDisabledTap;
    return Semantics(
      toggled: value,
      enabled: enabled,
      excludeSemantics: true,
      label: subtitle == null ? title : '$title, $subtitle',
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.settingsTile),
        child: AnimatedOpacity(
          duration: SettingsDimens.switchDuration,
          opacity: enabled ? 1 : ButtonDimens.disabledOpacity,
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
                        AppText(title, style: context.text.body),
                        if (subtitle != null)
                          AppText(
                            subtitle!,
                            style: context.text.bodyXs,
                            color: colors.textSecondary,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: SettingsDimens.rowGap),
                  _SwitchTrack(value: value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: SettingsDimens.switchDuration,
      width: SettingsDimens.switchWidth,
      height: SettingsDimens.switchHeight,
      padding: EdgeInsets.all(SettingsDimens.switchInset),
      decoration: BoxDecoration(
        color: value ? colors.primary : colors.switchOff,
        borderRadius: BorderRadius.circular(
          AppRadius.pill(SettingsDimens.switchHeight),
        ),
      ),
      alignment: value
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        width: SettingsDimens.switchThumb,
        height: SettingsDimens.switchThumb,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: value
              ? Border.all(
                  color: colors.primary,
                  width: SettingsDimens.switchThumbRing,
                )
              : null,
        ),
      ),
    );
  }
}
