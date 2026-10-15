import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/feeling_dimens.dart';

/// One feeling: its emoji and word on a white tile. The chosen one is green-tinted with a ring and a check.
class FeelingTile extends StatelessWidget {
  const FeelingTile({
    super.key,
    required this.emoji,
    required this.word,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String word;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: isSelected ? context.l10n.postFeelingSelected(word) : word,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: FeelingDimens.tileSide),
          decoration: BoxDecoration(
            color: isSelected ? colors.primarySoft : colors.surface,
            borderRadius: BorderRadius.circular(FeelingDimens.tileRadius),
            border: isSelected
                ? Border.all(
                    color: colors.primary,
                    width: FeelingDimens.selectedBorder,
                  )
                : null,
          ),
          child: Row(
            children: [
              Text(emoji, style: context.text.emojiTile),
              SizedBox(width: FeelingDimens.tileGap),
              Expanded(
                child: AppText(
                  word,
                  style: context.text.tileLabel,
                  color: colors.textPrimary,
                  maxLines: 1,
                ),
              ),
              if (isSelected)
                AppSvgIcon(
                  AppAssets.check,
                  size: FeelingDimens.check,
                  color: colors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
