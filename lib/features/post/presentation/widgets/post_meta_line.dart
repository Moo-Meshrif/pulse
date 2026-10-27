import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/post_time.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../../../core/widgets/app_text.dart';
import '../dimens/post_card_dimens.dart';

/// Under the headline: the place (green, tappable), the time and the audience icon, with a dot between.
class PostMetaLine extends StatelessWidget {
  const PostMetaLine({
    super.key,
    this.location,
    this.createdAt,
    this.audienceIcon,
    this.onLocation,
    this.onTime,
  });

  final String? location;

  /// Null leaves the time out (the composer: the post has no age yet).
  final DateTime? createdAt;
  final String? audienceIcon;
  final VoidCallback? onLocation;

  /// A tap on the time (the card opens the post's page).
  final VoidCallback? onTime;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final place = location?.trim();
    final posted = createdAt;
    final time = posted == null
        ? null
        : postTime(context.l10n, posted, clock.now());
    final dot = AppText(
      '·',
      style: context.text.caption,
      color: colors.textSecondary,
    );
    final gap = SizedBox(width: PostCardDimens.metaGap);
    return Row(
      children: [
        if (place != null && place.isNotEmpty) ...[
          Flexible(
            child: Semantics(
              button: onLocation != null,
              excludeSemantics: true,
              label: place,
              onTap: onLocation,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLocation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSvgIcon(
                      AppAssets.location,
                      size: PostCardDimens.locationIcon,
                      color: colors.primary,
                    ),
                    SizedBox(width: PostCardDimens.dotGap),
                    Flexible(
                      child: AppText(
                        place,
                        style: context.text.chip,
                        color: colors.primary,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (time != null) ...[gap, dot, gap],
        ],
        if (time != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTime,
            child: AppText(
              time,
              style: context.text.caption,
              color: colors.textSecondary,
            ),
          ),
        if (audienceIcon != null) ...[
          if (time != null) ...[gap, dot, gap],
          AppSvgIcon(
            audienceIcon!,
            size: PostCardDimens.visibilityIcon,
            color: colors.textSecondary,
          ),
        ],
      ],
    );
  }
}
