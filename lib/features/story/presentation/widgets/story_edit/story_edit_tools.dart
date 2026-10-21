import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_dimens.dart';

/// The tool column at the end: text, location, background palette, mute for a video, save. A tool whose
/// callback is null is left out (a story that shows a post has no location, a photo story no palette).
class StoryEditTools extends StatelessWidget {
  const StoryEditTools({
    super.key,
    this.isVideo = false,
    this.isMuted = false,
    required this.onText,
    this.onLocation,
    this.onPalette,
    this.onMute,
    required this.onSave,
  });

  final bool isVideo;
  final bool isMuted;
  final VoidCallback onText;
  final VoidCallback? onLocation;
  final VoidCallback? onPalette;
  final VoidCallback? onMute;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: StoryCameraDimens.toolGap,
      children: [
        _Tool(asset: AppAssets.text, label: l10n.storyToolText, onTap: onText),
        if (onLocation != null)
          _Tool(
            asset: AppAssets.location,
            label: l10n.storyToolLocation,
            onTap: onLocation!,
          ),
        if (onPalette != null)
          _Tool(
            asset: AppAssets.palette,
            label: l10n.storyToolBackground,
            onTap: onPalette!,
          ),
        if (isVideo && onMute != null)
          _Tool(
            asset: isMuted ? AppAssets.volumeOff : AppAssets.volume,
            label: isMuted ? l10n.storyToolUnmute : l10n.storyToolMute,
            onTap: onMute!,
          ),
        _Tool(
          asset: AppAssets.download,
          label: l10n.storySaveToDevice,
          onTap: onSave,
        ),
      ],
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({required this.asset, required this.label, required this.onTap});

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: StoryCameraDimens.tool / 2,
        child: Container(
          width: StoryCameraDimens.tool,
          height: StoryCameraDimens.tool,
          decoration: BoxDecoration(
            color: StoryColors.tool,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: AppSvgIcon(
            asset,
            size: StoryCameraDimens.toolIcon,
            color: context.appColors.onDark,
          ),
        ),
      ),
    );
  }
}
