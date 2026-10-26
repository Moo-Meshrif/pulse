import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/mention_person_entity.dart';
import '../../dimens/comments_dimens.dart';
import '../post_person_avatar.dart';

/// The people suggested for the `@word` being typed; the first row is highlighted.
class CommentMentionList extends StatelessWidget {
  const CommentMentionList({
    super.key,
    required this.people,
    required this.onPick,
  });

  final List<MentionPersonEntity> people;
  final ValueChanged<MentionPersonEntity> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Semantics(
      container: true,
      label: context.l10n.commentsMentionSuggestions,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(CommentsDimens.mentionRadius),
          border: Border.all(
            color: colors.divider,
            width: CommentsDimens.divider,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CommentsDimens.mentionRadius),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < people.length; i++)
                _Row(
                  person: people[i],
                  highlighted: i == 0,
                  onTap: () => onPick(people[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.person,
    required this.highlighted,
    required this.onTap,
  });

  final MentionPersonEntity person;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = person.fullName?.trim();
    final shown = name == null || name.isEmpty ? person.username : name;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$shown, @${person.username}',
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ColoredBox(
          color: highlighted ? colors.primarySoft : Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CommentsDimens.mentionRowMinHeight,
            ),
            child: Padding(
              padding: CommentsDimens.mentionRowPadding,
              child: Row(
                children: [
                  PostPersonAvatar(
                    id: person.id,
                    name: shown,
                    url: person.avatarUrl,
                    size: CommentsDimens.avatar,
                  ),
                  SizedBox(width: CommentsDimens.avatarGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          shown,
                          style: context.text.action,
                          color: colors.textPrimary,
                          maxLines: 1,
                        ),
                        AppText(
                          '@${person.username}',
                          style: context.text.caption,
                          color: colors.textSecondary,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
