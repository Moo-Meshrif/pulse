import 'package:flutter/material.dart';

import '../../../../../core/state/load_more_status.dart';
import '../../../../profile/domain/entity/last_account_entity.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../utils/pending_comment.dart';
import 'comment_posting_row.dart';
import 'comment_row.dart';
import 'comment_view_replies.dart';

/// A top-level comment, the replies loaded so far, your replies being sent, and the line that loads the rest.
class CommentThread extends StatelessWidget {
  const CommentThread({
    super.key,
    required this.comment,
    required this.repliesStatus,
    required this.pending,
    required this.me,
    required this.highlightedId,
    required this.onLike,
    required this.onLikeOnce,
    required this.onOptions,
    required this.onReply,
    required this.onMoreReplies,
    required this.onRetry,
    required this.onDiscard,
  });

  final CommentEntity comment;

  /// Paging of this thread's replies; null when nothing is loading.
  final LoadMoreStatus? repliesStatus;

  /// Your replies in this thread that the server has not confirmed.
  final List<PendingComment> pending;
  final LastAccountEntity? me;

  /// The comment or reply a reply is being written to.
  final String? highlightedId;
  final ValueChanged<CommentEntity> onLike;
  final ValueChanged<CommentEntity> onLikeOnce;

  /// Opens the long-press menu of a comment; resolves when it is closed.
  final Future<void> Function(CommentEntity) onOptions;

  /// Null when comments are off.
  final ValueChanged<CommentEntity>? onReply;
  final VoidCallback onMoreReplies;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDiscard;

  @override
  Widget build(BuildContext context) {
    final remaining = comment.replyCount - comment.replies.length;
    final reply = onReply;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommentRow(
          comment: comment,
          highlighted: highlightedId == comment.id,
          onLike: () => onLike(comment),
          onLikeOnce: () => onLikeOnce(comment),
          onOptions: () => onOptions(comment),
          onReply: reply == null ? null : () => reply(comment),
        ),
        for (final item in comment.replies)
          CommentRow(
            comment: item,
            highlighted: highlightedId == item.id,
            onLike: () => onLike(item),
            onLikeOnce: () => onLikeOnce(item),
            onOptions: () => onOptions(item),
            onReply: reply == null ? null : () => reply(item),
          ),
        if (remaining > 0)
          CommentViewReplies(
            remaining: remaining,
            status: repliesStatus,
            onTap: onMoreReplies,
          ),
        for (final item in pending)
          CommentPostingRow(
            key: ValueKey(item.clientId),
            pending: item,
            me: me,
            onRetry: () => onRetry(item.clientId),
            onDelete: () => onDiscard(item.clientId),
          ),
      ],
    );
  }
}
