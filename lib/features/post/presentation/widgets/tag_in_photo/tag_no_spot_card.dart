import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/tag_people_dimens.dart';
import '../../utils/tag_choice.dart';

/// Who is tagged in the post but not on a photo; nothing when everyone has a spot.
class TagNoSpotCard extends StatelessWidget {
  const TagNoSpotCard({super.key, required this.people});

  final List<TagChoice> people;

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final colors = context.appColors;
    final l10n = context.l10n;
    final text = people.length == 1
        ? l10n.postTagInPhotoNoSpot(people.first.shownName)
        : l10n.postTagInPhotoNoSpotMany(people.length);
    return Container(
      padding: TagPeopleDimens.infoPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(TagPeopleDimens.infoRadius),
      ),
      child: Row(
        children: [
          AppSvgIcon(
            AppAssets.user,
            size: TagPeopleDimens.infoIcon,
            color: colors.primary,
          ),
          SizedBox(width: TagPeopleDimens.rowGap),
          Expanded(
            child: AppText(
              text,
              style: context.text.bodySm,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
