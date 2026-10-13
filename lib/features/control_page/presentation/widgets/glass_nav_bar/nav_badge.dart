import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';

/// The unread count on the Chat item: a red pill with a white ring, "99+" above 99. Draws nothing at 0.
class NavBadge extends StatelessWidget {
  const NavBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final colors = context.appColors;
    return Container(
      constraints: BoxConstraints(
        minWidth: NavDimens.badgeMin,
        minHeight: NavDimens.badgeMin,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: NavDimens.badgeHorizontalPadding,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.like,
        borderRadius: BorderRadius.circular(NavDimens.badgeRadius),
        border: Border.all(
          color: colors.badgeRing,
          width: NavDimens.badgeBorder,
        ),
      ),
      child: AppText(
        count > NavDimens.badgeMax ? '${NavDimens.badgeMax}+' : '$count',
        style: context.text.badge,
        color: colors.textOnPrimary,
        maxLines: 1,
      ),
    );
  }
}
