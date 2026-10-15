import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../../../../core/widgets/app_text.dart';
import '../../../../../core/widgets/avatar_initials.dart';
import '../../../domain/entity/post_tag_entity.dart';
import '../../dimens/post_card_dimens.dart';
import 'tag_spot.dart';

/// The names of the people tagged on one photo, each at the spot it was tagged (x, y in 0..1 of the
/// photo). A label tap opens that profile; your own is a white card that can remove your tag. The spots
/// are not mirrored in right-to-left.
class PostTagLabels extends StatelessWidget {
  const PostTagLabels({
    super.key,
    required this.tags,
    this.viewerId,
    this.onPerson,
    this.onRemoveMe,
  });

  /// Only the tags that have a spot on this photo.
  final List<PostTagEntity> tags;
  final String? viewerId;
  final ValueChanged<String>? onPerson;
  final VoidCallback? onRemoveMe;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => Stack(
      children: [
        for (final tag in tags)
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: TagSpotLayout(
                anchor: Offset(
                  (tag.x ?? 0) * box.maxWidth,
                  (tag.y ?? 0) * box.maxHeight,
                ),
                above: fitsAbove((tag.y ?? 0) * box.maxHeight),
                isOwn: tag.userId == viewerId,
              ),
              child: tag.userId == viewerId
                  ? _OwnLabel(
                      above: fitsAbove((tag.y ?? 0) * box.maxHeight),
                      onRemove: onRemoveMe,
                    )
                  : _Label(
                      tag: tag,
                      above: fitsAbove((tag.y ?? 0) * box.maxHeight),
                      onTap: onPerson == null
                          ? null
                          : () => onPerson!(tag.userId),
                    ),
            ),
          ),
      ],
    ),
  );

  /// The label goes above its spot unless that would leave the photo.
  static bool fitsAbove(double y) =>
      y >= PostCardDimens.tagLabelHeight + PostCardDimens.tagPointer;
}

class _Label extends StatelessWidget {
  const _Label({required this.tag, required this.above, this.onTap});

  final PostTagEntity tag;
  final bool above;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pill = Container(
      height: PostCardDimens.tagLabelHeight,
      padding: EdgeInsets.symmetric(horizontal: PostCardDimens.tagLabelPadding),
      decoration: BoxDecoration(
        color: colors.tagLabel,
        borderRadius: BorderRadius.circular(PostCardDimens.tagLabelRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            tag.username ?? '',
            style: context.text.countLabel,
            color: colors.textOnPrimary,
            maxLines: 1,
          ),
        ],
      ),
    );
    return Semantics(
      button: onTap != null,
      label: tag.username,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TagPointerWrap(
          above: above,
          color: colors.tagLabel,
          child: pill,
        ),
      ),
    );
  }
}

class _OwnLabel extends StatelessWidget {
  const _OwnLabel({required this.above, this.onRemove});

  final bool above;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final card = Container(
      padding: EdgeInsets.symmetric(horizontal: PostCardDimens.tagLabelPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(PostCardDimens.ownTagRadius),
        boxShadow: PostCardDimens.ownTagShadow,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: PostCardDimens.ownTagNameRow,
              child: Row(
                children: [
                  AvatarInitials(
                    name: l10n.postHeadlineYou,
                    seed: 'you',
                    size: PostCardDimens.ownTagAvatar,
                  ),
                  SizedBox(width: PostCardDimens.dotGap),
                  AppText(
                    l10n.postHeadlineYou,
                    style: context.text.countLabel,
                    color: colors.textPrimary,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Divider(color: colors.divider),
            Semantics(
              button: true,
              excludeSemantics: true,
              label: l10n.postTagRemoveLabel,
              onTap: onRemove,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                child: SizedBox(
                  height: PostCardDimens.ownTagActionRow,
                  child: Row(
                    children: [
                      AppSvgIcon(
                        AppAssets.userMinus,
                        size: PostCardDimens.ownTagIcon,
                        color: colors.danger,
                      ),
                      SizedBox(width: PostCardDimens.dotGap),
                      AppText(
                        l10n.postTagRemoveLabel,
                        style: context.text.countLabel,
                        color: colors.danger,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return TagPointerWrap(above: above, color: colors.surface, child: card);
  }
}
