import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/comment_sort.dart';
import '../../../domain/entity/post_entity.dart';
import '../../cubit/comments/comments_cubit.dart';
import '../../cubit/comments/comments_state.dart';
import '../../cubit/post_actions/post_actions_cubit.dart';
import '../../cubit/post_actions/post_actions_state.dart';
import '../../cubit/post_page/post_page_cubit.dart';
import '../../cubit/post_page/post_page_state.dart';
import '../../dimens/comments_dimens.dart';
import '../../dimens/post_page_dimens.dart';
import '../../utils/enums/comments_status.dart';
import '../comments/comment_composer.dart';
import '../comments/comment_sort_chip.dart';
import '../comments/comments_empty.dart';
import '../comments/comments_list.dart';
import '../comments/comments_off_bar.dart';
import '../comments/comments_skeleton.dart';

/// Whether comments are on for the post, with what was done here (the options sheet can turn them off).
bool _commentsEnabled(PostEntity? post, PostActionsState actions) {
  if (post == null) return true;
  return (actions.posts[post.id] ?? post).commentsEnabled;
}

/// The comments section of the post page as slivers: a white card with the header and sort, then the
/// comments of the sheet built lazily in the page's own scroll.
class PostPageComments extends StatelessWidget {
  const PostPageComments({
    super.key,
    required this.headerKey,
    required this.isPostOwner,
    this.highlightedId,
  });

  /// Marks the header so the page can scroll to the section.
  final GlobalKey headerKey;
  final bool isPostOwner;
  final String? highlightedId;

  @override
  Widget build(BuildContext context) => DecoratedSliver(
    decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
    ),
    sliver: SliverPadding(
      padding: PostPageDimens.sectionPadding,
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(child: _Header(key: headerKey)),
          BlocSelector<PostPageCubit, PostPageState, PostEntity?>(
            selector: (state) => state.post?.entity,
            builder: (context, post) =>
                BlocSelector<PostActionsCubit, PostActionsState, bool>(
                  selector: (actions) => _commentsEnabled(post, actions),
                  builder: (context, enabled) => _Content(
                    commentsEnabled: enabled,
                    isPostOwner: isPostOwner,
                    highlightedId: highlightedId,
                  ),
                ),
          ),
        ],
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: CommentsDimens.headerGap),
    child: Row(
      children: [
        Expanded(
          child: AppText(
            context.l10n.commentsTitle,
            style: context.text.section,
            color: context.appColors.textPrimary,
            maxLines: 1,
          ),
        ),
        BlocSelector<CommentsCubit, CommentsState, CommentSort>(
          selector: (state) => state.sort,
          builder: (context, sort) => CommentSortChip(
            sort: sort,
            onChanged: context.read<CommentsCubit>().changeSort,
          ),
        ),
      ],
    ),
  );
}

class _Content extends StatelessWidget {
  const _Content({
    required this.commentsEnabled,
    required this.isPostOwner,
    required this.highlightedId,
  });

  final bool commentsEnabled;
  final bool isPostOwner;
  final String? highlightedId;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CommentsCubit, CommentsState>(
        buildWhen: (before, now) =>
            before.status != now.status || _isEmpty(before) != _isEmpty(now),
        builder: (context, state) => switch (state.status) {
          CommentsStatus.loading => const SliverToBoxAdapter(
            child: CommentsSkeleton(),
          ),
          CommentsStatus.failed => SliverToBoxAdapter(
            child: AppEmpty.failed(
              onRetry: context.read<CommentsCubit>().load,
            ),
          ),
          CommentsStatus.ready =>
            _isEmpty(state)
                ? const SliverToBoxAdapter(child: CommentsEmpty())
                : CommentsSliverList(
                    commentsEnabled: commentsEnabled,
                    isPostOwner: isPostOwner,
                    highlightedId: highlightedId,
                  ),
        },
      );
}

bool _isEmpty(CommentsState state) =>
    state.comments.isEmpty && state.pending.isEmpty;

/// The comment field pinned under the page, or the bar that says comments are off.
class PostPageComposer extends StatelessWidget {
  const PostPageComposer({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<PostPageCubit, PostPageState, PostEntity?>(
        selector: (state) => state.post?.entity,
        builder: (context, post) =>
            BlocSelector<PostActionsCubit, PostActionsState, bool>(
              selector: (actions) => _commentsEnabled(post, actions),
              builder: (context, enabled) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(
                    height: CommentsDimens.divider,
                    thickness: CommentsDimens.divider,
                    color: context.appColors.divider,
                  ),
                  if (enabled)
                    Padding(
                      padding: PostPageDimens.composerPadding,
                      child: CommentComposer(focusNode: focusNode),
                    )
                  else
                    const CommentsOffBar(),
                ],
              ),
            ),
      );
}
