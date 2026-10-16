import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/extensions/notice_context.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../post/domain/entity/post_entity.dart';
import '../../../../post/presentation/cubit/post_actions_cubit.dart';
import '../../../../post/presentation/cubit/post_actions_state.dart';
import '../../../../post/presentation/screen/add_edit_post_screen.dart';
import '../../../../post/presentation/utils/enums/post_row.dart';
import '../../../../post/presentation/utils/post_card_callbacks.dart';
import '../../../../post/presentation/utils/post_options_actions.dart';
import '../../../../post/presentation/utils/post_tag_removal.dart';
import '../../../../post/presentation/widgets/hidden_post_row.dart';
import '../../../../post/presentation/widgets/post_card.dart';
import '../../../../post/presentation/widgets/post_options/post_options_flow.dart';
import '../../../../post/presentation/widgets/tagged_people/tagged_people_sheet.dart';
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
  Map<String, String>? get _signedUrls {
    final Map<String, String> map = {};
    for (var e in widget.post.media) {
      if (e.cacheKey != null) {
        map[e.cacheKey!] = e.url;
      }
    }
    return map.isEmpty ? null : map;
  }

  PostActionsCubit get _actions => context.read<PostActionsCubit>();

  /// Only what the cubit changed is selected: the post itself comes from the widget at build time, so an
  /// edited post is never drawn from a copy the selector kept.
  ({PostEntity? changed, PostRow row, bool muted}) _current(
    PostActionsState state,
  ) => (
    changed: state.posts[_loaded.id],
    row: state.rows[_loaded.id] ?? PostRow.card,
    muted: state.mutedAuthors.contains(_loaded.authorId),
  );

  PostCardCallbacks _callbacks() => PostCardCallbacks(
    onProfile: _openProfile,
    onOptions: _openOptions,
    onLike: () => _actions.toggleLike(_loaded),
    onDoubleTapLike: () => _actions.likeByDoubleTap(_loaded),
    onComment: _openComments,
    onShare: _share,
    onSave: () => _actions.toggleSave(_loaded),
    onTaggedPerson: _openProfileOf,
    onTaggedPeople: _openTaggedPeople,
    onRemoveMyTag: _removeMyTag,
  );

  /// The delete's Undo and commit run when the notice ends, maybe after this card has scrolled away:
  /// they use the cubit and post taken now, never the context.
  PostOptionsActions _optionsActions() {
    final actions = _actions;
    final loaded = _loaded;
    return _optionsActionsOf(actions, loaded);
  }

  PostOptionsActions _optionsActionsOf(
    PostActionsCubit actions,
    PostEntity loaded,
  ) => PostOptionsActions(
    onSave: () => actions.toggleSave(loaded),
    onNotInterested: () => actions.notInterested(loaded),
    onUnfollow: () => actions.unfollow(loaded),
    onUndoUnfollow: () => actions.undoUnfollow(loaded),
    onMute: () => actions.mute(loaded),
    onUndoMute: () => actions.undoMute(loaded),
    onReport: (reason, note) => actions.report(loaded, reason, note),
    onToggleComments: () => actions.toggleComments(loaded),
    onDelete: () => actions.delete(loaded),
    onUndoDelete: () => actions.undoDelete(loaded),
    onCommitDelete: () => actions.commitDelete(loaded),
    onAudienceChanged: (audience) => actions.audienceChanged(loaded, audience),
    onEdit: _openEdit,
    onRemoveMyTag: () => _removeMyTagOf(actions, loaded),
  );

  void _openProfile() => _openProfileOf(_loaded.authorId);

  void _openProfileOf(String userId) =>
      AppNavigator.push<void>(context, AppRoutes.profileOf(userId));

  /// The cubit takes the tag off at once; a failure puts it back and is thrown to the dialog flow.
  Future<void> _removeMyTagOf(PostActionsCubit actions, PostEntity loaded) {
    final userId = context.read<FeedCubit>().state.userId;
    return userId == null
        ? Future.value()
        : actions.removeMyTag(loaded, userId: userId);
  }

  Future<void> _removeMyTag() => PostTagRemoval.confirmAndRemove(
    context,
    ownerName: _loaded.username,
    remove: () => _removeMyTagOf(_actions, _loaded),
  );

  Future<void> _openTaggedPeople() async {
    final result = await TaggedPeopleSheet.show(context, postId: _loaded.id);
    if (result == null || !mounted) return;
    final profileId = result.profileId;
    if (profileId != null) {
      _openProfileOf(profileId);
    } else if (result.removeMe) {
      await _removeMyTag();
    }
  }

  void _openEdit() => AppNavigator.push<void>(
    context,
    AppRoutes.editPost,
    rootNavigator: true,
    arguments: AddEditPostArgs(
      post: _actions.postOf(_loaded),
      signedUrls: _signedUrls,
    ),
  );

  void _openComments() =>
      AppNavigator.push<void>(context, AppRoutes.commentsOf(_loaded.id));

  void _share() {
    // TODO(home-plan H6): the system share sheet waits for post links and share_plus (post-plan T7).
    Notices.info(context.l10n.comingSoon);
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
    try {
      await _actions.undoNotInterested(_loaded);
    } on Failure catch (failure) {
      if (mounted) context.showFailure(failure);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PostActionsCubit,
        PostActionsState,
        ({PostEntity? changed, PostRow row, bool muted})
      >(
        selector: _current,
        builder: (context, current) => current.muted
            ? const SizedBox.shrink()
            : switch (current.row) {
                PostRow.deleting || PostRow.removed => const SizedBox.shrink(),
                PostRow.hidden => Padding(
                  padding: EdgeInsets.only(bottom: HomeDimens.cardGap),
                  child: HiddenPostRow(onUndo: _undoNotInterested),
                ),
                PostRow.card => Padding(
                  padding: EdgeInsets.only(bottom: HomeDimens.cardGap),
                  child: PostCard(
                    data: postCardData(
                      current.changed ?? widget.post.entity,
                      widget.post.media,
                      userId: context.read<FeedCubit>().state.userId,
                    ),
                    callbacks: _callbacks(),
                    isOptionsOpen: _isOptionsOpen,
                  ),
                ),
              },
      );
}
