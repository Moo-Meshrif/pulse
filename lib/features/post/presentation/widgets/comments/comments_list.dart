import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../../../core/theme/dimens/app_dimens.dart';
import '../../../../../core/widgets/paged_scroll_view/retry_row.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../cubit/comments/comments_cubit.dart';
import '../../cubit/comments/comments_state.dart';
import '../../dimens/comments_dimens.dart';
import '../../utils/pending_comment.dart';
import 'comment_options_flow.dart';
import 'comment_posting_row.dart';
import 'comment_thread.dart';

typedef _ListData = ({
  List<CommentEntity> comments,
  Map<String, LoadMoreStatus> replies,
  List<PendingComment> pending,
  String? replyToId,
  LoadMoreStatus more,
  bool hasMore,
});

/// The comments, a page at a time: the next page starts when the list nears its end. No pull to refresh.
class CommentsList extends StatelessWidget {
  const CommentsList({
    super.key,
    required this.commentsEnabled,
    required this.isPostOwner,
  });

  /// You wrote the post: you can hide comments on it.
  final bool isPostOwner;

  /// Off: the comments stay readable but cannot be replied to.
  final bool commentsEnabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CommentsCubit>();
    final me = cubit.me;
    return BlocSelector<CommentsCubit, CommentsState, _ListData>(
      selector: (state) => (
        comments: state.comments,
        replies: state.replies,
        pending: state.pending,
        replyToId: state.replyTo?.id,
        more: state.more,
        hasMore: state.nextCursor != null,
      ),
      builder: (context, data) {
        // Your unconfirmed comments: top-level ones lead the list, replies sit in their thread.
        final topLevel = <PendingComment>[];
        final repliesOf = <String, List<PendingComment>>{};
        for (final item in data.pending) {
          final parent = item.parentId;
          if (parent == null) {
            topLevel.add(item);
          } else {
            (repliesOf[parent] ??= []).add(item);
          }
        }
        final threadsStart = topLevel.length;
        return LoadMoreListener(
          onLoadMore: cubit.loadMore,
          child: ListView.builder(
            itemCount:
                threadsStart + data.comments.length + (data.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < threadsStart) {
                final item = topLevel[index];
                return CommentPostingRow(
                  key: ValueKey(item.clientId),
                  pending: item,
                  me: me,
                  onRetry: () => cubit.retry(item.clientId),
                  onDelete: () => cubit.discardFailed(item.clientId),
                );
              }
              final position = index - threadsStart;
              if (position == data.comments.length) {
                return _Footer(
                  status: data.more,
                  onRetry: () => cubit.loadMore(retry: true),
                );
              }
              final comment = data.comments[position];
              return CommentThread(
                key: ValueKey(comment.id),
                comment: comment,
                repliesStatus: data.replies[comment.id],
                pending: repliesOf[comment.id] ?? const [],
                me: me,
                highlightedId: data.replyToId,
                onLike: cubit.toggleLike,
                onLikeOnce: cubit.likeOnly,
                onOptions: (target) => CommentOptionsFlow.show(
                  context,
                  cubit: cubit,
                  comment: target,
                  isPostOwner: isPostOwner,
                  commentsEnabled: commentsEnabled,
                ),
                onReply: commentsEnabled ? cubit.startReply : null,
                onMoreReplies: () => cubit.loadMoreReplies(comment),
                onRetry: cubit.retry,
                onDiscard: cubit.discardFailed,
              );
            },
          ),
        );
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.status, required this.onRetry});

  final LoadMoreStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (status) {
    LoadMoreStatus.failed => RetryRow(
      label: context.l10n.commentsLoadMoreFailed,
      onTap: onRetry,
    ),
    _ => SizedBox(
      height: CommentsDimens.loadingBand,
      child: Center(
        child: PulseLineLoader(
          color: context.appColors.primary,
          width: LoadingDimens.loadMoreWidth,
        ),
      ),
    ),
  };
}
