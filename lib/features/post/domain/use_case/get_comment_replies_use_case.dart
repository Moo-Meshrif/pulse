import 'package:injectable/injectable.dart';

import '../../data/datasource/comments_datasource.dart';
import '../entity/comment_entity.dart';
import '../mapper/comment_entity_mapper.dart';

/// The replies of a top-level comment after [after] (the last reply you have; none = from the start),
/// oldest first. Fewer than [pageSize] means the thread is complete. Throws a `Failure` on error.
@injectable
class GetCommentRepliesUseCase {
  GetCommentRepliesUseCase(this._comments);

  final CommentsDatasource _comments;

  static const pageSize = 20;

  Future<List<CommentEntity>> call(
    String commentId, {
    CommentEntity? after,
  }) async => CommentEntityMapper.list(
    await _comments.getReplies(
      commentId,
      limit: pageSize,
      afterCreated: after?.createdAt,
      afterId: after?.id,
    ),
  );
}
