import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// A full-width white card with a red [label] and an optional [icon] (Log out).
class DangerButtonCard extends StatelessWidget {
  const DangerButtonCard({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppRadius.card);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      child: Semantics(
        button: true,
        excludeSemantics: true,
        label: label,
        onTap: onPressed,
        child: Material(
          color: colors.surface,
          borderRadius: radius,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: SizedBox(
              height: SettingsDimens.dangerHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    AppSvgIcon(
                      icon!,
                      size: SettingsDimens.dangerIcon,
                      color: colors.danger,
                    ),
                    SizedBox(width: SettingsDimens.dangerGap),
                  ],
                  AppText(
                    label,
                    style: context.text.button,
                    color: colors.danger,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
