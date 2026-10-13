import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';

/// A small pill on a dark surface ("Edit", "Fix"): white at 14% behind a [label] in [color].
class TintedChip extends StatelessWidget {
  const TintedChip({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.storyOnDark.withValues(
              alpha: StoryOpacity.secondaryFill,
            ),
            borderRadius: BorderRadius.circular(
              StoryPermissionDimens.fixChipHeight,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
          child: AppText(
            label,
            style: context.text.label,
            maxLines: 1,
            color: color,
          ),
        ),
      ),
    );
  }
}
