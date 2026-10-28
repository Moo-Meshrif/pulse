import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/post_likes_dimens.dart';
import '../../dimens/post_page_dimens.dart';

/// One person row as shapes under the shimmer, in the likes card: what the list shows before the first
/// page arrives, and (`.loadMore()`) under the last row while the next page loads.
class PostLikesSkeleton extends StatelessWidget {
  const PostLikesSkeleton({super.key}) : _loadMore = false;

  const PostLikesSkeleton.loadMore({super.key}) : _loadMore = true;

  final bool _loadMore;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.loading,
    child: ExcludeSemantics(
      child: Padding(
        padding: _loadMore
            ? EdgeInsets.symmetric(horizontal: PostLikesDimens.listPadding.left)
            : PostLikesDimens.listPadding,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(PostLikesDimens.cardRadius),
          ),
          child: Skeletonizer.zone(
            effect: skeletonEffect(context),
            child: Column(children: const [_Row()]),
          ),
        ),
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row();

  @override
  Widget build(BuildContext context) => Padding(
    padding: PostLikesDimens.rowPadding,
    child: SizedBox(
      height: PostLikesDimens.rowMinHeight,
      child: Row(
        children: [
          Bone.circle(size: PostLikesDimens.rowAvatar),
          SizedBox(width: PostLikesDimens.rowGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.text(
                  width: PostLikesDimens.skeletonNameWidth,
                  style: context.text.name,
                ),
                Bone.text(
                  width: PostLikesDimens.skeletonNameWidth / 2,
                  style: context.text.label,
                ),
              ],
            ),
          ),
          Bone.button(
            width: PostLikesDimens.skeletonButtonWidth,
            height: PostPageDimens.followHeight,
          ),
        ],
      ),
    ),
  );
}
