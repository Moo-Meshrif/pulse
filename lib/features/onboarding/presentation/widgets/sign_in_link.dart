import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "I already have an account **Sign in**": a centered 44-high row. The whole row is the
/// hit area; the pressed state is the platform ripple only.
class SignInLink extends StatelessWidget {
  const SignInLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = context.text.subtitle.copyWith(color: colors.textSecondary);
    return InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: OnboardingDimens.signInRowHeight,
        ),
        child: Center(
          child: Semantics(
            button: true,
            child: Text.rich(
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: '${context.l10n.alreadyHaveAccount} '),
                  TextSpan(
                    text: context.l10n.signIn,
                    style: base.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
