import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/extensions/snack_bar_context.dart';
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

  bool _hasNewRemovedPost(PostActionsState before, PostActionsState state) =>
      _removedIds(state).length > _removedIds(before).length;

  void _dropRemovedPosts(BuildContext context, PostActionsState state) =>
      context.read<FeedCubit>().removePosts(_removedIds(state));

  bool _hasNewActionFailure(PostActionsState before, PostActionsState state) =>
      state.failure != null && state.failure != before.failure;

  void _showActionFailure(BuildContext context, PostActionsState state) =>
      context.showFailure(state.failure);

  bool _uploadJustFailed(StoryRailState before, StoryRailState state) =>
      state.upload is StoryUploadFailed && before.upload is! StoryUploadFailed;

  void _showUploadFailedWithRetry(BuildContext context, StoryRailState state) {
    context.showSnackBar(
      context.l10n.storyPostFailed,
      actionLabel: context.l10n.retry,
      onAction: context.read<StoryRailCubit>().retryUpload,
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
          listenWhen: _hasNewRemovedPost,
          listener: _dropRemovedPosts,
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
