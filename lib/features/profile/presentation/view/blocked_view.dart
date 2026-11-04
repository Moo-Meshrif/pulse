import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/blocked/blocked_cubit.dart';
import '../cubit/blocked/blocked_state.dart';
import '../utils/enums/profile_status.dart';
import '../widgets/blocked_person_tile.dart';
import '../widgets/people_skeleton.dart';

/// The Blocked accounts page: the intro and the card of blocked people.
class BlockedView extends StatelessWidget {
  const BlockedView({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    backgroundColor: context.appColors.background,
    title: context.l10n.blockedTitle,
    child: BlocSelector<BlockedCubit, BlockedState, ProfileStatus>(
      selector: (state) => state.status,
      builder: (context, status) => switch (status) {
        ProfileStatus.loading => const PeopleSkeleton(),
        ProfileStatus.failed => AppEmpty.failed(
          onRetry: context.read<BlockedCubit>().load,
        ),
        ProfileStatus.ready => const _People(),
      },
    ),
  );
}

class _People extends StatelessWidget {
  const _People();

  PagingInfo _paging(BlockedState state) => (
    isRefreshing: state.isRefreshing,
    loadMore: state.more,
    hasMore: state.hasMore,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BlockedCubit>();
    final l10n = context.l10n;
    return BlocBuilder<BlockedCubit, BlockedState>(
      buildWhen: (before, now) => before.people != now.people,
      builder: (context, state) {
        if (state.people.isEmpty) {
          return AppEmpty(
            icon: AppAssets.stateBlocked,
            title: l10n.blockedEmpty,
            message: l10n.blockedIntro,
          );
        }
        return PagedScrollView<BlockedCubit, BlockedState>(
          paging: _paging,
          onRefresh: cubit.refresh,
          onLoadMore: () => unawaited(cubit.loadMore(retry: true)),
          retryLabel: l10n.peopleLoadMoreError,
          caughtUpLabel: l10n.peopleCaughtUp,
          loadMoreSkeleton: const PeopleSkeleton(),
          refreshIcon: AppAssets.block,
          refreshIconFilled: AppAssets.block,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s24,
                  AppSpacing.s16,
                  AppSpacing.s24,
                  0,
                ),
                child: AppText(
                  l10n.blockedIntro,
                  style: context.text.body,
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.cardMargin),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                sliver: SliverList.builder(
                  itemCount: state.people.length,
                  itemBuilder: (context, index) =>
                      BlockedPersonTile(person: state.people[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
