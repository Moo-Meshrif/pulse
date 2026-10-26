import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/state/load_more_status.dart';
import '../../../data/enums/comment_sort.dart';
import '../../../domain/entity/comment_cursor_entity.dart';
import '../../../domain/entity/comment_entity.dart';
import '../../utils/enums/comments_status.dart';
import '../../utils/pending_comment.dart';

part 'comments_state.freezed.dart';

@freezed
abstract class CommentsState with _$CommentsState {
  const factory CommentsState({
    @Default(CommentsStatus.loading) CommentsStatus status,
    @Default(CommentSort.relevant) CommentSort sort,

    /// Top-level comments in list order, each with the replies loaded so far.
    @Default(<CommentEntity>[]) List<CommentEntity> comments,

    /// Where the next page starts; null when there is none.
    CommentCursorEntity? nextCursor,
    @Default(LoadMoreStatus.idle) LoadMoreStatus more,

    /// Threads (by top-level comment id) whose rest of replies is loading or failed.
    @Default(<String, LoadMoreStatus>{}) Map<String, LoadMoreStatus> replies,

    /// Your comments that are being sent or failed, oldest first.
    @Default(<PendingComment>[]) List<PendingComment> pending,

    /// The comment you are replying to (it may itself be a reply); null when writing a comment.
    CommentEntity? replyTo,

    /// The comment of yours whose words are in the field to be changed; null when not editing.
    CommentEntity? editing,

    /// One-shot: an emoji picked in the long-press menu, to put in the reply field.
    String? emoji,

    /// How many comments this sheet added to the post, for the count on the card.
    @Default(0) int countDelta,

    /// One-shot: an action did not go through (a like is put back).
    Failure? failure,
  }) = _CommentsState;
}
