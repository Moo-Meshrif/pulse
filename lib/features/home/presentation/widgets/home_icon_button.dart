import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';

/// A 44 circle with an icon: Search and the bell in the header.
class HomeIconButton extends StatelessWidget {
  const HomeIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final String icon;

  /// What a screen reader says.
  final String label;
  final VoidCallback onTap;

  /// Drawn over the icon, e.g. the bell's dot.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.textPrimary;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: SizedBox.square(
        dimension: HomeDimens.actionTapTarget,
        child: Stack(
          children: [
            Material(
              type: MaterialType.transparency,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Center(
                  child: AppSvgIcon(
                    icon,
                    size: HomeDimens.actionIcon,
                    color: color,
                  ),
                ),
              ),
            ),
            ?badge,
          ],
        ),
      ),
    );
  }
}
