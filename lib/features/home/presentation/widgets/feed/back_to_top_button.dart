import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/home_dimens.dart';

/// The small round button that takes a deep feed back to the top.
class BackToTopButton extends StatelessWidget {
  const BackToTopButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: context.l10n.homeBackToTop,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: HomeDimens.backToTopSize,
          height: HomeDimens.backToTopSize,
          decoration: BoxDecoration(
            color: colors.textOnPrimary.withAlpha(
              HomeDimens.backToTopFillAlpha,
            ),
            shape: BoxShape.circle,
            boxShadow: AppShadows.backToTop,
          ),
          alignment: Alignment.center,
          child: AppSvgIcon(
            AppAssets.arrowUp,
            size: HomeDimens.backToTopIcon,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
