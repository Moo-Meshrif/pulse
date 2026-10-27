import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/utils/compact_count.dart';
import '../../../../core/widgets/widgets.dart';
import '../dimens/profile_dimens.dart';

/// Posts, Followers and Following in one white card. Followers and Following open their list when
/// [onFollowers] / [onFollowing] are given.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.posts,
    required this.followers,
    required this.following,
    this.onFollowers,
    this.onFollowing,
  });

  final int posts;
  final int followers;
  final int following;
  final VoidCallback? onFollowers;
  final VoidCallback? onFollowing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final divider = SizedBox(
      height: ProfileDimens.statsDividerHeight,
      child: VerticalDivider(
        width: ProfileDimens.statsDividerWidth,
        thickness: ProfileDimens.statsDividerWidth,
        color: context.appColors.divider,
      ),
    );
    return Container(
      height: ProfileDimens.statsHeight,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(ProfileDimens.statsRadius),
      ),
      child: Row(
        children: [
          _Stat(count: posts, label: l10n.profilePosts),
          divider,
          _Stat(
            count: followers,
            label: l10n.profileFollowers,
            onTap: onFollowers,
          ),
          divider,
          _Stat(
            count: following,
            label: l10n.profileFollowing,
            onTap: onFollowing,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.count, required this.label, this.onTap});

  final int count;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Expanded(
      child: Semantics(
        button: onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                count == 0 ? '0' : compactCount(count),
                style: context.text.stat,
                color: colors.textPrimary,
              ),
              AppText(
                label,
                style: context.text.bodyXs,
                color: colors.textSecondary,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
