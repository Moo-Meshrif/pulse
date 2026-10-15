import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../dimens/post_card_dimens.dart';

/// The person badge at the start of the bottom of a photo that has people tagged: a tap shows or hides the
/// labels, a long press opens the list of everyone tagged.
class PostTagBadge extends StatelessWidget {
  const PostTagBadge({super.key, required this.onTap, this.onLongPress});

  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: context.l10n.postTagBadge,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: PostCardDimens.tagBadge,
          height: PostCardDimens.tagBadge,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.mediaChip,
          ),
          child: AppSvgIcon(
            AppAssets.user,
            size: PostCardDimens.tagBadgeIcon,
            color: colors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
