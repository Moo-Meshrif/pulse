import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../theme/app_scale.dart';
import '../theme/app_text_styles.dart';
import 'app_spinner.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// The primary pill button (docs/specs/_theme, component 2.1). A null [onPressed] disables it; [loading]
/// shows a spinner and ignores taps.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIconAsset,
    this.trailingIconSize,
    this.trailingIconGap,
    this.expand = false,
    this.horizontalPadding = 0,
    this.loading = false,
    this.buttonHeight = height,
  });

  static const double height = 56; // unscaled: tap target

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// A directional icon after the label (it flips in RTL), e.g. the Next arrow.
  final String? trailingIconAsset;
  final double? trailingIconSize;
  final double? trailingIconGap;

  /// Fill the available width.
  final bool expand;
  final double horizontalPadding;

  /// Shows a spinner instead of the label and ignores taps; the fill stays `primary`.
  final bool loading;

  /// 56 by default; dialogs and sheets use the 48 pill (`AuthButtonDimens.pillHeight`).
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FilledButton(
      onPressed: loading ? null : onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, buttonHeight),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(double.infinity, buttonHeight),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        elevation: const WidgetStatePropertyAll(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(colors.textOnPrimary),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return loading
                ? colors.primary
                : colors.primary.withValues(
                    alpha: AuthButtonDimens.disabledOpacity,
                  );
          }
          return states.contains(WidgetState.pressed)
              ? colors.primaryPressed
              : colors.primary;
        }),
      ),
      child: loading
          ? Semantics(
              label: label,
              child: AppSpinner(
                size: AuthButtonDimens.spinnerSize,
                strokeWidth: AuthButtonDimens.spinnerStroke,
                color: colors.textOnPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: AppText(
                    label,
                    style: context.text.button,
                    color: colors.textOnPrimary,
                  ),
                ),
                if (trailingIconAsset != null) ...[
                  SizedBox(width: trailingIconGap ?? AppScale.scale(8)),
                  AppSvgIcon(
                    trailingIconAsset!,
                    size: trailingIconSize ?? AppScale.scale(20),
                    color: colors.textOnPrimary,
                    directional: true,
                  ),
                ],
              ],
            ),
    );
  }
}
