import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/avatar_initials.dart';

/// A 48 circle with the person's initials in white on a palette color picked from [seed] (their user id),
/// so a person keeps the same color (docs/specs/auth/02-components.md C12). Decorative: the row names them.
class AvatarInitials extends StatelessWidget {
  const AvatarInitials({super.key, required this.name, required this.seed});

  final String? name;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = colors.avatarBackgrounds;
    return ExcludeSemantics(
      child: Container(
        width: AuthDimens.avatarList,
        height: AuthDimens.avatarList,
        decoration: BoxDecoration(
          color: palette[stablePaletteIndex(seed, palette.length)],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AppText(
          initialsOf(name),
          style: context.text.name,
          color: colors.textOnPrimary,
        ),
      ),
    );
  }
}
