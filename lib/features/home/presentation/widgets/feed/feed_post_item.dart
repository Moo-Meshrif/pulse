import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/extensions/notice_context.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../post/domain/entity/liked_by_preview_entity.dart';
import '../../../../post/domain/entity/post_entity.dart';
import '../../../../post/presentation/cubit/post_actions/post_actions_cubit.dart';
import '../../../../post/presentation/cubit/post_actions/post_actions_state.dart';
import '../../../../post/presentation/screen/add_edit_post_screen.dart';
import '../../../../post/presentation/utils/enums/post_row.dart';
import '../../../../post/presentation/utils/feed_post.dart';
import '../../../../post/presentation/utils/post_card_callbacks.dart';
import '../../../../post/presentation/utils/post_card_data.dart';
import '../../../../post/presentation/utils/post_card_mapper.dart';
import '../../../../post/presentation/utils/post_entity_edit.dart';
import '../../../../post/presentation/utils/post_options_actions.dart';
import '../../../../post/presentation/utils/post_options_actions_of.dart';
import '../../../../post/presentation/utils/post_page_args.dart';
import '../../../../post/presentation/utils/post_tag_removal.dart';
import '../../../../post/presentation/utils/share_access_of.dart';
import '../../../../post/presentation/utils/story_post_args_of.dart';
import '../../../../post/presentation/widgets/comments/comments_sheet.dart';
import '../../../../post/presentation/widgets/hidden_post_row.dart';
import '../../../../post/presentation/widgets/post_card.dart';
import '../../../../post/presentation/widgets/post_options/post_options_flow.dart';
import '../../../../post/presentation/widgets/post_page/post_liked_by_row.dart';
import '../../../../post/presentation/widgets/share_sheet/share_sheet.dart';
import '../../../../post/presentation/widgets/tagged_people/tagged_people_sheet.dart';
import '../../../../profile/presentation/cubit/own_author/own_author_cubit.dart';
import '../../../../profile/presentation/cubit/own_author/own_author_state.dart';
import '../../cubit/feed/feed_cubit.dart';
import '../../cubit/feed/feed_state.dart';
import '../../dimens/home_dimens.dart';
import 'fresh_ring.dart';

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
      if (e.cacheKey != null && e.url != null) {
        map[e.cacheKey!] = e.url!;
      }
      if (e.posterCacheKey != null && e.posterUrl != null) {
        map[e.posterCacheKey!] = e.posterUrl!;
      }
    }
    return map.isEmpty ? null : map;
  }

  PostActionsCubit get _actions => context.read<PostActionsCubit>();

  /// The signed-in person's id: fixed for the session, so reading it once per tap or build is enough.
  String? get _userId => context.read<FeedCubit>().userId;

  /// Only what the cubit changed is selected: the post itself comes from the widget at build time, so an
  /// edited post is never drawn from a copy the selector kept.
  ({PostEntity? changed, PostRow row, bool muted, bool isOriginalGone})
  _current(PostActionsState state) => (
    changed: state.posts[_loaded.id],
    row: state.rows[_loaded.id] ?? PostRow.card,
    muted: state.mutedAuthors.contains(_loaded.authorId),
    isOriginalGone: _isOriginalGone(state),
  );

  /// The original of this share was deleted from this list (maybe still with Undo): the share shows the
  /// "unavailable" tile now, without loading the feed again.
  bool _isOriginalGone(PostActionsState state) {
    final id = _loaded.original?.id;
    final row = id == null ? null : state.rows[id];
    return row == PostRow.deleting || row == PostRow.removed;
  }

  PostEntity _shown(
    PostEntity? changed,
    bool isOriginalGone,
    OwnAuthorState? me,
  ) {
    final entity = changed ?? widget.post.entity;
    final shown = isOriginalGone ? entity.withoutOriginal() : entity;
    final id = me?.id;
    final username = me?.username;
    return id == null || username == null
        ? shown
        : shown.withAuthor(
            authorId: id,
            username: username,
            fullName: me?.fullName,
            avatarUrl: me?.avatarUrl,
          );
  }

  /// The signed-in person's current name and photo, once known. The card rebuilds only when they change (a
  /// saved Personal info): their posts, shares and the "Liked by" avatar all show them.
  OwnAuthorState? _mine(OwnAuthorState me) => me.id == null ? null : me;

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
    onOriginalProfile: _openOriginalProfile,
    onOriginal: _openOriginal,
    onOpenPost: _openPostPage,
  );

  /// The delete's Undo and commit run when the notice ends, maybe after this card has scrolled away:
  /// they use the cubit and post taken now, never the context.
  PostOptionsActions _optionsActions() {
    final actions = _actions;
    final loaded = _loaded;
    return postOptionsActionsOf(
      actions,
      loaded,
      onEdit: _openEdit,
      onRemoveMyTag: () => _removeMyTagOf(actions, loaded),
      onShare: _share,
    );
  }

  void _openProfile() => _openProfileOf(_loaded.authorId);

  void _openOriginalProfile() {
    final original = _loaded.original;
    if (original != null) _openProfileOf(original.authorId);
  }

  void _openOriginal() {
    final original = _loaded.original;
    if (original == null) return;
    AppNavigator.push<void>(
      context,
      AppRoutes.postPage(original.id),
      rootNavigator: true,
    );
  }

  /// The caption or the time: this post's page, shown at once with the post the feed already has.
  void _openPostPage() => AppNavigator.push<void>(
    context,
    AppRoutes.postPage(_loaded.id),
    rootNavigator: true,
    arguments: PostPageArgs(postId: _loaded.id, post: widget.post),
  );

  void _openProfileOf(String userId) =>
      AppNavigator.push<void>(context, AppRoutes.profileOf(userId));

  /// The cubit takes the tag off at once; a failure puts it back and is thrown to the dialog flow.
  Future<void> _removeMyTagOf(PostActionsCubit actions, PostEntity loaded) {
    final userId = _userId;
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
      original: _editedOriginal(),
    ),
  );

  /// A share under edit shows the shared post read-only, with the links the feed already signed.
  PostCardData? _editedOriginal() {
    final original = _loaded.original;
    if (original == null) return null;
    return postCardData(original, widget.post.originalMedia, userId: _userId);
  }

  /// Opens the comments sheet; the card's count follows what the sheet added or removed.
  void _openComments() {
    final actions = _actions;
    final loaded = _loaded;
    final now = actions.postOf(loaded);
    final countAtOpen = now.commentCount;
    CommentsSheet.show(
      context,
      postId: loaded.id,
      commentsEnabled: now.commentsEnabled,
      isPostOwner: loaded.authorId == _userId,
      fromCommentIcon: true,
      onCountChanged: (delta) =>
          actions.commentCountChanged(loaded, countAtOpen + delta),
    );
  }

  /// Opens the Share sheet of this post, or of the original when it is a share.
  void _share() {
    final userId = _userId;
    final target = shareTarget(_loaded);
    final access = shareAccessOf(_loaded, userId: userId);
    if (target == null || !access.isShown) return;
    ShareSheet.show(
      context,
      postId: target.id,
      access: access,
      story: storyPostArgsOf(widget.post, target),
    );
  }

  Future<void> _openOptions() async {
    final data = postOptionsData(_actions.postOf(_loaded), userId: _userId);
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

  /// The preview was saved with the avatar the person had then: show the one they have now.
  LikedByPreviewEntity _withMyAvatar(
    LikedByPreviewEntity likedBy,
    OwnAuthorState? me,
  ) {
    final id = me?.id;
    final username = me?.username;
    if (id == null || username == null) return likedBy;
    return likedBy.withAvatarOf(
      id,
      name: me?.fullName ?? username,
      avatarUrl: me?.avatarUrl,
    );
  }

  /// "Liked by …" under the buttons: only once the feed has loaded it and the post still has likes.
  Widget _likedByFooter(PostEntity post, OwnAuthorState? me) =>
      BlocSelector<FeedCubit, FeedState, LikedByPreviewEntity?>(
        selector: (state) => state.likedBy[post.id],
        builder: (context, likedBy) => likedBy == null || post.likeCount <= 0
            ? const SizedBox.shrink()
            : LikedByRow(
                likedBy: _withMyAvatar(likedBy, me),
                onTap: () => AppNavigator.push<void>(
                  context,
                  AppRoutes.postLikes(post.id),
                  rootNavigator: true,
                ),
              ),
      );

  @override
  Widget build(BuildContext context) =>
      BlocSelector<
        PostActionsCubit,
        PostActionsState,
        ({PostEntity? changed, PostRow row, bool muted, bool isOriginalGone})
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
                  child: FreshRing(
                    postId: _loaded.id,
                    child:
                        BlocSelector<
                          OwnAuthorCubit,
                          OwnAuthorState,
                          OwnAuthorState?
                        >(
                          selector: _mine,
                          builder: (context, me) {
                            final shown = _shown(
                              current.changed,
                              current.isOriginalGone,
                              me,
                            );
                            return PostCard(
                              data: postCardData(
                                shown,
                                widget.post.media,
                                userId: _userId,
                                originalMedia: widget.post.originalMedia,
                              ),
                              callbacks: _callbacks(),
                              isOptionsOpen: _isOptionsOpen,
                              footer: _likedByFooter(shown, me),
                            );
                          },
                        ),
                  ),
                ),
              },
      );
}
