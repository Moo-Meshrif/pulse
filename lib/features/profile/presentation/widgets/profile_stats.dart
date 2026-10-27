import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/people_kind.dart';
import '../cubit/profile/profile_cubit.dart';
import '../cubit/profile/profile_state.dart';
import 'stats_card.dart';

/// The numbers, or a note that they need a connection when the header is the saved copy.
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  void _open(BuildContext context, PeopleKind kind, String userId) =>
      AppNavigator.push<void>(
        context,
        AppRoutes.peopleOf(kind.value, userId),
        rootNavigator: true,
      );

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    buildWhen: (before, state) =>
        before.page != state.page || before.fromDevice != state.fromDevice,
    builder: (context, state) {
      final page = state.page;
      if (page == null) return const SliverToBoxAdapter();
      final id = page.id;
      if (state.fromDevice) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s16,
            ),
            child: AppText(
              context.l10n.profileOfflineNumbers,
              style: context.text.bodyXs,
              color: context.appColors.textSecondary,
            ),
          ),
        );
      }
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: AppSpacing.s16),
          child: StatsCard(
            posts: page.postsCount ?? 0,
            followers: page.followersCount ?? 0,
            following: page.followingCount ?? 0,
            onFollowers: id == null
                ? null
                : () => _open(context, PeopleKind.followers, id),
            onFollowing: id == null
                ? null
                : () => _open(context, PeopleKind.following, id),
          ),
        ),
      );
    },
  );
}
