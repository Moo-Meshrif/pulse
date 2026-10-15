import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/model/audience_person_model.dart';
import '../../dimens/story_dimens.dart';
import '../story_avatar.dart';
import 'audience_check.dart';

/// One follower: avatar, name, @username and the round selector.
class AudiencePersonRow extends StatelessWidget {
  const AudiencePersonRow({
    super.key,
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final AudiencePersonModel person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.text;
    final name = person.fullName ?? person.username ?? '';
    return Semantics(
      button: true,
      checked: selected,
      label: context.l10n.storyAudienceSelectPerson(name),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: StoryDimens.viewerRowHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Row(
              children: [
                StoryAvatar(
                  size: StoryDimens.viewerAvatar,
                  seed: person.userId ?? name,
                  name: name,
                  imageUrl: person.avatarUrl,
                ),
                SizedBox(width: StoryDimens.viewerRowGap),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        name,
                        style: text.name,
                        color: colors.onDark,
                        maxLines: 1,
                      ),
                      if (person.username != null)
                        AppText(
                          '@${person.username}',
                          style: text.caption,
                          color: colors.onDark.withValues(
                            alpha: DarkOpacity.subtitle,
                          ),
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                AudienceCheck(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
