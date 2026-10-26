import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasource/comments_datasource.dart';
import '../entity/comment_entity.dart';
import '../mapper/comment_entity_mapper.dart';

/// Writes a comment on [postId], or a reply when [parentId] is set. The same [clientId] writes once, so a
/// retry is safe. Returns the comment as written. Throws a `Failure`: a [NotFoundFailure] when the post is
/// gone, a [RejectedFailure] when comments are off.
@injectable
class AddCommentUseCase {
  AddCommentUseCase(this._comments);

  final CommentsDatasource _comments;

  Future<CommentEntity> call(
    String postId,
    String body, {
    String? parentId,
    required String clientId,
  }) async {
    final comment = await _comments.addComment(
      postId,
      body,
      parentId: parentId,
      clientId: clientId,
    );
    return CommentEntityMapper.fromModel(comment) ??
        (throw const ParseFailure());
  }
}
