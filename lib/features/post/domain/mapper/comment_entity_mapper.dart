import '../../data/model/comment_model.dart';
import '../../data/model/comment_page_model.dart';
import '../entity/comment_cursor_entity.dart';
import '../entity/comment_entity.dart';
import '../entity/comment_page_entity.dart';

/// Turns comment rows from the server into [CommentEntity]s.
abstract final class CommentEntityMapper {
  /// A row missing something the list needs is left out.
  static CommentEntity? fromModel(CommentModel comment) {
    final id = comment.id;
    final postId = comment.postId;
    final authorId = comment.authorId;
    final username = comment.username;
    final body = comment.body;
    final createdAt = comment.createdAt;
    if (id == null ||
        postId == null ||
        authorId == null ||
        username == null ||
        body == null ||
        createdAt == null) {
      return null;
    }
    return CommentEntity(
      id: id,
      postId: postId,
      parentId: comment.parentId,
      authorId: authorId,
      username: username,
      fullName: comment.fullName,
      avatarUrl: comment.avatarUrl,
      body: body,
      createdAt: createdAt,
      editedAt: comment.editedAt,
      likeCount: comment.likeCount ?? 0,
      likedByMe: comment.likedByMe ?? false,
      isPostAuthor: comment.isPostAuthor ?? false,
      replyCount: comment.replyCount ?? 0,
      replies: [
        for (final reply in comment.replies ?? const <CommentModel>[])
          ?fromModel(reply),
      ],
      isFocus: comment.isFocus ?? false,
      rank: comment.rank ?? 0,
    );
  }

  static List<CommentEntity> list(List<CommentModel> comments) => [
    for (final comment in comments) ?fromModel(comment),
  ];

  /// The comments that can be shown, and the cursor only when all three parts of it are set.
  static CommentPageEntity page(CommentPageModel page) {
    final rank = page.nextRank;
    final created = page.nextCreated;
    final id = page.nextId;
    return CommentPageEntity(
      comments: list(page.comments),
      nextCursor: rank == null || created == null || id == null
          ? null
          : CommentCursorEntity(rank: rank, createdAt: created, id: id),
    );
  }
}
