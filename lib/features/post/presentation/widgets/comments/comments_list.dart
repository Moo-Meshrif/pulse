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

BlocSelector<CommentsCubit, CommentsState, _ListData> _selectList({
  required Widget Function(BuildContext context, _Rows rows) builder,
  required bool commentsEnabled,
  required bool isPostOwner,
  String? highlightedId,
}) => BlocSelector<CommentsCubit, CommentsState, _ListData>(
  selector: (state) => (
    comments: state.comments,
    replies: state.replies,
    pending: state.pending,
    replyToId: state.replyTo?.id,
    more: state.more,
    hasMore: state.nextCursor != null,
  ),
  builder: (context, data) => builder(
    context,
    _Rows(
      cubit: context.read<CommentsCubit>(),
      data: data,
      commentsEnabled: commentsEnabled,
      isPostOwner: isPostOwner,
      highlightedId: highlightedId,
    ),
  ),
);

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
  Widget build(BuildContext context) => _selectList(
    commentsEnabled: commentsEnabled,
    isPostOwner: isPostOwner,
    builder: (context, rows) => LoadMoreListener(
      onLoadMore: context.read<CommentsCubit>().loadMore,
      child: ListView.builder(itemCount: rows.count, itemBuilder: rows.item),
    ),
  );
}

/// The same rows for the post page, whose own scroll holds them: built lazily, and the page asks for the
/// next page itself.
class CommentsSliverList extends StatelessWidget {
  const CommentsSliverList({
    super.key,
    required this.commentsEnabled,
    required this.isPostOwner,
    this.highlightedId,
  });

  /// A comment lit up for a moment (the one a notification points at), when none is being replied to.
  final String? highlightedId;

  final bool isPostOwner;
  final bool commentsEnabled;

  @override
  Widget build(BuildContext context) => _selectList(
    commentsEnabled: commentsEnabled,
    isPostOwner: isPostOwner,
    highlightedId: highlightedId,
    builder: (context, rows) =>
        SliverList.builder(itemCount: rows.count, itemBuilder: rows.item),
  );
}

class _Rows {
  _Rows({
    required this.cubit,
    required this.data,
    required this.commentsEnabled,
    required this.isPostOwner,
    required this.highlightedId,
  }) {
    // Your unconfirmed comments: top-level ones lead the list, replies sit in their thread.
    for (final item in data.pending) {
      final parent = item.parentId;
      if (parent == null) {
        _topLevel.add(item);
      } else {
        (_repliesOf[parent] ??= []).add(item);
      }
    }
  }

  final CommentsCubit cubit;
  final _ListData data;
  final bool commentsEnabled;
  final bool isPostOwner;
  final String? highlightedId;
  final _topLevel = <PendingComment>[];
  final _repliesOf = <String, List<PendingComment>>{};

  int get count =>
      _topLevel.length + data.comments.length + (data.hasMore ? 1 : 0);

  Widget item(BuildContext context, int index) {
    final threadsStart = _topLevel.length;
    if (index < threadsStart) {
      final item = _topLevel[index];
      return CommentPostingRow(
        key: ValueKey(item.clientId),
        pending: item,
        me: cubit.me,
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
      pending: _repliesOf[comment.id] ?? const [],
      me: cubit.me,
      highlightedId: data.replyToId ?? highlightedId,
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
