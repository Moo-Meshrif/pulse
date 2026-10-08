import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';
import '../enums/pill_button_variant.dart';

/// A fully rounded secondary button (docs/specs/auth/02-components.md C4). Pick the look with a factory:
/// [PillButton.outline], [PillButton.soft] or [PillButton.danger]. The primary button is `PrimaryButton`.
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.variant,
    this.expand = true,
    this.autofocus = false,
  });

  const PillButton.outline({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: PillButtonVariant.outline,
         expand: expand,
       );

  /// [autofocus] puts the focus on it when the dialog opens (the cancel action of a destructive dialog).
  const PillButton.soft({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool expand = true,
    bool autofocus = false,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: PillButtonVariant.soft,
         expand: expand,
         autofocus: autofocus,
       );

  const PillButton.danger({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         variant: PillButtonVariant.danger,
         expand: expand,
       );

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final bool expand;
  final bool autofocus;

  static const double _pressedDarken = 0.06;

  @override
  Widget build(BuildContext context) {
    final fill = variant.fill(context);
    final foreground = variant.foreground(context);
    final borderColor = variant.border(context);
    final pressed = Color.lerp(
      fill,
      context.appColors.textPrimary,
      _pressedDarken,
    )!;
    return FilledButton(
      onPressed: onPressed,
      autofocus: autofocus,
      style: ButtonStyle(
        minimumSize: WidgetStatePropertyAll(
          Size(expand ? double.infinity : 0, variant.height ?? 0),
        ),
        maximumSize: WidgetStatePropertyAll(
          Size(double.infinity, variant.height ?? double.infinity),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: variant.verticalPadding),
        ),
        shape: WidgetStatePropertyAll(
          StadiumBorder(
            side: borderColor == null
                ? BorderSide.none
                : BorderSide(
                    color: borderColor,
                    width: AuthButtonDimens.outlineBorderWidth,
                  ),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(foreground),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed) ? pressed : fill,
        ),
      ),
      child: Opacity(
        opacity: onPressed != null ? 1 : AuthButtonDimens.disabledOpacity,
        child: AppText(
          label,
          style: context.text.button,
          color: foreground,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
