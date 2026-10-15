import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';

/// The round selector at the end of a row: a green circle with a check when [selected], an empty ring
/// when not.
class AudienceCheck extends StatelessWidget {
  const AudienceCheck({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = CameraPermissionDimens.okCircle;
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : StoryMotion.uiFade,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.successOnDark : Colors.transparent,
        border: selected
            ? null
            : Border.all(
                color: colors.onDark.withValues(alpha: DarkOpacity.fieldBorder),
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
