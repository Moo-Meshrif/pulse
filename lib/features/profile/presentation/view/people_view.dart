import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/enums/people_kind.dart';
import '../cubit/people/people_cubit.dart';
import '../cubit/people/people_state.dart';
import '../utils/enums/profile_status.dart';
import '../widgets/people_skeleton.dart';
import '../widgets/person_tile.dart';

/// The list of people: the bar, the search field (not for "Followed by") and the rows.
class PeopleView extends StatelessWidget {
  const PeopleView({super.key, required this.kind});

  final PeopleKind kind;

  String _title(BuildContext context) => switch (kind) {
    PeopleKind.followers => context.l10n.peopleFollowersTitle,
    PeopleKind.following => context.l10n.peopleFollowingTitle,
    PeopleKind.mutual => context.l10n.peopleMutualTitle,
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PeopleCubit>();
    return AppPage(
      backgroundColor: context.appColors.background,
      title: _title(context),
      child: Column(
        children: [
          if (kind != PeopleKind.mutual)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.cardMargin),
              child: SearchPillField(
                onChanged: cubit.queryChanged,
                hint: context.l10n.peopleSearchHint,
                clearLabel: context.l10n.peopleSearchClear,
              ),
            ),
          Expanded(child: _Body(kind: kind)),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.kind});

  final PeopleKind kind;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PeopleCubit, PeopleState, ProfileStatus>(
        selector: (state) => state.status,
        builder: (context, status) => switch (status) {
          ProfileStatus.loading => const PeopleSkeleton(),
          ProfileStatus.failed => AppEmpty.failed(
            onRetry: context.read<PeopleCubit>().load,
          ),
          ProfileStatus.ready => _People(kind: kind),
        },
      );
}

class _People extends StatelessWidget {
  const _People({required this.kind});

  final PeopleKind kind;

  PagingInfo _paging(PeopleState state) => (
    isRefreshing: state.isRefreshing,
    loadMore: state.more,
    hasMore: state.hasMore,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PeopleCubit>();
    return BlocBuilder<PeopleCubit, PeopleState>(
      buildWhen: (before, now) =>
          before.people != now.people || before.isLocked != now.isLocked,
      builder: (context, state) {
        if (state.isLocked) return const _Locked();
        if (state.people.isEmpty) return _Empty(kind: kind);
        return PagedScrollView<PeopleCubit, PeopleState>(
          paging: _paging,
          onRefresh: cubit.refresh,
          onLoadMore: () => unawaited(cubit.loadMore(retry: true)),
          retryLabel: context.l10n.peopleLoadMoreError,
          caughtUpLabel: context.l10n.peopleCaughtUp,
          loadMoreSkeleton: const PeopleSkeleton(),
          refreshIcon: AppAssets.profile,
          refreshIconFilled: AppAssets.profileFilled,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(AppSpacing.cardMargin),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                sliver: SliverList.builder(
                  itemCount: state.people.length,
                  itemBuilder: (context, index) {
                    final person = state.people[index];
                    return PersonTile(
                      person: person,
                      isMe: person.id == state.userId,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.kind});

  final PeopleKind kind;

  @override
  Widget build(BuildContext context) {
    final searching = context.select<PeopleCubit, bool>(
      (cubit) => cubit.state.isSearching,
    );
    final l10n = context.l10n;
    final (title, message) = searching
        ? (l10n.peopleNoMatches, l10n.peopleNoMatchesBody)
        : switch (kind) {
            PeopleKind.followers => (
              l10n.peopleNoFollowers,
              l10n.peopleNoFollowersBody,
            ),
            PeopleKind.following => (
              l10n.peopleNoFollowing,
              l10n.peopleNoFollowingBody,
            ),
            PeopleKind.mutual => (l10n.peopleNoMutual, l10n.peopleNoMutualBody),
          };
    return AppEmpty(icon: AppAssets.userAdd, title: title, message: message);
  }
}

/// A private account the signed-in user does not follow.
class _Locked extends StatelessWidget {
  const _Locked();

  @override
  Widget build(BuildContext context) => AppEmpty(
    icon: AppAssets.lockClosed,
    title: context.l10n.peoplePrivateTitle,
    message: context.l10n.peoplePrivateBody,
  );
}
