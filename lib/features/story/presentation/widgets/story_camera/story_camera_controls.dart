import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import 'story_shutter.dart';

/// Gallery at the start, shutter in the middle, flip camera at the end.
class StoryCameraControls extends StatelessWidget {
  const StoryCameraControls({
    super.key,
    required this.isRecording,
    required this.progress,
    required this.onGallery,
    required this.onFlip,
    required this.onTap,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final bool isRecording;
  final double progress;
  final VoidCallback onGallery;
  final VoidCallback onFlip;
  final VoidCallback onTap;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: StoryCameraDimens.bottomRowSide,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The thumbnail of the last library photo needs a gallery-reading package (photo_manager):
          // a plain tile stands in until the user decides to add it.
          Opacity(
            opacity: isRecording ? 0 : 1,
            child: Semantics(
              button: true,
              label: context.l10n.storyGallery,
              excludeSemantics: true,
              child: InkWell(
                onTap: isRecording ? null : onGallery,
                borderRadius: BorderRadius.circular(
                  StoryCameraDimens.galleryRadius,
                ),
                child: SizedBox.square(
                  dimension: StoryCameraDimens.roundControl,
                  child: Center(
                    child: Container(
                      width: StoryCameraDimens.galleryThumb,
                      height: StoryCameraDimens.galleryThumb,
                      decoration: BoxDecoration(
                        color: colors.storyControl,
                        borderRadius: BorderRadius.circular(
                          StoryCameraDimens.galleryRadius,
                        ),
                        border: Border.all(
                          color: colors.storyOnDark,
                          width: StoryCameraDimens.galleryBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AppSvgIcon(
                        AppAssets.image,
                        size: StoryCameraDimens.controlIcon,
                        color: colors.storyOnDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          StoryShutter(
            isRecording: isRecording,
            progress: progress,
            onTap: onTap,
            onHoldStart: onHoldStart,
            onHoldEnd: onHoldEnd,
          ),
          Opacity(
            opacity: isRecording ? StoryOpacity.recordTrack : 1,
            child: Semantics(
              button: true,
              label: context.l10n.storyFlipCamera,
              excludeSemantics: true,
              child: InkResponse(
                onTap: isRecording ? null : onFlip,
                child: Container(
                  width: StoryCameraDimens.roundControl,
                  height: StoryCameraDimens.roundControl,
                  decoration: BoxDecoration(
                    color: colors.storyControl,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    AppAssets.cameraFlip,
                    size: StoryCameraDimens.controlIcon,
                    color: colors.storyOnDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
