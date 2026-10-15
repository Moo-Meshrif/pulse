import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/tag_person_entity.dart';
import '../../dimens/tag_people_dimens.dart';
import '../post_person_avatar.dart';

/// A person in the Tag people list: avatar, name, @username and a check. Someone who does not allow tags
/// is dimmed, says so and has no check; a full post dims the rows nobody can pick.
class TagPersonPickRow extends StatelessWidget {
  const TagPersonPickRow({
    super.key,
    required this.person,
    required this.isChosen,
    required this.isFull,
    required this.onTap,
  });

  final TagPersonEntity person;
  final bool isChosen;

  /// The post already has the most people: rows not chosen are dimmed.
  final bool isFull;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final name = person.fullName?.trim();
    final shown = name == null || name.isEmpty ? person.username : name;
    final dimmed = !person.canTag || (isFull && !isChosen);
    return Semantics(
      button: true,
      excludeSemantics: true,
      checked: person.canTag ? isChosen : null,
      label: person.canTag
          ? (isChosen
                ? l10n.postTagPersonTagged(shown)
                : l10n.postTagPersonNotTagged(shown))
          : '$shown, ${l10n.postTagPeopleNoTags}',
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: dimmed ? TagPeopleDimens.disabledOpacity : 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: TagPeopleDimens.rowMinHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              child: Row(
                children: [
                  PostPersonAvatar(
                    id: person.id,
                    name: shown,
                    size: TagPeopleDimens.rowAvatar,
                    url: person.avatarUrl,
                  ),
                  SizedBox(width: TagPeopleDimens.rowGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          shown,
                          style: context.text.name,
                          color: colors.textPrimary,
                          maxLines: 1,
                        ),
                        AppText(
                          '@${person.username}',
                          style: context.text.label,
                          color: colors.textSecondary,
                          maxLines: 1,
                        ),
                        if (!person.canTag)
                          Row(
                            children: [
                              AppSvgIcon(
                                AppAssets.block,
                                size: TagPeopleDimens.blockIcon,
                                color: colors.textSecondary,
                              ),
                              SizedBox(width: AppSpacing.s4),
                              Flexible(
                                child: AppText(
                                  l10n.postTagPeopleNoTags,
                                  style: context.text.caption,
                                  color: colors.textSecondary,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (person.canTag) _Check(isOn: isChosen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.isOn});

  final bool isOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: TagPeopleDimens.check,
      height: TagPeopleDimens.check,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isOn ? colors.primary : Colors.transparent,
        border: isOn
            ? null
            : Border.all(
                color: colors.dashed,
                width: TagPeopleDimens.checkBorder,
              ),
      ),
      child: isOn
          ? AppSvgIcon(
              AppAssets.check,
              size: TagPeopleDimens.checkIcon,
              color: colors.textOnPrimary,
            )
          : null,
    );
  }
}
