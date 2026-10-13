import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../story_avatar.dart';

/// The bottom row: the "Your story" pill (who posts it; the audience picker comes later, Q18) and Share.
class StoryEditActions extends StatelessWidget {
  const StoryEditActions({
    super.key,
    required this.me,
    required this.isSharing,
    required this.onShare,
  });

  final LastAccountEntity? me;
  final bool isSharing;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final height = StoryCameraDimens.actionHeight;
    return Row(
      spacing: StoryCameraDimens.actionGap,
      children: [
        Expanded(
          child: Container(
            height: height,
            padding: EdgeInsetsDirectional.only(
              start: AppSpacing.s12,
              end: AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              color: colors.storyControl,
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Row(
              children: [
                StoryAvatar(
                  size: StoryCameraDimens.audienceAvatar,
                  ringWidth: StoryCameraDimens.audienceAvatarRing,
                  seed: me?.id ?? '',
                  name: me?.fullName ?? me?.username,
                  imageUrl: me?.avatarUrl,
                ),
                SizedBox(width: AppSpacing.s8),
                Flexible(
                  child: AppText(
                    l10n.storyYourStoryPill,
                    style: context.text.name,
                    color: colors.storyOnDark,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Semantics(
          button: true,
          label: l10n.storyShare,
          excludeSemantics: true,
          child: SizedBox(
            width: StoryCameraDimens.sharePill,
            height: height,
            child: FilledButton(
              onPressed: isSharing ? null : onShare,
              style: FilledButton.styleFrom(
                backgroundColor: colors.storyOnDark,
                disabledBackgroundColor: colors.storyOnDark,
                foregroundColor: colors.textPrimary,
                padding: EdgeInsets.zero,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: isSharing
                  ? PulseLineLoader(
                      color: colors.textPrimary,
                      width: StoryCameraDimens.sharePill / 2,
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown, // a long label at a large text size shrinks, not overflows
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppText(
                            l10n.storyShare,
                            style: context.text.name,
                            color: colors.textPrimary,
                          ),
                          SizedBox(width: AppSpacing.s4),
                          AppSvgIcon(
                            AppAssets.chevronRight,
                            size: StoryCameraDimens.shareChevron,
                            color: colors.textPrimary,
                            directional: true,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
