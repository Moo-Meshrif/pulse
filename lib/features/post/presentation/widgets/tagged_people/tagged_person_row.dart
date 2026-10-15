import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/follow_state.dart';
import '../../../domain/entity/tagged_person_entity.dart';
import '../../dimens/tagged_people_dimens.dart';
import '../post_person_avatar.dart';

/// A person tagged on a post: avatar, name, @username and the pill at the end. A tap on the row opens the
/// profile, a tap on the pill follows or unfollows (or removes your own tag).
class TaggedPersonRow extends StatelessWidget {
  const TaggedPersonRow({
    super.key,
    required this.person,
    required this.onOpen,
    required this.onPill,
  });

  final TaggedPersonEntity person;
  final VoidCallback onOpen;
  final VoidCallback onPill;

  String _stateLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (person.followState) {
      FollowState.none => l10n.postTaggedFollow,
      FollowState.pending => l10n.postTaggedRequested,
      FollowState.following => l10n.postTaggedFollowing,
      FollowState.me => l10n.postTagRemoveConfirm,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final name = person.fullName?.trim();
    final shown = name == null || name.isEmpty ? person.username : name;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: TaggedPeopleDimens.rowMinHeight,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              excludeSemantics: true,
              label: context.l10n.postTaggedPerson(shown, _stateLabel(context)),
              onTap: onOpen,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onOpen,
                child: Row(
                  children: [
                    PostPersonAvatar(
                      id: person.id,
                      name: shown,
                      size: TaggedPeopleDimens.avatar,
                      url: person.avatarUrl,
                    ),
                    SizedBox(width: TaggedPeopleDimens.avatarGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: TaggedPeopleDimens.avatarGap),
          _Pill(
            label: _stateLabel(context),
            state: person.followState,
            onTap: onPill,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.state, required this.onTap});

  final String label;
  final FollowState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = state == FollowState.none;
    final textColor = switch (state) {
      FollowState.none => colors.textOnPrimary,
      FollowState.following => colors.textPrimary,
      FollowState.pending => colors.textSecondary,
      FollowState.me => colors.danger,
    };
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
          child: Center(
            child: Container(
              height: TaggedPeopleDimens.pillHeight,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: TaggedPeopleDimens.pillSide,
              ),
              decoration: BoxDecoration(
                color: filled ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppRadius.pill(TaggedPeopleDimens.pillHeight),
                ),
                border: filled ? null : Border.all(color: colors.border),
              ),
              child: AppText(
                label,
                style: context.text.label,
                color: textColor,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
