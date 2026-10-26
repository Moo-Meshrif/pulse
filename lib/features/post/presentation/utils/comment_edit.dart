import '../../domain/entity/comment_entity.dart';

/// A comment taken out of the list, with where it was, so it can go back.
typedef RemovedComment = ({CommentEntity comment, int index});

/// Changes to a loaded list of top-level comments, each with its replies.
abstract final class CommentEdit {
  /// [comments] with the comment [id] (top level or reply) replaced by `change` of it.
  static List<CommentEntity> update(
    List<CommentEntity> comments,
    String id,
    CommentEntity Function(CommentEntity comment) change,
  ) => comments
      .map(
        (comment) => comment.id == id
            ? change(comment)
            : comment.replies.any((reply) => reply.id == id)
            ? comment.copyWith(
                replies: comment.replies
                    .map((reply) => reply.id == id ? change(reply) : reply)
                    .toList(),
              )
            : comment,
      )
      .toList();

  /// [comment] liked or unliked, its count moved by one.
  static CommentEntity liked(CommentEntity comment, {required bool liked}) =>
      comment.copyWith(
        likedByMe: liked,
        likeCount: (comment.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 31),
      );

  /// Whether a comment or reply with [id] is in [comments].
  static bool contains(List<CommentEntity> comments, String id) => comments.any(
    (comment) =>
        comment.id == id || comment.replies.any((reply) => reply.id == id),
  );

  /// [comment] at the top of [comments].
  static List<CommentEntity> prepend(
    List<CommentEntity> comments,
    CommentEntity comment,
  ) => [comment, ...comments];

  /// [reply] added to the thread [parentId] when all its replies are loaded (so the order holds); otherwise
  /// only the thread's count grows and the reply comes with "View more".
  static List<CommentEntity> addReply(
    List<CommentEntity> comments,
    String parentId,
    CommentEntity reply,
  ) => update(comments, parentId, (thread) {
    final complete = thread.replies.length >= thread.replyCount;
    return thread.copyWith(
      replies: complete ? [...thread.replies, reply] : null,
      replyCount: thread.replyCount + 1,
    );
  });

  /// The place of comment or reply [id]: its list index in [comments] or in its thread; null when absent.
  static RemovedComment? find(List<CommentEntity> comments, String id) {
    for (final (i, comment) in comments.indexed) {
      if (comment.id == id) return (comment: comment, index: i);
      final at = comment.replies.indexWhere((reply) => reply.id == id);
      if (at >= 0) return (comment: comment.replies[at], index: at);
    }
    return null;
  }

  /// [comments] without comment or reply [id]. A removed reply lowers its thread's count.
  static List<CommentEntity> remove(
    List<CommentEntity> comments,
    String id,
  ) => [
    for (final comment in comments)
      if (comment.id != id)
        if (comment.replies.any((reply) => reply.id == id))
          comment.copyWith(
            replies: comment.replies.where((reply) => reply.id != id).toList(),
            replyCount: comment.replyCount - 1,
          )
        else
          comment,
  ];

  /// [removed] put back where it was in [comments] (a reply goes back into its thread).
  static List<CommentEntity> restore(
    List<CommentEntity> comments,
    RemovedComment removed,
  ) {
    final comment = removed.comment;
    final parentId = comment.parentId;
    if (parentId == null) {
      return [...comments]
        ..insert(removed.index.clamp(0, comments.length), comment);
    }
    return update(comments, parentId, (thread) {
      final replies = [...thread.replies]
        ..insert(removed.index.clamp(0, thread.replies.length), comment);
      return thread.copyWith(
        replies: replies,
        replyCount: thread.replyCount + 1,
      );
    });
  }
}
