import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// "Paused" under the header while a sheet or dialog holds the story still.
class StoryPausedChip extends StatelessWidget {
  const StoryPausedChip({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.storyBlack.withValues(alpha: StoryOpacity.pausedChip),
        borderRadius: BorderRadius.circular(StorySheetDimens.pausedChipHeight),
      ),
      child: SizedBox(
        height: StorySheetDimens.pausedChipHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: StorySheetDimens.pausedChipPadding,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                AppAssets.pause,
                size: StorySheetDimens.pausedChipIcon,
                color: colors.storyOnDark,
              ),
              SizedBox(width: StorySheetDimens.pausedChipGap),
              AppText(
                context.l10n.storyPaused,
                style: context.text.chipLabel,
                color: colors.storyOnDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
