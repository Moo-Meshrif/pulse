import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_navigator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/dimens/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/post_entity.dart';
import '../cubit/comments/comments_cubit.dart';
import '../cubit/comments/comments_state.dart';
import '../cubit/post_actions/post_actions_cubit.dart';
import '../cubit/post_actions/post_actions_state.dart';
import '../cubit/post_page/post_page_cubit.dart';
import '../cubit/post_page/post_page_state.dart';
import '../dimens/post_page_dimens.dart';
import '../screen/add_edit_post_screen.dart';
import '../utils/enums/post_page_status.dart';
import '../utils/feed_post.dart';
import '../utils/feed_videos.dart';
import '../utils/post_card_callbacks.dart';
import '../utils/post_card_mapper.dart';
import '../utils/post_options_actions_of.dart';
import '../utils/post_page_args.dart';
import '../utils/post_tag_removal.dart';
import '../utils/share_access_of.dart';
import '../utils/story_post_args_of.dart';
import '../widgets/post_card.dart';
import '../widgets/post_options/post_options_flow.dart';
import '../widgets/post_page/post_follow_chip.dart';
import '../widgets/post_page/post_liked_by_row.dart';
import '../widgets/post_page/post_notification_chip.dart';
import '../widgets/post_page/post_page_comments.dart';
import '../widgets/post_page/post_page_date.dart';
import '../widgets/post_page/post_page_top_bar.dart';
import '../widgets/post_page/post_page_unavailable.dart';
import '../widgets/post_video_scope.dart';
import '../widgets/share_sheet/share_sheet.dart';
import '../widgets/tagged_people/tagged_people_sheet.dart';

/// The post page: the bar, the post with its comments below, and the comment field pinned at the bottom.
class PostPageView extends StatefulWidget {
  const PostPageView({super.key, required this.args});

  final PostPageArgs args;

  @override
  State<PostPageView> createState() => _PostPageViewState();
}

class _PostPageViewState extends State<PostPageView> {
  final _scroll = ScrollController();
  final _commentsKey = GlobalKey();
  final _composerFocus = FocusNode();
  final _showAuthor = ValueNotifier(false);
  Timer? _focusTimer;

  /// The comment a notification pointed at, lit for a moment.
  String? _litCommentId;
  bool _isOptionsOpen = false;

  PostPageCubit get _page => context.read<PostPageCubit>();
  PostActionsCubit get _actions => context.read<PostActionsCubit>();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    if (widget.args.focusComposer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _composerFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _scroll.dispose();
    _composerFocus.dispose();
    _showAuthor.dispose();
    super.dispose();
  }

  void _onScroll() {
    _showAuthor.value =
        _scroll.hasClients && _scroll.offset > PostPageDimens.miniAuthorOffset;
  }

  /// The first page of comments is in: light the comment the link points at, and take the light away.
  void _lightFocusedComment(CommentsState state) {
    String? found;
    for (final comment in state.comments) {
      if (comment.isFocus) found = comment.id;
      for (final reply in comment.replies) {
        if (reply.isFocus) found = reply.id;
      }
    }
    if (found == null) return;
    setState(() => _litCommentId = found);
    _focusTimer?.cancel();
    _focusTimer = Timer(PostPageDimens.focusDuration, () {
      if (mounted) setState(() => _litCommentId = null);
    });
  }

  PostEntity? get _entity => _page.state.post?.entity;

  PostCardCallbacks _callbacks(FeedPost post) => PostCardCallbacks(
    onProfile: () => _openProfile(post.entity.authorId),
    onOptions: _openOptions,
    onLike: () => _actions.toggleLike(post.entity),
    onDoubleTapLike: () => _actions.likeByDoubleTap(post.entity),
    onComment: _goToComments,
    onShare: () => _share(post),
    onSave: () => _actions.toggleSave(post.entity),
    onTaggedPerson: _openProfile,
    onTaggedPeople: _openTaggedPeople,
    onRemoveMyTag: _removeMyTag,
    onOriginalProfile: () {
      final original = post.entity.original;
      if (original != null) _openProfile(original.authorId);
    },
    onOriginal: () {
      final original = post.entity.original;
      if (original == null) return;
      AppNavigator.push<void>(
        context,
        AppRoutes.postPage(original.id),
        rootNavigator: true,
      );
    },
  );

  void _openProfile(String userId) =>
      AppNavigator.push<void>(context, AppRoutes.profileOf(userId));

  /// The comment icon: show the comments and put the cursor in the field.
  void _goToComments() {
    final target = _commentsKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: PostPageDimens.scrollToComments,
        curve: Curves.easeOut,
      );
    }
    _composerFocus.requestFocus();
  }

  void _share(FeedPost post) {
    final target = shareTarget(post.entity);
    final access = shareAccessOf(post.entity, userId: _page.state.userId);
    if (target == null || !access.isShown) return;
    ShareSheet.show(
      context,
      postId: target.id,
      access: access,
      story: storyPostArgsOf(post, target),
    );
  }

  Future<void> _openTaggedPeople() async {
    final entity = _entity;
    if (entity == null) return;
    final result = await TaggedPeopleSheet.show(context, postId: entity.id);
    if (result == null || !mounted) return;
    final profileId = result.profileId;
    if (profileId != null) {
      _openProfile(profileId);
    } else if (result.removeMe) {
      await _removeMyTag();
    }
  }

  Future<void> _removeMyTag() {
    final entity = _entity;
    if (entity == null) return Future.value();
    return PostTagRemoval.confirmAndRemove(
      context,
      ownerName: entity.username,
      remove: () => _removeMyTagOf(_actions, entity),
    );
  }

  Future<void> _removeMyTagOf(PostActionsCubit actions, PostEntity entity) {
    final userId = _page.state.userId;
    return userId == null
        ? Future.value()
        : actions.removeMyTag(entity, userId: userId);
  }

  Map<String, String>? _signedUrls(FeedPost post) {
    final map = <String, String>{};
    for (final e in post.media) {
      if (e.cacheKey != null && e.url != null) map[e.cacheKey!] = e.url!;
      if (e.posterCacheKey != null && e.posterUrl != null) {
        map[e.posterCacheKey!] = e.posterUrl!;
      }
    }
    return map.isEmpty ? null : map;
  }

  void _openEdit() {
    final post = _page.state.post;
    if (post == null) return;
    final original = post.entity.original;
    AppNavigator.push<void>(
      context,
      AppRoutes.editPost,
      rootNavigator: true,
      arguments: AddEditPostArgs(
        post: _actions.postOf(post.entity),
        signedUrls: _signedUrls(post),
        original: original == null
            ? null
            : postCardData(
                original,
                post.originalMedia,
                userId: _page.state.userId,
              ),
      ),
    );
  }

  Future<void> _openOptions() async {
    final post = _page.state.post;
    if (post == null) return;
    final actions = _actions;
    final loaded = post.entity;
    final data = postOptionsData(
      actions.postOf(loaded),
      userId: _page.state.userId,
    );
    setState(() => _isOptionsOpen = true);
    await PostOptionsFlow.show(
      context,
      data: data,
      actions: postOptionsActionsOf(
        actions,
        loaded,
        onEdit: _openEdit,
        onRemoveMyTag: () => _removeMyTagOf(actions, loaded),
        onShare: () => _share(post),
      ),
    );
    if (mounted) setState(() => _isOptionsOpen = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.appColors.background,
    body: BlocListener<CommentsCubit, CommentsState>(
      listenWhen: (before, now) =>
          widget.args.focusCommentId != null &&
          before.comments.isEmpty &&
          now.comments.isNotEmpty,
      listener: (context, state) => _lightFocusedComment(state),
      child: Column(
        children: [
          _TopBar(
            showAuthor: _showAuthor,
            onBack: () => AppNavigator.back<void>(context),
            onOptions: _openOptions,
          ),
          Expanded(
            child: AppSafeArea(
              top: false,
              bottom: false, // the pinned field takes the bottom inset on its white band
              child: BlocBuilder<PostPageCubit, PostPageState>(
                buildWhen: (before, now) =>
                    before.status != now.status || before.post != now.post,
                builder: (context, state) => switch (state.status) {
                  PostPageStatus.loading => Center(
                    child: PulseLineLoader(
                      color: context.appColors.primary,
                      width: LoadingDimens.loadMoreWidth,
                    ),
                  ),
                  PostPageStatus.failed => AppEmpty.failed(onRetry: _page.load),
                  PostPageStatus.unavailable => const PostPageUnavailable(),
                  PostPageStatus.ready => _buildReady(state.post!),
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildReady(FeedPost post) => ContentWidth(
    child: Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              LoadMoreListener(
                onLoadMore: context.read<CommentsCubit>().loadMore,
                child: CustomScrollView(
                  controller: _scroll,
                  slivers: [
                    SliverPadding(
                      padding: PostPageDimens.listPadding,
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          SliverToBoxAdapter(
                            child: PostVideoScope(
                              videos: feedVideos([post]),
                              startMuted: false,
                              child: _Card(
                                post: post,
                                callbacks: _callbacks(post),
                                isOptionsOpen: _isOptionsOpen,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(height: PostPageDimens.sectionGap),
                          ),
                          PostPageComments(
                            headerKey: _commentsKey,
                            isPostOwner:
                                post.entity.authorId == _page.state.userId,
                            highlightedId: _litCommentId,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_litCommentId != null)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(child: PostNotificationChip()),
                ),
            ],
          ),
        ),
        ColoredBox(
          color: context.appColors.surface,
          child: AppSafeArea(
            top: false,
            child: PostPageComposer(focusNode: _composerFocus),
          ),
        ),
      ],
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.showAuthor,
    required this.onBack,
    required this.onOptions,
  });

  final ValueListenable<bool> showAuthor;
  final VoidCallback onBack;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PostPageCubit, PostPageState>(
        buildWhen: (before, now) =>
            before.post?.entity.authorId != now.post?.entity.authorId,
        builder: (context, state) {
          final post = state.post?.entity;
          return ValueListenableBuilder<bool>(
            valueListenable: showAuthor,
            builder: (context, show, _) => PostPageTopBar(
              onBack: onBack,
              onOptions: post == null ? null : onOptions,
              showAuthor: show && post != null,
              authorId: post?.authorId,
              authorName: post == null
                  ? null
                  : (post.fullName?.trim().isNotEmpty ?? false)
                  ? post.fullName
                  : post.username,
              authorAvatarUrl: post?.avatarUrl,
            ),
          );
        },
      );
}

/// The card with what the page changed on it (likes, saves, counts) applied.
class _Card extends StatelessWidget {
  const _Card({
    required this.post,
    required this.callbacks,
    required this.isOptionsOpen,
  });

  final FeedPost post;
  final PostCardCallbacks callbacks;
  final bool isOptionsOpen;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostActionsCubit, PostActionsState, PostEntity?>(
        selector: (state) => state.posts[post.id],
        builder: (context, changed) {
          final entity = changed ?? post.entity;
          return PostCard(
            data: postCardData(
              entity,
              post.media,
              userId: context.read<PostPageCubit>().state.userId,
              originalMedia: post.originalMedia,
            ),
            callbacks: callbacks,
            isOptionsOpen: isOptionsOpen,
            isDetail: true,
            authorTrailing: const PostFollowChip(),
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostLikedByRow(postId: post.id),
                PostPageDate(createdAt: entity.createdAt),
              ],
            ),
          );
        },
      );
}
