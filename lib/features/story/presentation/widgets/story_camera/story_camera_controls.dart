import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
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
                  dimension: CameraPermissionDimens.roundControl,
                  child: Center(
                    child: Container(
                      width: StoryCameraDimens.galleryThumb,
                      height: StoryCameraDimens.galleryThumb,
                      decoration: BoxDecoration(
                        color: StoryColors.control,
                        borderRadius: BorderRadius.circular(
                          StoryCameraDimens.galleryRadius,
                        ),
                        border: Border.all(
                          color: colors.onDark,
                          width: StoryCameraDimens.galleryBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AppSvgIcon(
                        AppAssets.image,
                        size: StoryCameraDimens.controlIcon,
                        color: colors.onDark,
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
                  width: CameraPermissionDimens.roundControl,
                  height: CameraPermissionDimens.roundControl,
                  decoration: BoxDecoration(
                    color: StoryColors.control,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: AppSvgIcon(
                    AppAssets.cameraFlip,
                    size: StoryCameraDimens.controlIcon,
                    color: colors.onDark,
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
