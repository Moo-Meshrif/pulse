import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import 'app_text.dart';

/// A small outline pill for list rows (Unblock, Follow, Log out). The visible height is 36, the tap target
/// 44. [PillButton.outline] is the full-width form button.
class OutlinePillButton extends StatelessWidget {
  const OutlinePillButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final enabled = onPressed != null;
    final shape = StadiumBorder(
      side: BorderSide(color: colors.border, width: SettingsDimens.pillBorder),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      label: label,
      onTap: onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
          child: Center(
            widthFactor: 1,
            child: AnimatedOpacity(
              duration: SettingsDimens.switchDuration,
              opacity: enabled ? 1 : ButtonDimens.disabledOpacity,
              child: Material(
                color: colors.surface,
                shape: shape,
                child: InkWell(
                  onTap: onPressed,
                  customBorder: shape,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: SettingsDimens.pillHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SettingsDimens.pillSide,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: AppText(
                          label,
                          style: context.text.label,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
