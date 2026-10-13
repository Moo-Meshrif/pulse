import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../utils/format_story_timer.dart';

/// X at the start, "Story" in the middle (the red timer chip while recording), flash at the end.
class StoryCameraTopBar extends StatelessWidget {
  const StoryCameraTopBar({
    super.key,
    required this.isRecording,
    required this.elapsed,
    required this.hasFlash,
    required this.isFlashOn,
    required this.onClose,
    required this.onFlash,
  });

  final bool isRecording;
  final Duration elapsed;
  final bool hasFlash;
  final bool isFlashOn;
  final VoidCallback onClose;
  final VoidCallback onFlash;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: StoryCameraDimens.topBarHeight,
      child: Row(
        children: [
          _RoundIcon(
            asset: AppAssets.close,
            size: StoryCameraDimens.closeIcon,
            label: context.l10n.close,
            color: colors.storyOnDark,
            onTap: onClose,
          ),
          Expanded(
            child: Center(
              child: isRecording
                  ? _TimerChip(elapsed: elapsed)
                  : AppText(
                      context.l10n.storyCameraTitle,
                      style: context.text.cameraTitle,
                      color: colors.storyOnDark,
                      maxLines: 1,
                    ),
            ),
          ),
          // A front camera has no flash: no button, and a gap the size of one so the title stays centred.
          if (hasFlash)
            _RoundIcon(
              asset: AppAssets.flash,
              size: StoryCameraDimens.controlIcon,
              label: isFlashOn
                  ? context.l10n.storyFlashOn
                  : context.l10n.storyFlash,
              color: isFlashOn ? colors.storyWarning : colors.storyOnDark,
              onTap: onFlash,
            )
          else
            const SizedBox(width: StoryCameraDimens.roundControl),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.asset,
    required this.size,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String asset;
  final double size;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: StoryCameraDimens.roundControl / 2,
      child: SizedBox.square(
        dimension: StoryCameraDimens.roundControl,
        child: Center(
          child: AppSvgIcon(asset, size: size, color: color),
        ),
      ),
    ),
  );
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.elapsed});

  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final time = formatStoryTimer(elapsed);
    return Semantics(
      liveRegion: false,
      label: context.l10n.storyRecordingTime(time),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.like,
          borderRadius: BorderRadius.circular(StoryCameraDimens.timerHeight),
        ),
        child: SizedBox(
          height: StoryCameraDimens.timerHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: StoryCameraDimens.timerPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: StoryCameraDimens.timerDot,
                  height: StoryCameraDimens.timerDot,
                  decoration: BoxDecoration(
                    color: colors.storyOnDark,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                AppText(
                  time,
                  style: context.text.action,
                  color: colors.storyOnDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
