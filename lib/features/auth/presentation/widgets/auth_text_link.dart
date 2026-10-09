import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A centered 44-high text link in `primary` bold (docs/specs/auth/screens/s4-signup-verify-email.md,
/// "Use a different email"). [onPressed] null shows it disabled, in `textSecondary`.
class AuthTextLink extends StatelessWidget {
  const AuthTextLink({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AuthDimens.linkTapHeight,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.subtitle.copyWith(
                fontWeight: FontWeight.w700,
                color: onPressed == null
                    ? colors.textSecondary
                    : colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
