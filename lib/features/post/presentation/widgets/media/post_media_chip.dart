import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../dimens/post_card_dimens.dart';

/// A small label on the media: the "1/4" counter and the video duration.
class PostMediaChip extends StatelessWidget {
  const PostMediaChip({super.key, required this.text, this.radius});

  final String text;

  /// The counter's radius when null.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: PostCardDimens.chipPadding,
      decoration: BoxDecoration(
        color: colors.mediaChip,
        borderRadius: BorderRadius.circular(
          radius ?? PostCardDimens.counterRadius,
        ),
      ),
      child: AppText(
        text,
        style: context.text.chip,
        color: colors.textOnPrimary,
      ),
    );
  }
}
