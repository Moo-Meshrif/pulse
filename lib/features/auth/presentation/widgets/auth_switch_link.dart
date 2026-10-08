import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "New to Pulse? **Create account**": a centered 44-high row, the prompt in `textSecondary` and the
/// action in `primary` bold. The whole row is the hit area (docs/specs/auth/screens/s1-signin.md footer).
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final base = context.text.subtitle.copyWith(color: colors.textSecondary);
    return InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AuthDimens.linkTapHeight),
        child: Center(
          child: Semantics(
            button: true,
            child: Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: base,
                children: [
                  TextSpan(text: '$prompt '),
                  TextSpan(
                    text: action,
                    style: base.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
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
