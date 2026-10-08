import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A 72 `primarySoft` tile (radius 22) with a 32 `primary` icon: the lock on Forgot password, the mail
/// on Verify email, the key on Set a new password (docs/specs/auth/02-components.md C2). Decorative.
class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: AuthDimens.iconTile,
      height: AuthDimens.iconTile,
      decoration: BoxDecoration(
        color: context.appColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.iconTile),
      ),
      alignment: Alignment.center,
      child: AppSvgIcon(
        icon,
        size: AuthDimens.iconTileIcon,
        color: context.appColors.primary,
      ),
    ),
  );
}
