import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasource/comments_datasource.dart';
import '../entity/comment_entity.dart';
import '../mapper/comment_entity_mapper.dart';

/// Changes the words of your own comment and returns it as saved. Throws a `Failure` on error.
@injectable
class EditCommentUseCase {
  EditCommentUseCase(this._comments);

  final CommentsDatasource _comments;

  Future<CommentEntity> call(String commentId, String body) async {
    final comment = await _comments.editComment(commentId, body);
    return CommentEntityMapper.fromModel(comment) ??
        (throw const ParseFailure());
  }
}
