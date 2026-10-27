import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/profile/profile_cubit.dart';
import '../cubit/profile/profile_state.dart';
import '../dimens/profile_dimens.dart';
import '../utils/enums/profile_status.dart';
import '../utils/enums/profile_tab.dart';
import 'post_grid.dart';
import 'profile_skeleton.dart';

/// The active tab's tiles, or its loading, empty, failed or coming-soon page.
class GridSection extends StatelessWidget {
  const GridSection({super.key});

  bool _hasGridChanged(ProfileState before, ProfileState state) =>
      before.tab != state.tab ||
      before.gridStatus != state.gridStatus ||
      before.items != state.items ||
      before.urls != state.urls;

  @override
  Widget build(BuildContext context) => BlocBuilder<ProfileCubit, ProfileState>(
    buildWhen: _hasGridChanged,
    builder: (context, state) {
      final l10n = context.l10n;
      if (state.tab == ProfileTab.shorts) {
        // TODO(profile-plan T3): Shorts need the shorts feature
        return _Message(
          icon: AppAssets.shorts,
          title: l10n.profileShortsSoon,
          message: l10n.profileShortsSoonBody,
        );
      }
      return switch (state.gridStatus) {
        ProfileStatus.loading => const SliverToBoxAdapter(
          child: GridSkeleton(),
        ),
        ProfileStatus.failed => SliverToBoxAdapter(
          child: SizedBox(
            height: ProfileDimens.emptyHeight,
            child: AppEmpty.failed(
              onRetry: () => context.read<ProfileCubit>().retryGrid(),
            ),
          ),
        ),
        ProfileStatus.ready when state.items.isEmpty =>
          state.tab == ProfileTab.saved
              ? _Message(
                  icon: AppAssets.bookmark,
                  title: l10n.profileNoSaved,
                  message: l10n.profileNoSavedBody,
                )
              : _Message(
                  icon: AppAssets.inbox,
                  title: l10n.profileNoPosts,
                  message: l10n.profileNoPostsBody,
                  primaryLabel: l10n.profileSharePost,
                  onPrimary: () => AppNavigator.push(
                    context,
                    AppRoutes.createPost,
                    rootNavigator: true,
                  ),
                ),
        ProfileStatus.ready => PostGrid(items: state.items, urls: state.urls),
      };
    },
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
  });

  final String icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    final nav = NavClearance.of(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) => SliverToBoxAdapter(
        child: SizedBox(
          height: math.max(
            ProfileDimens.emptyMinHeight,
            constraints.remainingPaintExtent - nav,
          ),
          child: AppEmpty(
            icon: icon,
            title: title,
            message: message,
            primaryLabel: primaryLabel,
            onPrimary: onPrimary,
          ),
        ),
      ),
    );
  }
}
