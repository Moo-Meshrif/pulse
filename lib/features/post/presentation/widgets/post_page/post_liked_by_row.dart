import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../domain/entity/liked_by_preview_entity.dart';
import '../../cubit/post_page/post_page_cubit.dart';
import '../../cubit/post_page/post_page_state.dart';
import '../../dimens/post_likes_dimens.dart';
import '../post_person_avatar.dart';

/// "Liked by salma.ash and 1,203 others" with up to two overlapping avatars, under the post's actions on
/// the post page. A tap opens the likes list. Not drawn when nobody else liked the post.
class PostLikedByRow extends StatelessWidget {
  const PostLikedByRow({super.key, required this.postId});

  final String postId;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostPageCubit, PostPageState, LikedByPreviewEntity?>(
        selector: (state) => state.likedBy,
        builder: (context, likedBy) => likedBy == null
            ? const SizedBox.shrink()
            : _Row(
                likedBy: likedBy,
                onTap: () => AppNavigator.push<void>(
                  context,
                  AppRoutes.postLikes(postId),
                  rootNavigator: true,
                ),
              ),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.likedBy, required this.onTap});

  final LikedByPreviewEntity likedBy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final others = likedBy.others > 0
        ? l10n.postLikedByOthers(likedBy.others)
        : null;
    final name = likedBy.isOnlyMe ? l10n.postLikedByYouName : likedBy.firstName;
    final text = likedBy.isOnlyMe
        ? l10n.postLikedByYou
        : others == null
        ? l10n.postLikedByOne(likedBy.firstName)
        : l10n.postLikedBy(likedBy.firstName, others);
    return Semantics(
      button: true,
      label: text,
      hint: l10n.postLikesOpen,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: PostLikesDimens.likedMinHeight,
          ),
          child: Padding(
            padding: PostLikesDimens.likedPadding,
            child: Row(
              children: [
                _Avatars(avatars: likedBy.avatars),
                SizedBox(width: PostLikesDimens.likedGap),
                Expanded(
                  child: Text.rich(
                    _spans(context, text, [name, ?others]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// [text] with each of [bold] in bold, in the order they appear.
  TextSpan _spans(BuildContext context, String text, List<String> bold) {
    final colors = context.appColors;
    final base = context.text.caption.copyWith(
      fontSize: context.text.label.fontSize,
      color: colors.textPrimary,
    );
    final strong = base.copyWith(fontWeight: FontWeight.w700);
    final spans = <TextSpan>[];
    var start = 0;
    for (final part in bold) {
      final at = text.indexOf(part, start);
      if (at < 0) continue;
      if (at > start) spans.add(TextSpan(text: text.substring(start, at)));
      spans.add(TextSpan(text: part, style: strong));
      start = at + part.length;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));
    return TextSpan(style: base, children: spans);
  }
}

/// Up to two avatars, each overlapping the one before it.
class _Avatars extends StatelessWidget {
  const _Avatars({required this.avatars});

  final List<LikedByAvatarEntity> avatars;

  @override
  Widget build(BuildContext context) {
    final size = PostLikesDimens.likedAvatar;
    final step = size - PostLikesDimens.likedOverlap;
    final surface = context.appColors.surface;
    return SizedBox(
      width: avatars.isEmpty ? 0 : size + step * (avatars.length - 1),
      height: size,
      child: Stack(
        children: [
          // The first person is on top, so they are drawn last.
          for (var i = avatars.length - 1; i >= 0; i--)
            PositionedDirectional(
              start: step * i,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: surface,
                    width: PostLikesDimens.likedRing,
                  ),
                ),
                child: PostPersonAvatar(
                  id: avatars[i].id,
                  name: avatars[i].name,
                  url: avatars[i].avatarUrl,
                  size: size,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
