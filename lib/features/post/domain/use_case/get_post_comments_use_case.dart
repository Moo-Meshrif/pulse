import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../data/datasource/comments_datasource.dart';
import '../../data/datasource/comments_local_datasource.dart';
import '../../data/enums/comment_sort.dart';
import '../entity/comment_cursor_entity.dart';
import '../entity/comment_page_entity.dart';
import '../mapper/comment_entity_mapper.dart';

/// A page of [postId]'s top-level comments with their first replies. Pass the previous page's
/// `nextCursor` as [before] for the next one. [focusCommentId] puts that comment (or its thread) first on
/// the first page; pass it on every page. Throws a `Failure` on error. A first page without a focus
/// comment is also saved on the device for [userId], and [saved] gives it back.
@injectable
class GetPostCommentsUseCase {
  GetPostCommentsUseCase(this._comments, this._local);

  final CommentsDatasource _comments;
  final CommentsLocalDatasource _local;

  static const pageSize = 20;

  /// The first page saved for [postId] in [sort]; null when there is none.
  CommentPageEntity? saved(String userId, String postId, CommentSort sort) {
    final page = _local.read(userId, postId, sort);
    return page == null ? null : CommentEntityMapper.page(page);
  }

  Future<CommentPageEntity> call(
    String postId, {
    required CommentSort sort,
    String? userId,
    CommentCursorEntity? before,
    String? focusCommentId,
  }) async {
    final page = await _comments.getComments(
      postId,
      sort: sort,
      limit: pageSize,
      beforeRank: before?.rank,
      beforeCreated: before?.createdAt,
      beforeId: before?.id,
      focusCommentId: focusCommentId,
    );
    if (userId != null && before == null && focusCommentId == null) {
      unawaited(_local.write(userId, postId, sort, page));
    }
    return CommentEntityMapper.page(page);
  }
}
