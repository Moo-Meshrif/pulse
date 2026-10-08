import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// The 6-digit verification code on `pinput` (docs/specs/auth/02-components.md C10). Always left-to-right;
/// boxes shrink on narrow widths, never below 44.
class OtpField extends StatelessWidget {
  const OtpField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onCompleted,
    this.errorText,
    this.autofocus = true,
    this.enabled = true,
  });

  static const length = 6;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? errorText;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AuthDimens.otpBoxGap;
        final fitted = (constraints.maxWidth - gap * (length - 1)) / length;
        final width = fitted.clamp(AuthDimens.otpMinBoxWidth, double.infinity);

        PinTheme theme(Color border, double borderWidth) => PinTheme(
          width: width < AuthDimens.otpBoxWidth
              ? width
              : AuthDimens.otpBoxWidth,
          height: AuthDimens.otpBoxHeight,
          textStyle: context.text.otpDigit.copyWith(color: colors.textPrimary),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: border, width: borderWidth),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, child) => Semantics(
                  label: context.l10n.otpDigit(
                    (value.text.length + 1).clamp(1, length),
                  ),
                  child: child,
                ),
                child: Pinput(
                  length: length,
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: autofocus,
                  enabled: enabled,
                  onChanged: onChanged,
                  onCompleted: onCompleted,
                  forceErrorState: errorText != null,
                  mainAxisAlignment: MainAxisAlignment.center,
                  separatorBuilder: (_) => SizedBox(width: gap),
                  defaultPinTheme: theme(
                    colors.border,
                    AuthDimens.otpIdleBorderWidth,
                  ),
                  submittedPinTheme: theme(
                    colors.primary,
                    AuthDimens.otpFilledBorderWidth,
                  ),
                  focusedPinTheme: theme(
                    colors.textPrimary,
                    AuthDimens.otpFocusedBorderWidth,
                  ),
                  errorPinTheme: theme(
                    colors.danger,
                    AuthDimens.otpFilledBorderWidth,
                  ),
                ),
              ),
            ),
            if (errorText != null) ...[
              SizedBox(height: AppSpacing.s12),
              AppText(
                errorText!,
                style: context.text.caption,
                color: colors.danger,
              ),
            ],
          ],
        );
      },
    );
  }
}
