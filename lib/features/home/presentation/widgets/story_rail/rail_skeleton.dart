import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../dimens/home_dimens.dart';
import '../skeleton_effect.dart';

/// [RailSkeleton] with its shimmer and loading label: what Home shows until the rail's first answer.
class RailSkeletonZone extends StatelessWidget {
  const RailSkeletonZone({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.loading,
    child: ExcludeSemantics(
      child: Skeletonizer.zone(
        effect: homeSkeletonEffect(context),
        child: const RailSkeleton(),
      ),
    ),
  );
}

/// The Stories rail as shapes: "Your story" and a few people. Draw it inside a `Skeletonizer.zone`.
class RailSkeleton extends StatelessWidget {
  const RailSkeleton({super.key});

  @override
  // More circles than fit: the row is cut off at the edge, as the real rail is.
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: const NeverScrollableScrollPhysics(),
    padding: StoryRailDimens.railRowPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i <= HomeDimens.skeletonStories; i++) ...[
          if (i > 0) SizedBox(width: StoryRailDimens.railGap),
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
      Bone.circle(size: StoryRailDimens.railAvatar),
      SizedBox(height: StoryRailDimens.railLabelGap),
      Bone.text(
        width: HomeDimens.skeletonLabelWidth,
        style: context.text.caption,
      ),
    ],
  );
}
