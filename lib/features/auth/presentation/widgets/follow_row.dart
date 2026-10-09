import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../profile/data/model/suggested_profile_model.dart';
import '../utils/l10n/suggested_profile_l10n.dart';
import 'avatar_initials.dart';

/// One person on the Follow step: avatar, name, meta line and the Follow / Following pill
/// (docs/specs/auth/02-components.md C12).
class FollowRow extends StatelessWidget {
  const FollowRow({
    super.key,
    required this.person,
    required this.following,
    required this.onToggle,
  });

  final SuggestedProfileModel person;
  final bool following;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final name = person.fullName ?? person.username ?? '';
    final meta = person.metaLine(context);
    return Padding(
      padding: EdgeInsets.all(AppSpacing.cardMargin),
      child: Row(
        children: [
          AvatarInitials(name: name, seed: person.id),
          SizedBox(width: AppSpacing.s12),
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
                if (meta != null)
                  AppText(
                    meta,
                    style: context.text.bodySm,
                    color: colors.textSecondary,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s12),
          Semantics(
            button: true,
            toggled: following,
            excludeSemantics: true,
            label: following
                ? l10n.unfollowPerson(name)
                : l10n.followPerson(name),
            onTap: onToggle,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AuthDimens.tapTarget,
                ),
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: following ? colors.surface : colors.primary,
                      border: following
                          ? Border.all(
                              color: colors.border,
                              width: AuthDimens.inputBorderWidth,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(
                        AppRadius.pill(AuthDimens.followPillHeight),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20,
                        vertical: AppSpacing.s8,
                      ),
                      child: AppText(
                        following ? l10n.following : l10n.follow,
                        style: context.text.action,
                        color: following
                            ? colors.textPrimary
                            : colors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
