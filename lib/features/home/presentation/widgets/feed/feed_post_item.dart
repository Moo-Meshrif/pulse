import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/snack_bar_context.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../post/domain/entity/post_entity.dart';
import '../../../../post/presentation/cubit/post_actions_cubit.dart';
import '../../../../post/presentation/cubit/post_actions_state.dart';
import '../../../../post/presentation/utils/enums/post_row.dart';
import '../../../../post/presentation/utils/post_card_callbacks.dart';
import '../../../../post/presentation/utils/post_options_actions.dart';
import '../../../../post/presentation/widgets/hidden_post_row.dart';
import '../../../../post/presentation/widgets/post_card.dart';
import '../../../../post/presentation/widgets/post_options/post_options_flow.dart';
import '../../cubit/feed_cubit.dart';
import '../../dimens/home_dimens.dart';
import '../../utils/feed_post.dart';
import '../../utils/post_card_mapper.dart';

/// One post of the feed: its card, the "Not interested" row it turns into, or nothing once it was
/// reported or deleted. Wires the card to [PostActionsCubit].
class FeedPostItem extends StatefulWidget {
  const FeedPostItem({super.key, required this.post});

  final FeedPost post;

  @override
  State<FeedPostItem> createState() => _FeedPostItemState();
}

class _FeedPostItemState extends State<FeedPostItem> {
  bool _isOptionsOpen = false;

  PostEntity get _loaded => widget.post.entity;
  PostActionsCubit get _actions => context.read<PostActionsCubit>();

  ({PostEntity post, PostRow row}) _current(PostActionsState state) => (
    post: state.posts[_loaded.id] ?? _loaded,
    row: state.rows[_loaded.id] ?? PostRow.card,
  );

  PostCardCallbacks _callbacks() => PostCardCallbacks(
    onProfile: _openProfile,
    onOptions: _openOptions,
    onLike: () => _actions.toggleLike(_loaded),
    onDoubleTapLike: () => _actions.likeByDoubleTap(_loaded),
    onComment: _openComments,
    onShare: _share,
    onSave: () => _actions.toggleSave(_loaded),
  );

  PostOptionsActions _optionsActions() => PostOptionsActions(
    onSave: () => _actions.toggleSave(_loaded),
    onNotInterested: () => _actions.notInterested(_loaded),
    onUnfollow: () => _actions.unfollow(_loaded),
    onUndoUnfollow: () => _actions.undoUnfollow(_loaded),
    onMute: () => _actions.mute(_loaded),
    onUndoMute: () => _actions.undoMute(_loaded),
    onReport: (reason, note) => _actions.report(_loaded, reason, note),
    onToggleComments: () => _actions.toggleComments(_loaded),
    onDelete: () => _actions.delete(_loaded),
    onAudienceChanged: (audience) =>
        _actions.audienceChanged(_loaded, audience),
    onEdit: _openEdit,
  );

  void _openProfile() =>
      AppNavigator.push<void>(context, AppRoutes.profileOf(_loaded.authorId));

  void _openEdit() => AppNavigator.push<void>(
    context,
    AppRoutes.editPost,
    rootNavigator: true,
    arguments: _actions.postOf(_loaded),
  );

  void _openComments() =>
      AppNavigator.push<void>(context, AppRoutes.commentsOf(_loaded.id));

  void _share() {
    // TODO(home-plan H6): the system share sheet waits for post links and share_plus (post-plan T7).
    context.showSnackBar(context.l10n.comingSoon);
  }

  Future<void> _openOptions() async {
    final data = postOptionsData(
      _actions.postOf(_loaded),
      userId: context.read<FeedCubit>().state.userId,
    );
    final actions = _optionsActions();
    setState(() => _isOptionsOpen = true);
    await PostOptionsFlow.show(context, data: data, actions: actions);
    if (mounted) setState(() => _isOptionsOpen = false);
  }

  Future<void> _undoNotInterested() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _actions.undoNotInterested(_loaded);
    } on Failure catch (failure) {
      if (messenger.mounted) messenger.context.showFailure(failure);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PostActionsCubit,
        PostActionsState,
        ({PostEntity post, PostRow row})
      >(
        selector: _current,
        builder: (context, current) => switch (current.row) {
          PostRow.removed => const SizedBox.shrink(),
          PostRow.hidden => Padding(
            padding: EdgeInsets.only(bottom: HomeDimens.cardGap),
            child: HiddenPostRow(onUndo: _undoNotInterested),
          ),
          PostRow.card => Padding(
            padding: EdgeInsets.only(bottom: HomeDimens.cardGap),
            child: PostCard(
              data: postCardData(current.post, widget.post.media),
              callbacks: _callbacks(),
              isOptionsOpen: _isOptionsOpen,
            ),
          ),
        },
      );
}
