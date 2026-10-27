import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../dimens/post_card_dimens.dart';
import '../utils/post_card_callbacks.dart';
import '../utils/post_card_data.dart';
import 'post_headline.dart';
import 'post_meta_line.dart';
import 'post_ringed_avatar.dart';
import 'post_tap_button.dart';

/// The top of a post card: avatar, the headline (name, feeling, tagged people), the meta line (place, time,
/// audience icon) and the options button, highlighted while its sheet is open.
class PostAuthorRow extends StatelessWidget {
  const PostAuthorRow({
    super.key,
    required this.data,
    required this.callbacks,
    this.isOptionsOpen = false,
    this.isEmbedded = false,
    this.showOptions = true,
    this.trailing,
  });

  final PostCardData data;
  final PostCardCallbacks callbacks;
  final bool isOptionsOpen;

  /// Inside the frame of a share: a smaller picture and no options button.
  final bool isEmbedded;

  /// False on the post page, whose top bar has the options button.
  final bool showOptions;

  /// Drawn before the options button (the post page's Follow chip).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        button: callbacks.onProfile != null,
        label: data.authorName,
        excludeSemantics: true,
        onTap: callbacks.onProfile,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: callbacks.onProfile,
          child: PostRingedAvatar(
            authorId: data.authorId,
            name: data.authorName,
            avatarUrl: data.authorAvatarUrl,
            size: isEmbedded ? PostCardDimens.embedAvatar : null,
          ),
        ),
      ),
      SizedBox(width: PostCardDimens.authorGap),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PostHeadline(data: data, callbacks: callbacks),
            PostMetaLine(
              location: data.city,
              createdAt: data.createdAt,
              audienceIcon: data.audienceIcon,
              onLocation: callbacks.onLocation,
              onTime: callbacks.onOpenPost,
            ),
          ],
        ),
      ),
      ?trailing,
      if (!isEmbedded && showOptions)
        _MoreButton(isOpen: isOptionsOpen, onTap: callbacks.onOptions),
    ],
  );
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.isOpen, required this.onTap});

  final bool isOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PostTapButton(
      label: context.l10n.postOptions,
      onTap: onTap,
      child: Container(
        width: PostCardDimens.moreTapTarget,
        height: PostCardDimens.moreTapTarget,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOpen ? colors.primarySoft : Colors.transparent,
        ),
        child: AppSvgIcon(
          AppAssets.moreHorizontal,
          size: PostCardDimens.moreIcon,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}
