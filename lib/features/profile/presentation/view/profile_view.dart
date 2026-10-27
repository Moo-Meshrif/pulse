import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/model/profile_page_model.dart';
import '../cubit/profile/profile_cubit.dart';
import '../cubit/profile/profile_state.dart';
import '../utils/enums/profile_status.dart';
import '../utils/enums/profile_tab.dart';
import '../widgets/cover_button.dart';
import '../widgets/grid_section.dart';
import '../widgets/photo_viewer.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_tabs.dart';

/// The Profile tab's page: the header, the numbers, the tabs and the grid.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.background,
    body: AppSafeArea(
      top: false,
      bottomSpace: NavClearance.of(context),
      child: const ContentWidth(child: _Body()),
    ),
  );
}

/// The skeleton until the header answers, then the page; or the failed page.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ProfileCubit, ProfileState, ProfileStatus>(
        selector: (state) => state.status,
        builder: (context, status) => switch (status) {
          ProfileStatus.loading => const ProfileSkeleton(),
          ProfileStatus.failed => Padding(
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            child: AppEmpty.failed(
              onRetry: () => context.read<ProfileCubit>().load(),
            ),
          ),
          ProfileStatus.ready => const _Page(),
        },
      );
}

class _Page extends StatelessWidget {
  const _Page();

  // An empty grid has no end to reach: its empty page is the footer.
  PagingInfo _paging(ProfileState state) => (
    isRefreshing: state.isRefreshing,
    loadMore: state.loadMore,
    hasMore: state.hasMore || state.items.isEmpty,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    return PagedScrollView<ProfileCubit, ProfileState>(
      paging: _paging,
      onRefresh: cubit.refresh,
      onLoadMore: () => unawaited(cubit.loadMore()),
      retryLabel: context.l10n.profileLoadMoreError,
      caughtUpLabel: context.l10n.profileCaughtUp,
      refreshIcon: AppAssets.profile,
      refreshIconFilled: AppAssets.profileFilled,
      bottomSpace: NavClearance.of(context),
      loadMoreSkeleton: const GridSkeleton(),
      slivers: const [_Header(), ProfileStats(), _Tabs(), GridSection()],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ProfileCubit, ProfileState, ProfilePageModel?>(
        selector: (state) => state.page,
        builder: (context, page) {
          if (page == null) return const SliverToBoxAdapter();
          final avatarUrl = page.avatarUrl;
          return SliverToBoxAdapter(
            child: ProfileHeader(
              page: page,
              leading: CoverButton(
                icon: AppAssets.send,
                label: context.l10n.profileShareA11y,
                onPressed: () =>
                    unawaited(context.read<ProfileCubit>().shareProfile()),
              ),
              trailing: CoverButton(
                icon: AppAssets.sliders,
                label: context.l10n.profileSettingsA11y,
                onPressed: () => AppNavigator.push(context, AppRoutes.settings),
              ),
              onAvatarTap: avatarUrl == null
                  ? null
                  : () => PhotoViewer.show(context, avatarUrl),
            ),
          );
        },
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<ProfileCubit, ProfileState, ProfileTab>(
      selector: (state) => state.tab,
      builder: (context, tab) => SliverToBoxAdapter(
        child: ProfileTabs(
          labels: [
            l10n.profileTabPosts,
            l10n.profileTabShorts,
            l10n.profileTabSaved,
          ],
          selected: tab.index,
          onSelected: (index) => unawaited(
            context.read<ProfileCubit>().selectTab(ProfileTab.values[index]),
          ),
        ),
      ),
    );
  }
}
