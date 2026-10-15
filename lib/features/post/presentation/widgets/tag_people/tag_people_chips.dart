import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../dimens/tag_people_dimens.dart';
import '../../utils/tag_choice.dart';
import '../post_person_avatar.dart';

/// The people chosen so far, in the order they were picked; each chip has a × to take the person off.
class TagPeopleChips extends StatelessWidget {
  const TagPeopleChips({
    super.key,
    required this.chosen,
    required this.onRemove,
  });

  final List<TagChoice> chosen;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppSizes.tapTarget,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      itemCount: chosen.length,
      separatorBuilder: (_, _) => SizedBox(width: TagPeopleDimens.chipGap),
      itemBuilder: (context, index) => Center(
        child: _Chip(
          choice: chosen[index],
          onRemove: () => onRemove(chosen[index].id),
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.choice, required this.onRemove});

  final TagChoice choice;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = choice.shownName;
    return Container(
      height: TagPeopleDimens.chipHeight,
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.s4,
        end: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(
          AppRadius.pill(TagPeopleDimens.chipHeight),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostPersonAvatar(
            id: choice.id,
            name: name,
            size: TagPeopleDimens.chipAvatar,
            url: choice.avatarUrl,
          ),
          SizedBox(width: AppSpacing.s8),
          AppText(
            name.split(' ').first,
            style: context.text.label,
            color: colors.primary,
            maxLines: 1,
          ),
          SizedBox(width: AppSpacing.s8),
          Semantics(
            container: true,
            button: true,
            excludeSemantics: true,
            label: context.l10n.postTagPeopleRemoveChip(name),
            onTap: onRemove,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                width: TagPeopleDimens.chipRemove,
                height: TagPeopleDimens.chipRemove,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: AppSvgIcon(
                  AppAssets.close,
                  size: TagPeopleDimens.chipRemoveIcon,
                  color: colors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
