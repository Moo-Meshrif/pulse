import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// The Stories rail as shapes: "Your story" and a few people. Draw it inside a `Skeletonizer.zone`.
class RailSkeleton extends StatelessWidget {
  const RailSkeleton({super.key});

  @override
  // More circles than fit: the row is cut off at the edge, as the real rail is.
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const NeverScrollableScrollPhysics(),
    padding: StoryDimens.railRowPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i <= HomeDimens.skeletonStories; i++) ...[
          if (i > 0) SizedBox(width: StoryDimens.railGap),
          const _Person(),
        ],
      ],
    ),
  );
}

class _Person extends StatelessWidget {
  const _Person();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Bone.circle(size: StoryDimens.railAvatar),
      SizedBox(height: StoryDimens.railLabelGap),
      Bone.text(
        width: HomeDimens.skeletonLabelWidth,
        style: context.text.caption,
      ),
    ],
  );
}
