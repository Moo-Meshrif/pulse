import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/profile_dimens.dart';

/// A round button over the cover: white at 88%, a 22 icon, a 44 tap target.
class CoverButton extends StatelessWidget {
  const CoverButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.directional = false,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;
  final bool directional;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: ProfileDimens.coverButton,
          height: ProfileDimens.coverButton,
          decoration: BoxDecoration(
            color: colors.surface.withAlpha(0xE0),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: AppSvgIcon(
              icon,
              size: ProfileDimens.coverButtonIcon,
              color: colors.textPrimary,
              directional: directional,
            ),
          ),
        ),
      ),
    );
  }
}
