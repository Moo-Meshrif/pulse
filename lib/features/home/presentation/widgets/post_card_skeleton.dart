import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../post/presentation/dimens/post_card_dimens.dart';
import '../dimens/home_dimens.dart';

/// A post card as shapes: the author row, two lines of caption, the picture and the action bar. Draw it
/// inside a `Skeletonizer.zone`.
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key});

  /// The picture's shape while its real size is unknown.
  static const _mediaAspect = 1.7;

  @override
  Widget build(BuildContext context) => Container(
    padding: PostCardDimens.padding,
    decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(PostCardDimens.radius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Bone.circle(size: PostCardDimens.avatar),
            SizedBox(width: PostCardDimens.authorGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(
                    width: HomeDimens.skeletonNameWidth,
                    style: context.text.name,
                  ),
                  SizedBox(height: PostCardDimens.actionGap),
                  Bone.text(
                    width: HomeDimens.skeletonMetaWidth,
                    style: context.text.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: PostCardDimens.captionMargin,
          child: const Bone.multiText(lines: 2),
        ),
        AspectRatio(
          aspectRatio: _mediaAspect,
          child: Bone(
            borderRadius: BorderRadius.circular(PostCardDimens.mediaRadius),
          ),
        ),
        SizedBox(
          height: PostCardDimens.actionBarHeight + PostCardDimens.actionBarTop,
          child: Row(
            children: [
              Bone.circle(size: PostCardDimens.actionIcon),
              SizedBox(width: PostCardDimens.actionHorizontal * 2),
              Bone.circle(size: PostCardDimens.actionIcon),
              SizedBox(width: PostCardDimens.actionHorizontal * 2),
              Bone.circle(size: PostCardDimens.shareIcon),
              const Spacer(),
              Bone.circle(size: PostCardDimens.saveIcon),
            ],
          ),
        ),
      ],
    ),
  );
}
