import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../follow/data/enums/follow_status.dart';
import '../../../domain/entity/post_liker_entity.dart';
import '../../dimens/post_likes_dimens.dart';
import '../post_follow_button.dart';
import '../post_person_avatar.dart';

/// A person in the likes list: avatar, name, @username and the Follow button. No button on your own row.
class PostLikerRow extends StatelessWidget {
  const PostLikerRow({
    super.key,
    required this.liker,
    required this.isMe,
    required this.onTap,
    required this.onFollow,
  });

  final PostLikerEntity liker;
  final bool isMe;
  final VoidCallback onTap;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = liker.displayName;
    return Semantics(
      button: true,
      label: '$name, @${liker.username}',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: PostLikesDimens.rowMinHeight),
          child: Padding(
            padding: PostLikesDimens.rowPadding,
            child: Row(
              children: [
                PostPersonAvatar(
                  id: liker.id,
                  name: name,
                  size: PostLikesDimens.rowAvatar,
                  url: liker.avatarUrl,
                ),
                SizedBox(width: PostLikesDimens.rowGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText(
                        name,
                        style: context.text.name,
                        color: colors.textPrimary,
                        maxLines: 1,
                      ),
                      AppText(
                        '@${liker.username}',
                        style: context.text.label,
                        color: colors.textSecondary,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                if (!isMe) ...[
                  SizedBox(width: PostLikesDimens.rowGap),
                  _FollowButton(liker: liker, onTap: onFollow),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.liker, required this.onTap});

  final PostLikerEntity liker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = liker.displayName;
    final isFollowing = liker.follow != FollowStatus.none;
    return PostFollowButton(
      isFollowing: isFollowing,
      label: isFollowing
          ? l10n.postFollowing
          : liker.followsMe
          ? l10n.postLikesFollowBack
          : l10n.postFollow,
      semanticsLabel: switch (liker.follow) {
        FollowStatus.accepted => l10n.unfollowPerson(name),
        FollowStatus.pending => l10n.cancelRequestPerson(name),
        FollowStatus.none => l10n.followPerson(name),
      },
      onTap: onTap,
    );
  }
}
