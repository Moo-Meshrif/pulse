import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A checkbox + [label] (docs/specs/auth/02-components.md C9). The whole row toggles it. [compact] is the
/// reset screen's smaller box.
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.compact = false,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final box = compact ? AuthDimens.checkboxCompact : AuthDimens.checkbox;
    return Semantics(
      checked: checked,
      child: InkWell(
        onTap: () => onChanged(!checked),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AuthDimens.tapTarget),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AuthDimens.progressDuration,
                width: box,
                height: box,
                decoration: BoxDecoration(
                  color: checked ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.checkbox),
                  border: checked
                      ? null
                      : Border.all(
                          color: colors.border,
                          width: AuthDimens.checkboxBorderWidth,
                        ),
                ),
                alignment: Alignment.center,
                child: checked
                    ? AppSvgIcon(
                        AppAssets.check,
                        size: compact
                            ? AuthDimens.checkboxCheckCompact
                            : AuthDimens.checkboxCheck,
                        color: colors.textOnPrimary,
                      )
                    : null,
              ),
              SizedBox(width: AuthDimens.checkboxToLabelGap),
              Expanded(child: label),
            ],
          ),
        ),
      ),
    );
  }
}
