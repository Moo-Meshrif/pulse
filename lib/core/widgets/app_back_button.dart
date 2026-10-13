import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import 'app_svg_icon.dart';

/// The back arrow of every screen: a 44 tap target around a 24 `textPrimary` arrow that mirrors in
/// RTL, labelled "Back" (docs/specs/auth/02-components.md C7).
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

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
