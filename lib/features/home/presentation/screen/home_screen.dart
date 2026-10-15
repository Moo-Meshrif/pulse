import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/notice/notices.dart';
import '../../../post/presentation/cubit/post_actions_cubit.dart';
import '../../../post/presentation/cubit/post_actions_state.dart';
import '../../../post/presentation/utils/enums/post_row.dart';
import '../../../story/domain/entity/story_upload_status.dart';
import '../cubit/bell_dot_cubit.dart';
import '../cubit/feed_cubit.dart';
import '../cubit/feed_state.dart';
import '../cubit/story_rail_cubit.dart';
import '../cubit/story_rail_state.dart';
import '../view/home_view.dart';

/// The Home tab's root page: the feed of the people you follow.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  bool _postsReplaced(FeedState before, FeedState state) =>
      before.generation != state.generation;

  void _forgetOldActions(BuildContext context, FeedState state) =>
      context.read<PostActionsCubit>().reset();

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

  bool _uploadJustFailed(StoryRailState before, StoryRailState state) =>
      state.upload is StoryUploadFailed && before.upload is! StoryUploadFailed;

  void _showUploadFailedWithRetry(BuildContext context, StoryRailState state) {
    final rail = context.read<StoryRailCubit>();
    Notices.error(
      context.l10n.storyPostFailed,
      actionLabel: context.l10n.retry,
      onResult: (acted) {
        if (acted) rail.retryUpload();
      },
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<FeedCubit>()..start()),
      BlocProvider(create: (_) => getIt<PostActionsCubit>()),
      BlocProvider(create: (_) => getIt<BellDotCubit>()..start()),
      BlocProvider(create: (_) => getIt<StoryRailCubit>()..start()),
    ],
    // Independent effects, each with its own condition: do not merge them.
    child: MultiBlocListener(
      listeners: [
        BlocListener<FeedCubit, FeedState>(
          listenWhen: _postsReplaced,
          listener: _forgetOldActions,
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
        BlocListener<StoryRailCubit, StoryRailState>(
          listenWhen: _uploadJustFailed,
          listener: _showUploadFailedWithRetry,
        ),
      ],
      child: const HomeView(),
    ),
  );
}
