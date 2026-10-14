import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_text.dart';
import '../utils/post_author_meta.dart';
import 'post_ringed_avatar.dart';
import 'post_tap_button.dart';

/// The top of a post card: avatar, name, `{city} · {time}` with an audience icon for a post that is not
/// public, and the options button, highlighted while its sheet is open.
class PostAuthorRow extends StatelessWidget {
  const PostAuthorRow({
    super.key,
    required this.authorId,
    required this.name,
    this.avatarUrl,
    this.city,
    required this.createdAt,
    this.audienceIcon,
    this.isOptionsOpen = false,
    this.onProfile,
    this.onOptions,
  });

  final String authorId;
  final String name;
  final String? avatarUrl;
  final String? city;
  final DateTime createdAt;
  final String? audienceIcon;
  final bool isOptionsOpen;
  final VoidCallback? onProfile;
  final VoidCallback? onOptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final meta = postAuthorMeta(context, city: city, createdAt: createdAt);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: onProfile != null,
            label: name,
            excludeSemantics: true,
            onTap: onProfile,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onProfile,
              child: Row(
                children: [
                  PostRingedAvatar(
                    authorId: authorId,
                    name: name,
                    avatarUrl: avatarUrl,
                  ),
                  SizedBox(width: PostCardDimens.authorGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          name,
                          style: context.text.name,
                          color: colors.textPrimary,
                          maxLines: 1,
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: AppText(
                                meta,
                                style: context.text.caption,
                                color: colors.textSecondary,
                                maxLines: 1,
                              ),
                            ),
                            if (audienceIcon != null) ...[
                              SizedBox(width: PostCardDimens.dotGap),
                              AppSvgIcon(
                                audienceIcon!,
                                size: PostCardDimens.visibilityIcon,
                                color: colors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _MoreButton(isOpen: isOptionsOpen, onTap: onOptions),
      ],
    );
  }
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
