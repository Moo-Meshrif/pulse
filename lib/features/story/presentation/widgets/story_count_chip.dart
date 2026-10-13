import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

class StoryCountChip extends StatelessWidget {
  const StoryCountChip({super.key, required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: context.l10n.storyViewers(count),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: StoryDimens.replyAction),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvgIcon(
                AppAssets.eye,
                size: StoryDimens.countIcon,
                color: colors.storyOnDark,
              ),
              SizedBox(width: AppSpacing.s8),
              AppText(
                '$count',
                style: context.text.countLabel,
                color: colors.storyOnDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
