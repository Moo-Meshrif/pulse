import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../post/presentation/widgets/post_video_scope.dart';
import '../cubit/bell_dot_cubit.dart';
import '../cubit/feed_cubit.dart';
import '../cubit/feed_state.dart';
import '../cubit/story_rail_cubit.dart';
import '../dimens/home_dimens.dart';
import '../utils/enums/feed_mode.dart';
import '../utils/feed_videos.dart';
import '../widgets/feed/feed_empty.dart';
import '../widgets/feed/feed_failed.dart';
import '../widgets/feed/feed_header.dart';
import '../widgets/feed/feed_post_list.dart';
import '../widgets/feed/feed_skeleton.dart';
import '../widgets/feed/publish_banner.dart';
import '../widgets/story_rail/story_rail.dart';

/// The Home tab: the header, the Stories rail and the posts of the feed, or the page for a feed that is
/// loading, empty or failed (docs/specs/home/screens/s1-home-feed.md).
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.background,
    body: AppSafeArea(
      bottomSpace: NavClearance.of(context),
      child: const ContentWidth(child: _Body()),
    ),
  );
}

/// Fades from the skeleton to the loaded feed.
class _Body extends StatelessWidget {
  const _Body();

  static const _skeletonKey = ValueKey('skeleton');
  static const _loadedKey = ValueKey('loaded');

  @override
  Widget build(BuildContext context) =>
      BlocSelector<FeedCubit, FeedState, bool>(
        selector: (state) => state.mode == FeedMode.skeleton,
        builder: (context, isSkeleton) => AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : HomeDimens.skeletonFade,
          child: isSkeleton
              ? const _Loading(key: _skeletonKey)
              : const _Loaded(key: _loadedKey),
        ),
      );
}

/// The skeleton under the real header. It does not scroll.
class _Loading extends StatelessWidget {
  const _Loading({super.key});

  @override
  Widget build(BuildContext context) => const CustomScrollView(
    primary: false,
    physics: NeverScrollableScrollPhysics(),
    slivers: [
      FeedHeader(),
      SliverToBoxAdapter(child: FeedSkeleton()),
    ],
  );
}

/// Picks the page for the feed's mode: the posts, the empty page or the failed page.
class _Loaded extends StatelessWidget {
  const _Loaded({super.key});

  bool _hasModeChanged(FeedState before, FeedState state) =>
      before.mode != state.mode;

  @override
  Widget build(BuildContext context) => BlocBuilder<FeedCubit, FeedState>(
    buildWhen: _hasModeChanged,
    builder: (context, state) => switch (state.mode) {
      FeedMode.content || FeedMode.skeleton => const _Posts(),
      FeedMode.empty => const FeedEmpty(),
      FeedMode.failed => FeedFailed(failure: state.failure),
    },
  );
}

/// The feed with pull to refresh and paging.
class _Posts extends StatelessWidget {
  const _Posts();

  bool _havePostsChanged(FeedState before, FeedState state) =>
      before.posts != state.posts;

  PagingInfo _paging(FeedState state) => (
    isRefreshing: state.isRefreshing,
    loadMore: state.loadMore,
    hasMore: state.hasMore,
  );

  Future<void> _refresh(BuildContext context) {
    unawaited(context.read<BellDotCubit>().load());
    unawaited(context.read<StoryRailCubit>().load());
    return context.read<FeedCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<FeedCubit, FeedState>(
    buildWhen: _havePostsChanged,
    builder: (context, state) => PostVideoScope(
      videos: feedVideos(state.posts),
      child: PagedScrollView<FeedCubit, FeedState>(
        paging: _paging,
        onRefresh: () => _refresh(context),
        onLoadMore: () => unawaited(context.read<FeedCubit>().loadMore()),
        retryLabel: context.l10n.homeLoadMoreError,
        caughtUpLabel: context.l10n.homeCaughtUp,
        bottomSpace: NavClearance.of(context),
        headerSlivers: const [FeedHeader()],
        slivers: [
          const SliverToBoxAdapter(child: StoryRail()),
          const SliverToBoxAdapter(child: PublishBanner()),
          SliverPadding(
            padding: HomeDimens.listPadding,
            sliver: FeedPostList(posts: state.posts),
          ),
        ],
      ),
    ),
  );
}
