import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/colors/app_colors.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';

/// Over the edit screen while a video is saved to the device: it takes a while, so it shows how far it is
/// and keeps taps off the screen.
class StorySavingOverlay extends StatelessWidget {
  const StorySavingOverlay({super.key, required this.progress});

  /// 0..1.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final percent = (progress.clamp(0.0, 1.0) * 100).round();
    return Positioned.fill(
      child: AbsorbPointer(
        child: ColoredBox(
          color: colors.black.withValues(alpha: StoryOpacity.savingScrim),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: StorySavingDimens.gap,
              children: [
                SizedBox.square(
                  dimension: StorySavingDimens.ring,
                  child: CircularProgressIndicator(
                    value: progress <= 0 ? null : progress.clamp(0.0, 1.0),
                    strokeWidth: StorySavingDimens.stroke,
                    color: colors.onDark,
                    backgroundColor: StoryColors.control,
                  ),
                ),
                AppText(
                  context.l10n.storySavingVideo(percent),
                  style: context.text.chipLabel,
                  color: colors.onDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
