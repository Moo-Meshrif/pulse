import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_composer_dimens.dart';

/// The dashed "+ Add" tile at the end of the media strip.
class AddMediaTile extends StatelessWidget {
  const AddMediaTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.l10n.newPostAdd;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          foregroundPainter: DashedRoundedRectPainter(
            color: colors.dashed,
            radius: PostComposerDimens.thumbRadius,
            width: PostComposerDimens.addBorderWidth,
          ),
          child: Container(
            width: PostComposerDimens.thumb,
            height: PostComposerDimens.thumb,
            decoration: BoxDecoration(
              color: colors.addFill,
              borderRadius: BorderRadius.circular(
                PostComposerDimens.thumbRadius,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppSvgIcon(
                  AppAssets.plus,
                  size: PostComposerDimens.addPlus,
                  color: colors.primary,
                ),
                AppText(
                  label,
                  style: context.text.action,
                  color: colors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
