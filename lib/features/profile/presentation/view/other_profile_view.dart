import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/load_more_status.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../follow/data/enums/follow_status.dart';
import '../../data/enums/people_kind.dart';
import '../cubit/other_profile/other_profile_cubit.dart';
import '../cubit/other_profile/other_profile_state.dart';
import '../utils/enums/profile_status.dart';
import '../widgets/cover_button.dart';
import '../widgets/other_profile_details.dart';
import '../widgets/photo_viewer.dart';
import '../widgets/post_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_skeleton.dart';
import '../widgets/profile_tabs.dart';
import '../widgets/stats_card.dart';

class OtherProfileView extends StatelessWidget {
  const OtherProfileView({super.key});

  Future<void> _follow(BuildContext context, OtherProfileState state) async {
    final cubit = context.read<OtherProfileCubit>();
    final l10n = context.l10n;
    if (state.follow != FollowStatus.none) {
      final pending = state.follow == FollowStatus.pending;
      final confirmed = await ConfirmationDialog.destructive(
        context,
        icon: AppAssets.profile,
        title: pending
            ? l10n.otherCancelRequest
            : l10n.otherUnfollowTitle(state.page?.fullName ?? ''),
        message: pending ? l10n.otherCancelRequestBody : l10n.otherUnfollowBody,
        confirmLabel: pending
            ? l10n.otherCancelRequestConfirm
            : l10n.otherUnfollow,
        cancelLabel: l10n.cancel,
      );
      if (confirmed != true) return;
    }
    await cubit.toggleFollow();
  }

  void _people(BuildContext context, PeopleKind kind, String id) =>
      AppNavigator.push<void>(
        context,
        AppRoutes.peopleOf(kind.value, id),
        rootNavigator: true,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.background,
    body: BlocBuilder<OtherProfileCubit, OtherProfileState>(
      builder: (context, state) {
        final cubit = context.read<OtherProfileCubit>();
        if (state.status == ProfileStatus.loading) {
          return const ProfileSkeleton();
        }
        if (state.status == ProfileStatus.failed) {
          return AppSafeArea(child: AppEmpty.failed(onRetry: cubit.load));
        }
        if (state.notFound || state.page == null) {
          return AppSafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: BackButton(
                    onPressed: () => AppNavigator.back(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AppText(
                      context.l10n.otherProfileNotFound,
                      style: context.text.title,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        final page = state.page!;
        final blocked = page.blockedByMe == true;
        final locked =
            page.isPrivate == true && state.follow != FollowStatus.accepted;
        final l10n = context.l10n;
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.extentAfter < 400 &&
                state.more == LoadMoreStatus.idle) {
              unawaited(cubit.loadMore());
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: cubit.load,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    page: page,
                    blocked: blocked,
                    leading: CoverButton(
                      icon: AppAssets.arrowBack,
                      label: l10n.back,
                      directional: true,
                      onPressed: () => AppNavigator.back(context),
                    ),
                    trailing: CoverButton(
                      icon: AppAssets.moreHorizontal,
                      label: l10n.otherOptions,
                      onPressed: () => Notices.info(l10n.otherOptionsSoon),
                    ),
                    onAvatarTap: page.avatarUrl == null || blocked
                        ? null
                        : () => PhotoViewer.show(context, page.avatarUrl!),
                  ),
                ),
                if (!blocked) ...[
                  if (page.followsMe == true)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: AppText(
                          l10n.otherFollowsYou,
                          style: context.text.label,
                          color: context.appColors.primary,
                        ),
                      ),
                    ),
                  if (state.mutual.isNotEmpty)
                    SliverToBoxAdapter(
                      child: FollowedByRow(
                        data: state.mutual,
                        onTap: () =>
                            _people(context, PeopleKind.mutual, cubit.userId),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: StatsCard(
                        posts: page.postsCount ?? 0,
                        followers: state.followers,
                        following: page.followingCount ?? 0,
                        onFollowers: () => _people(
                          context,
                          PeopleKind.followers,
                          cubit.userId,
                        ),
                        onFollowing: () => _people(
                          context,
                          PeopleKind.following,
                          cubit.userId,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: state.follow == FollowStatus.none
                                ? PrimaryButton(
                                    label: page.followsMe == true
                                        ? l10n.otherFollowBack
                                        : l10n.follow,
                                    onPressed: state.busy
                                        ? null
                                        : () => _follow(context, state),
                                    expand: true,
                                  )
                                : PillButton.soft(
                                    label: state.follow == FollowStatus.pending
                                        ? l10n.requested
                                        : l10n.following,
                                    onPressed: state.busy
                                        ? null
                                        : () => _follow(context, state),
                                  ),
                          ),
                          if (page.canMessage != false &&
                              state.follow != FollowStatus.pending) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: PillButton.outline(
                                label: l10n.otherMessage,
                                onPressed: () {
                                  // TODO(profile-plan T6): open Chat when it exists.
                                  Notices.info(l10n.otherMessageSoon);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ProfileTabs(
                      labels: [
                        l10n.profileTabPosts,
                        l10n.profileTabShorts,
                        l10n.otherTagged,
                      ],
                      selected: state.tab,
                      onSelected: (tab) => unawaited(cubit.selectTab(tab)),
                    ),
                  ),
                ],
                if (blocked)
                  SliverToBoxAdapter(
                    child: OtherProfileCard(
                      icon: AppAssets.stateBlocked,
                      title: l10n.otherBlockedTitle,
                      body: l10n.otherBlockedBody,
                      action: OutlinePillButton(
                        label: l10n.unblock,
                        onPressed: state.busy
                            ? null
                            : () => unawaited(cubit.unblock()),
                      ),
                    ),
                  )
                else if (locked)
                  SliverToBoxAdapter(
                    child: OtherProfileCard(
                      icon: AppAssets.lockClosed,
                      title: l10n.otherPrivateTitle,
                      body: state.follow == FollowStatus.pending
                          ? l10n.otherPrivateRequested(page.fullName ?? '')
                          : l10n.otherPrivateBody,
                    ),
                  )
                // TODO(profile-plan T3): Shorts need the shorts feature.
                else if (state.tab == 1)
                  SliverToBoxAdapter(
                    child: OtherProfileCard(
                      icon: AppAssets.shorts,
                      title: l10n.profileShortsSoon,
                      body: l10n.profileShortsSoonBody,
                    ),
                  )
                else if (state.gridStatus == ProfileStatus.loading)
                  const SliverToBoxAdapter(child: GridSkeleton())
                else if (state.gridStatus == ProfileStatus.failed)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250,
                      child: AppEmpty.failed(onRetry: cubit.loadGrid),
                    ),
                  )
                else if (state.items.isEmpty)
                  SliverToBoxAdapter(
                    child: OtherProfileCard(
                      icon: AppAssets.inbox,
                      title: l10n.profileNoPosts,
                      body: l10n.otherNoPostsBody,
                    ),
                  )
                else
                  PostGrid(items: state.items, urls: state.urls),
                if (state.more == LoadMoreStatus.loading)
                  const SliverToBoxAdapter(child: GridSkeleton()),
                if (state.more == LoadMoreStatus.failed)
                  SliverToBoxAdapter(
                    child: TextButton(
                      onPressed: () {
                        cubit.retryMore();
                      },
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    ),
  );
}
