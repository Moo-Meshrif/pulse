import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/content/domain/entity/content_publish_status.dart';
import '../../../post/presentation/cubit/post_actions/post_actions_cubit.dart';
import '../../../post/presentation/cubit/post_actions/post_actions_state.dart';
import '../../../post/presentation/utils/enums/post_row.dart';
import '../cubit/bell_dot/bell_dot_cubit.dart';
import '../cubit/feed/feed_cubit.dart';
import '../cubit/feed/feed_state.dart';
import '../cubit/post_publish/post_line_cubit.dart';
import '../cubit/post_publish/post_publish_cubit.dart';
import '../cubit/story_rail/story_rail_cubit.dart';
import '../cubit/story_rail/story_rail_state.dart';
import '../view/home_view.dart';

/// The Home tab's root page: the feed of the people you follow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _postsReplaced(FeedState before, FeedState state) =>
      before.generation != state.generation;

  void _forgetOldActions(BuildContext context, FeedState state) =>
      context.read<PostActionsCubit>().reset();

  bool _postsWereReplaced(FeedState before, FeedState state) =>
      state.replacedIds.isNotEmpty && state.replacedIds != before.replacedIds;

  void _forgetReplaced(BuildContext context, FeedState state) =>
      context.read<PostActionsCubit>().forget(state.replacedIds);

  bool _haveCountsChanged(FeedState before, FeedState state) =>
      state.counts != before.counts;

  void _applyCounts(BuildContext context, FeedState state) => context
      .read<PostActionsCubit>()
      .applyCounts([for (final post in state.posts) post.entity], state.counts);

  bool _hasNewRefreshFailure(FeedState before, FeedState state) =>
      state.refreshFailure != null &&
      state.refreshFailure != before.refreshFailure;

  void _showRefreshFailure(BuildContext context, FeedState state) =>
      context.showFailure(state.refreshFailure);

  Set<String> _removedIds(PostActionsState state) => {
    for (final entry in state.rows.entries)
      if (entry.value == PostRow.removed) entry.key,
  };

  Set<String> _deletingIds(PostActionsState state) => {
    for (final entry in state.rows.entries)
      if (entry.value == PostRow.deleting) entry.key,
  };

  bool _hasDeleteChanged(PostActionsState before, PostActionsState state) =>
      !setEquals(_removedIds(state), _removedIds(before)) ||
      !setEquals(_deletingIds(state), _deletingIds(before));

  void _syncDeletedPosts(BuildContext context, PostActionsState state) {
    final feed = context.read<FeedCubit>();
    feed.removePosts(_removedIds(state));
    feed.setPendingDeletes(_deletingIds(state));
  }

  bool _hasNewActionFailure(PostActionsState before, PostActionsState state) =>
      state.failure != null && state.failure != before.failure;

  void _showActionFailure(BuildContext context, PostActionsState state) =>
      context.showFailure(state.failure);

  bool _publishJustDone(
    ContentPublishStatus before,
    ContentPublishStatus status,
  ) => status is ContentPublishDone;

  void _showPublishDone(BuildContext context, ContentPublishStatus status) {
    if (status is! ContentPublishDone) return;
    Notices.success(
      status.isEdit ? context.l10n.postUpdated : context.l10n.newPostShared,
    );
  }

  bool _discardRefused(
    ContentPublishStatus before,
    ContentPublishStatus status,
  ) => status is ContentDiscardRefused;

  /// The post had gone out before the discard reached the server: say so, and load it into the feed.
  void _showDiscardRefused(BuildContext context, ContentPublishStatus status) {
    Notices.info(context.l10n.postDiscardTooLate);
    unawaited(context.read<FeedCubit>().refresh());
  }

  bool _uploadJustFailed(StoryRailState before, StoryRailState state) =>
      state.upload is ContentPublishFailed &&
      before.upload is! ContentPublishFailed;

  bool _uploadResumed(StoryRailState before, StoryRailState state) =>
      before.upload is ContentPublishFailed &&
      state.upload is! ContentPublishFailed;

  /// The story posts again by itself: the notice about it is no longer true.
  void _clearUploadNotice(BuildContext context, StoryRailState state) =>
      Notices.clear();

  void _showUploadFailedWithRetry(BuildContext context, StoryRailState state) {
    final rail = context.read<StoryRailCubit>();
    final failure = state.upload;
    // A lost connection is retried by itself when it is back: say so instead of offering a retry.
    if (failure is ContentPublishFailed && failure.isOffline) {
      Notices.info(context.l10n.storyPostOffline);
      return;
    }
    Notices.error(
      context.l10n.storyPostFailed,
      actionLabel: context.l10n.retry,
      onResult: (acted) {
        if (acted) rail.retryUpload();
      },
    );
  }

  /// Opens New post with the draft the app was closed on, once, when Home first opens.
  PostPublishCubit _createPostPublish(BuildContext context) {
    final cubit = getIt<PostPublishCubit>();
    final reopenDraft = cubit.hasOpenDraft;
    cubit.start();
    if (reopenDraft) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          AppNavigator.push<void>(
            context,
            AppRoutes.createPost,
            rootNavigator: true,
          );
        }
      });
    }
    return cubit;
  }

  /// The app came back: finish shared posts that were waiting, and learn what changed meanwhile in the feed and in the Stories rail.
  void _onAppReturned(BuildContext context) {
    context.read<PostPublishCubit>().resume();
    context.read<FeedCubit>().resumeLive();
    unawaited(context.read<FeedCubit>().checkChanges());
    unawaited(context.read<StoryRailCubit>().checkChanges());
  }

  /// The app went to the background: stop listening to the server.
  void _onAppHidden(BuildContext context) =>
      context.read<FeedCubit>().pauseLive();

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<FeedCubit>()..start()),
      BlocProvider(create: (_) => getIt<PostActionsCubit>()),
      BlocProvider(create: (_) => getIt<BellDotCubit>()..start()),
      BlocProvider(create: (_) => getIt<StoryRailCubit>()..start()),
      BlocProvider(create: _createPostPublish),
      BlocProvider(create: (_) => getIt<PostLineCubit>()..start()),
    ],
    // Independent effects, each with its own condition: do not merge them.
    child: MultiBlocListener(
      listeners: [
        BlocListener<FeedCubit, FeedState>(
          listenWhen: _postsReplaced,
          listener: _forgetOldActions,
        ),
        BlocListener<FeedCubit, FeedState>(
          listenWhen: _postsWereReplaced,
          listener: _forgetReplaced,
        ),
        BlocListener<FeedCubit, FeedState>(
          listenWhen: _haveCountsChanged,
          listener: _applyCounts,
        ),
        BlocListener<FeedCubit, FeedState>(
          listenWhen: _hasNewRefreshFailure,
          listener: _showRefreshFailure,
        ),
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: _hasDeleteChanged,
          listener: _syncDeletedPosts,
        ),
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: _hasNewActionFailure,
          listener: _showActionFailure,
        ),
        BlocListener<PostPublishCubit, ContentPublishStatus>(
          listenWhen: _publishJustDone,
          listener: _showPublishDone,
        ),
        BlocListener<PostPublishCubit, ContentPublishStatus>(
          listenWhen: _discardRefused,
          listener: _showDiscardRefused,
        ),
        BlocListener<StoryRailCubit, StoryRailState>(
          listenWhen: _uploadJustFailed,
          listener: _showUploadFailedWithRetry,
        ),
        BlocListener<StoryRailCubit, StoryRailState>(
          listenWhen: _uploadResumed,
          listener: _clearUploadNotice,
        ),
      ],
      child: Builder(
        builder: (context) => OnAppVisibility(
          onShow: () => _onAppReturned(context),
          onHide: () => _onAppHidden(context),
          child: const HomeView(),
        ),
      ),
    ),
  );
}
