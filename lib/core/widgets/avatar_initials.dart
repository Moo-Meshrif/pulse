import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/dimens/app_dimens.dart';
import '../utils/avatar_initials.dart';
import 'app_text.dart';

/// A 48 circle with the person's initials in white on a palette color picked from [seed] (their user id),
/// so a person keeps the same color (docs/specs/auth/02-components.md C12). Decorative: the row names them.
class AvatarInitials extends StatelessWidget {
  const AvatarInitials({
    super.key,
    required this.name,
    required this.seed,
    this.size,
    this.fontSize,
  });

  final String? name;
  final String? seed;

  /// Diameter; the list avatar (48) when null.
  final double? size;

  /// Initials size; the `name` text style's own when null.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = colors.avatarBackgrounds;
    return ExcludeSemantics(
      child: Container(
        width: size ?? AvatarDimens.list,
        height: size ?? AvatarDimens.list,
        padding: EdgeInsets.all(AvatarDimens.initialsPadding),
        decoration: BoxDecoration(
          color: palette[stablePaletteIndex(seed, palette.length)],
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: AppText(
            initialsOf(name),
            style: fontSize == null
                ? context.text.name
                : context.text.name.copyWith(fontSize: fontSize),
            color: colors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
