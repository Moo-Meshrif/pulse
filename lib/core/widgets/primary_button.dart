import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_scale.dart';
import '../theme/app_text_styles.dart';
import 'app_svg_icon.dart';
import 'app_text.dart';

/// Pill button: height 56, fully rounded, `primary` fill (`primaryPressed` while pressed),
/// `button` label in `textOnPrimary` (docs/specs/_theme, component 2.1).
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
  });

  static const double height = 56; // unscaled: tap target

  final String label;
  final VoidCallback onPressed;

  /// A directional icon after the label (it flips in RTL), e.g. the Next arrow.
  final String? trailingIconAsset;
  final double? trailingIconSize;
  final double? trailingIconGap;

  /// Fill the available width.
  final bool expand;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return FilledButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, height),
        ),
        maximumSize: const WidgetStatePropertyAll(
          Size(double.infinity, height),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        elevation: const WidgetStatePropertyAll(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(colors.textOnPrimary),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? colors.primaryPressed
              : colors.primary,
        ),
      ),
      child: Row(
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
