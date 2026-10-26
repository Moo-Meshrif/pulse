import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/widgets/skeleton_effect.dart';
import '../../dimens/home_dimens.dart';
import '../post_card_skeleton.dart';

/// What the feed looks like before its first posts arrive: a few post cards as
/// shimmering shapes. The shimmer sweeps from start to end (mirrored in RTL) and stands still when the
/// system asks to reduce motion (docs/specs/home/02-components.md C14).
class FeedSkeleton extends StatelessWidget {
  const FeedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final effect = skeletonEffect(context);
    return Semantics(
      liveRegion: true,
      label: context.l10n.loading,
      child: ExcludeSemantics(
        child: Skeletonizer.zone(
          effect: effect,
          child: Padding(
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
        ),
      ),
    );
  }
}

/// The next page of the feed while it loads: one post card as a shimmering shape under the last post.
class FeedMoreSkeleton extends StatelessWidget {
  const FeedMoreSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.loading,
    child: ExcludeSemantics(
      child: Skeletonizer.zone(
        effect: skeletonEffect(context),
        child: Padding(
          padding: HomeDimens.listPadding,
          child: const PostCardSkeleton(),
        ),
      ),
    ),
  );
}
