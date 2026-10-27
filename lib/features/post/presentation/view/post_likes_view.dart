import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/post_likes/post_likes_cubit.dart';
import '../cubit/post_likes/post_likes_state.dart';
import '../dimens/post_likes_dimens.dart';
import '../utils/enums/post_likes_status.dart';
import '../widgets/post_likes/post_liker_row.dart';
import '../widgets/post_likes/post_likes_skeleton.dart';

/// The likes list: the bar with the count, the search field and the people.
class PostLikesView extends StatelessWidget {
  const PostLikesView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostLikesCubit>();
    return AppPage(
      backgroundColor: context.appColors.background,
      titleWidget: const _Title(),
      child: Column(
        children: [
          Padding(
            padding: PostLikesDimens.searchPadding,
            child: SearchPillField(
              onChanged: cubit.queryChanged,
              hint: context.l10n.postLikesSearchHint,
              clearLabel: context.l10n.postLikesSearchClear,
            ),
          ),
          const Expanded(child: _Body()),
        ],
      ),
    );
  }
}

/// "Likes · 1,204"; just "Likes" until the count is known.
class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostLikesCubit, PostLikesState, int?>(
        selector: (state) => state.total,
        builder: (context, total) => AppText(
          total == null
              ? context.l10n.postLikesTitleBare
              : context.l10n.postLikesTitle(total),
          style: context.text.sheetTitle,
          color: context.appColors.textPrimary,
          maxLines: 1,
        ),
      );
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostLikesCubit, PostLikesState, PostLikesStatus>(
        selector: (state) => state.status,
        builder: (context, status) => switch (status) {
          PostLikesStatus.loading => const PostLikesSkeleton(),
          PostLikesStatus.failed => AppEmpty.failed(
            onRetry: context.read<PostLikesCubit>().load,
          ),
          PostLikesStatus.ready => const _People(),
        },
      );
}

class _People extends StatelessWidget {
  const _People();

  PagingInfo _paging(PostLikesState state) => (
    isRefreshing: state.isRefreshing,
    loadMore: state.more,
    hasMore: state.nextCursor != null,
  );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PostLikesCubit>();
    return BlocBuilder<PostLikesCubit, PostLikesState>(
      buildWhen: (before, now) => before.likers != now.likers,
      builder: (context, state) {
        if (state.likers.isEmpty) return const _Empty();
        return PagedScrollView<PostLikesCubit, PostLikesState>(
          paging: _paging,
          onRefresh: cubit.refresh,
          onLoadMore: () => unawaited(cubit.loadMore(retry: true)),
          retryLabel: context.l10n.postLikesLoadMoreError,
          caughtUpLabel: context.l10n.postLikesCaughtUp,
          refreshIcon: AppAssets.heart,
          refreshIconFilled: AppAssets.heartFilled,
          slivers: [
            SliverPadding(
              padding: PostLikesDimens.listPadding,
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(
                    PostLikesDimens.cardRadius,
                  ),
                ),
                sliver: SliverList.separated(
                  itemCount: state.likers.length,
                  separatorBuilder: (context, _) => Divider(
                    height: PostLikesDimens.divider,
                    thickness: PostLikesDimens.divider,
                    indent: PostLikesDimens.dividerIndent.start,
                    color: context.appColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final liker = state.likers[index];
                    return PostLikerRow(
                      liker: liker,
                      isMe: liker.id == state.userId,
                      onTap: () => AppNavigator.push<void>(
                        context,
                        AppRoutes.profileOf(liker.id),
                      ),
                      onFollow: () => cubit.toggleFollow(liker),
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
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: AppSvgIcon(
                AppAssets.search,
                size: PostLikesDimens.emptyIcon,
                color: colors.primary,
              ),
            ),
            SizedBox(height: PostLikesDimens.rowGap),
            AppText(
              context.l10n.postLikesEmpty,
              style: context.text.stat,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
