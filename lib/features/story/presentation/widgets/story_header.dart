import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import '../utils/story_age.dart';
import 'story_avatar.dart';

class StoryHeader extends StatelessWidget {
  const StoryHeader({
    super.key,
    required this.person,
    required this.postedAt,
    this.onMore,
    required this.onClose,
  });

  final StoryRailItemEntity person;
  final DateTime? postedAt;

  /// Null hides the "···" button (the loading screen).
  final VoidCallback? onMore;
  final VoidCallback onClose;

  String? _age(BuildContext context) {
    final at = postedAt;
    if (at == null) return null;
    final age = storyAge(at, clock.now());
    return age.unit.l10n(context, age.count);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final age = _age(context);
    return SizedBox(
      height: StoryDimens.headerHeight,
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: StoryDimens.headerStart,
          end: StoryDimens.headerEnd,
        ),
        child: Row(
          children: [
            StoryAvatar(
              size: StoryDimens.headerAvatar,
              ringWidth: StoryDimens.headerAvatarRing,
              seed: person.authorId,
              name: person.fullName ?? person.username,
              imageUrl: person.avatarUrl,
            ),
            SizedBox(width: StoryDimens.headerGap),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: AppText(
                      person.isMe
                          ? context.l10n.storyYourStory
                          : person.username,
                      style: text.name,
                      color: colors.storyOnDark,
                      maxLines: 1,
                    ),
                  ),
                  if (age != null) ...[
                    SizedBox(width: StoryDimens.headerGap),
                    AppText(
                      age,
                      style: text.bodyXs,
                      color: colors.storyOnDark.withValues(
                        alpha: StoryOpacity.time,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            if (onMore != null)
              _IconButton(
                asset: AppAssets.moreHorizontal,
                label: context.l10n.storyMore,
                size: StoryDimens.moreIcon,
                onTap: onMore!,
              ),
            _IconButton(
              asset: AppAssets.close,
              label: context.l10n.close,
              size: StoryDimens.closeIcon,
              onTap: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.asset,
    required this.label,
    required this.size,
    required this.onTap,
  });

  final String asset;
  final String label;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: StoryDimens.headerButton / 2,
      child: SizedBox.square(
        dimension: StoryDimens.headerButton,
        child: Center(
          child: AppSvgIcon(
            asset,
            size: size,
            color: context.appColors.storyOnDark,
          ),
        ),
      ),
    ),
  );
}
