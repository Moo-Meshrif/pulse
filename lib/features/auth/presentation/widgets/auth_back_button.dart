import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// The back arrow of the auth screens: a 44 tap target around a 24 `textPrimary` arrow that mirrors in
/// RTL, labelled "Back" (docs/specs/auth/02-components.md C7).
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.back,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onPressed,
      radius: AuthDimens.tapTarget / 2,
      child: SizedBox.square(
        dimension: AuthDimens.tapTarget,
        child: Center(
          child: AppSvgIcon(
            AppAssets.arrowBack,
            size: AuthDimens.stepBarIcon,
            color: context.appColors.textPrimary,
            directional: true,
          ),
        ),
      ),
    ),
  );
}
