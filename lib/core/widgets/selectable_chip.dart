import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// Pill chip (docs/specs/auth/02-components.md C11). The visible [height] is padded to a 44 tap target; the
/// [dark] variant shows no check.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.height,
    this.dark = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fill = !selected
        ? colors.surface
        : dark
        ? colors.textPrimary
        : colors.primary;
    final foreground = selected ? colors.textOnPrimary : colors.textPrimary;
    final pill = BorderRadius.circular(AppRadius.pill(height));

    return Semantics(
      button: true,
      selected: selected,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      // The opaque detector makes the padding up to 44 high tappable too (the hit slop).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AuthDimens.chipMinTapHeight,
          ),
          child: Center(
            widthFactor: 1,
            child: Material(
              color: fill,
              shape: RoundedRectangleBorder(
                borderRadius: pill,
                side: selected
                    ? BorderSide.none
                    : BorderSide(
                        color: colors.border,
                        width: AuthDimens.chipBorderWidth,
                      ),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: pill,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AuthDimens.chipHorizontalPadding,
                      vertical: AppSpacing.s8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected && !dark) ...[
                          AppSvgIcon(
                            AppAssets.check,
                            size: AuthDimens.chipCheckSize,
                            color: foreground,
                          ),
                          SizedBox(width: AuthDimens.chipCheckGap),
                        ],
                        Flexible(
                          child: AppText(
                            label,
                            style: context.text.name,
                            color: foreground,
                          ),
                        ),
                      ],
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
