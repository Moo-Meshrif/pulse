import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// The X of the reset screen: a 44 tap target around a 24 `textPrimary` cross, labelled "Close"
/// (docs/specs/auth/screens/s11-set-new-password.md). Not a back arrow, so it does not mirror.
class AuthCloseButton extends StatelessWidget {
  const AuthCloseButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.close,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onPressed,
      radius: AuthDimens.tapTarget / 2,
      child: SizedBox.square(
        dimension: AuthDimens.tapTarget,
        child: Center(
          child: AppSvgIcon(
            AppAssets.close,
            size: AuthDimens.stepBarIcon,
            color: context.appColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}
