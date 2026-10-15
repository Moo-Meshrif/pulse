import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../dimens/post_card_dimens.dart';
import '../post_tap_button.dart';

/// The round button on a video that switches the sound for the whole list.
class PostMuteButton extends StatelessWidget {
  const PostMuteButton({super.key, required this.isMuted, required this.onTap});

  final bool isMuted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = isMuted
        ? context.l10n.postUnmuteVideo
        : context.l10n.postMuteVideo;
    return PostTapButton(
      isContainer: true,
      label: label,
      onTap: onTap,
      child: Container(
        width: PostCardDimens.muteButton,
        height: PostCardDimens.muteButton,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.mediaChip,
        ),
        alignment: Alignment.center,
        child: AppSvgIcon(
          isMuted ? AppAssets.volumeOff : AppAssets.volume,
          size: PostCardDimens.muteIcon,
          color: colors.textOnPrimary,
        ),
      ),
    );
  }
}
