import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../post/presentation/widgets/post_person_avatar.dart';
import '../../dimens/home_dimens.dart';
import '../../utils/feed_floaters_rules.dart';
import '../../utils/feed_post.dart';

/// The pill over the feed that says new posts are waiting: avatars of up to three of their authors, an
/// arrow and the words. One tap takes them there. It sits in the same place in Arabic; the arrow does not
/// mirror.
class NewPostsPill extends StatelessWidget {
  const NewPostsPill({super.key, required this.pending, required this.onTap});

  final List<FeedPost> pending;
  final VoidCallback onTap;

  /// One avatar per author, newest first.
  List<FeedPost> get _authors {
    final seen = <String>{};
    return [
      for (final post in pending)
        if (seen.add(post.entity.authorId)) post,
    ].take(HomeDimens.pillAvatars).toList();
  }

  String _label(BuildContext context) {
    final l10n = context.l10n;
    return switch (FeedFloatersRules.labelFor(pending.length)) {
      NewPostsLabel.plain => l10n.homeNewPosts,
      NewPostsLabel.count => l10n.homeNewPostsCount(pending.length),
      NewPostsLabel.many => l10n.homeNewPostsMany,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      button: true,
      liveRegion: true,
      label: context.l10n.homeNewPostsOpen(pending.length),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: HomeDimens.pillHeight,
          padding: HomeDimens.pillPadding,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(HomeDimens.pillRadius),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withAlpha(HomeDimens.pillShadowAlpha),
                offset: Offset(0, HomeDimens.pillShadowDy),
                blurRadius: HomeDimens.pillShadowBlur,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Avatars(authors: _authors),
              SizedBox(width: HomeDimens.pillGap),
              AppSvgIcon(
                AppAssets.arrowUpBold,
                size: HomeDimens.pillArrow,
                color: colors.textOnPrimary,
              ),
              SizedBox(width: HomeDimens.pillGap),
              AppText(
                _label(context),
                style: context.text.action,
                color: colors.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The authors' round pictures, each in a ring of the pill's color, overlapping.
class _Avatars extends StatelessWidget {
  const _Avatars({required this.authors});

  final List<FeedPost> authors;

  @override
  Widget build(BuildContext context) {
    final size = HomeDimens.pillAvatar;
    final step = size - HomeDimens.pillAvatarOverlap;
    final ring = HomeDimens.pillAvatarRing;
    return SizedBox(
      width: size + step * (authors.length - 1),
      height: size,
      child: Stack(
        children: [
          for (final (i, post) in authors.indexed)
            PositionedDirectional(
              start: step * i,
              child: Container(
                padding: EdgeInsets.all(ring),
                decoration: BoxDecoration(
                  color: context.appColors.primary,
                  shape: BoxShape.circle,
                ),
                child: PostPersonAvatar(
                  id: post.entity.authorId,
                  name: post.entity.fullName ?? post.entity.username,
                  url: post.entity.avatarUrl,
                  size: size - ring * 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
