import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../dimens/home_dimens.dart';
import '../post_card_skeleton.dart';
import '../story_rail/rail_skeleton.dart';

/// What the feed looks like before its first posts arrive: the Stories rail and a few post cards as
/// shimmering shapes. The shimmer sweeps from start to end (mirrored in RTL) and stands still when the
/// system asks to reduce motion (docs/specs/home/02-components.md C14).
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final PaintingEffect effect = MediaQuery.disableAnimationsOf(context)
        ? SolidColorEffect(color: colors.skeletonBase)
        : ShimmerEffect(
            baseColor: colors.skeletonBase,
            highlightColor: colors.skeletonHighlight,
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            duration: HomeDimens.skeletonSweep,
          );
    return Semantics(
      liveRegion: true,
      label: context.l10n.loading,
      child: ExcludeSemantics(
        child: Skeletonizer.zone(
          effect: effect,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RailSkeleton(),
              Padding(
                padding: HomeDimens.listPadding,
                child: Column(
                  children: [
                    for (var i = 0; i < HomeDimens.skeletonCards; i++)
                      Padding(
                        padding: EdgeInsets.only(bottom: HomeDimens.cardGap),
                        child: const PostCardSkeleton(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
