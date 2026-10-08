import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// "Forgot password?": end-aligned, `primary` 14/700, 44 tap target.
class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AuthDimens.linkTapHeight),
        child: Center(
          widthFactor: 1,
          child: Semantics(
            button: true,
            child: AppText(
              context.l10n.forgotPassword,
              style: context.text.bodySm.copyWith(fontWeight: FontWeight.w700),
              color: context.appColors.primary,
            ),
          ),
        ),
      ),
    ),
  );
}
