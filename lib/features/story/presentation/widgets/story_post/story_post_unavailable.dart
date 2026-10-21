import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';

/// Takes the place of a story's post sticker when the post was deleted or can't be seen: a frosted card,
/// not tappable.
class StoryPostUnavailable extends StatelessWidget {
  const StoryPostUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label:
          '${l10n.storyPostUnavailableTitle}. ${l10n.storyPostUnavailableBody}',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(StoryPostDimens.unavailableRadius),
        child: BackdropBlur(
          sigma: StoryPostDimens.unavailableBlur,
          child: Container(
            width: StoryPostDimens.unavailableWidth,
            padding: EdgeInsets.all(StoryPostDimens.unavailablePadding),
            color: colors.onDark.withValues(
              alpha: StoryOpacity.unavailableFill,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.s8,
              children: [
                AppSvgIcon(
                  AppAssets.lock,
                  size: StoryPostDimens.unavailableIcon,
                  color: colors.onDark,
                ),
                AppText(
                  l10n.storyPostUnavailableTitle,
                  style: context.text.button,
                  color: colors.onDark,
                  textAlign: TextAlign.center,
                ),
                AppText(
                  l10n.storyPostUnavailableBody,
                  style: context.text.bodyXs,
                  color: colors.onDark.withValues(alpha: StoryOpacity.hint),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
