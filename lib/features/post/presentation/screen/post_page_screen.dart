import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/notice_context.dart';
import '../../../../core/router/app_navigator.dart';
import '../cubit/comment_mentions/comment_mentions_cubit.dart';
import '../cubit/comments/comments_cubit.dart';
import '../cubit/comments/comments_state.dart';
import '../cubit/post_actions/post_actions_cubit.dart';
import '../cubit/post_actions/post_actions_state.dart';
import '../cubit/post_page/post_page_cubit.dart';
import '../cubit/post_page/post_page_state.dart';
import '../utils/enums/post_row.dart';
import '../utils/post_page_args.dart';
import '../view/post_page_view.dart';

/// One post on its own page (docs/specs/post/screens/s15-post-page.md): provides the cubits and holds the
/// one-shot effects (notices, leaving when the post is deleted, telling the feed the counts changed).
class PostPageScreen extends StatelessWidget {
  const PostPageScreen({super.key, required this.args});

  final PostPageArgs args;

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) =>
            getIt<PostPageCubit>(param1: args.postId, param2: args.post)
              ..load(),
      ),
      BlocProvider(create: (_) => getIt<PostActionsCubit>()),
      BlocProvider(
        create: (_) => getIt<CommentsCubit>(
          param1: args.postId,
          param2: args.focusCommentId,
        )..load(),
      ),
      BlocProvider(
        create: (_) => getIt<CommentMentionsCubit>(param1: args.postId),
      ),
    ],
    child: MultiBlocListener(
      listeners: [
        BlocListener<PostPageCubit, PostPageState>(
          listenWhen: (before, now) =>
              now.failure != null && before.failure != now.failure,
          listener: (context, state) => context.showFailure(state.failure),
        ),
        // A fresh read already holds what was done here.
        BlocListener<PostPageCubit, PostPageState>(
          listenWhen: (before, now) => before.post != now.post,
          listener: (context, state) =>
              context.read<PostActionsCubit>().forget({args.postId}),
        ),
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: (before, now) =>
              now.failure != null && before.failure != now.failure,
          listener: (context, state) => context.showFailure(state.failure),
        ),
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: (before, now) =>
              before.posts[args.postId] != now.posts[args.postId],
          listener: (context, state) {
            final post = state.posts[args.postId];
            if (post != null) context.read<PostPageCubit>().countsChanged(post);
          },
        ),
        // A like made here changes who is named in "Liked by".
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: (before, now) =>
              before.posts[args.postId]?.likedByMe !=
              now.posts[args.postId]?.likedByMe,
          listener: (context, state) {
            final page = context.read<PostPageCubit>();
            if (!(state.posts[args.postId]?.likedByMe ?? true)) {
              page.youUnliked();
            }
            // The server knows the new like only once the request ends.
            context
                .read<PostActionsCubit>()
                .likeSettled(args.postId)
                .then((_) => page.loadLikedBy());
          },
        ),
        BlocListener<PostActionsCubit, PostActionsState>(
          listenWhen: (before, now) =>
              before.rows[args.postId] != now.rows[args.postId] &&
              _isGone(now.rows[args.postId]),
          listener: (context, state) => AppNavigator.back<void>(context),
        ),
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (before, now) =>
              now.failure != null && before.failure != now.failure,
          listener: (context, state) => context.showFailure(state.failure),
        ),
        BlocListener<CommentsCubit, CommentsState>(
          listenWhen: (before, now) => before.countDelta != now.countDelta,
          listener: _commentCountChanged,
        ),
      ],
      child: PostPageView(args: args),
    ),
  );

  bool _isGone(PostRow? row) =>
      row == PostRow.deleting || row == PostRow.removed;

  /// The comments added or removed here show on the post's count.
  void _commentCountChanged(BuildContext context, CommentsState state) {
    final post = context.read<PostPageCubit>().state.post?.entity;
    if (post == null) return;
    context.read<PostActionsCubit>().commentCountChanged(
      post,
      post.commentCount + state.countDelta,
    );
  }
}
