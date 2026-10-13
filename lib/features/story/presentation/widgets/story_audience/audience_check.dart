import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';

/// The round selector at the end of a row: a green circle with a check when [selected], an empty ring
/// when not.
class AudienceCheck extends StatelessWidget {
  const AudienceCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = StoryPermissionDimens.okCircle;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : StoryMotion.uiFade,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.storySuccess : Colors.transparent,
        border: selected
            ? null
            : Border.all(
                color: colors.storyOnDark.withValues(
                  alpha: StoryOpacity.fieldBorder,
                ),
                width: StoryDimens.replyBorder,
              ),
      ),
      alignment: Alignment.center,
      child: selected
          ? AppSvgIcon(
              AppAssets.check,
              size: size * 0.6,
              color: colors.textPrimary,
            )
          : null,
    );
  }
}
