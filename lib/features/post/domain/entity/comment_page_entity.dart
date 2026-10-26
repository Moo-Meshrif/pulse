import '../../../../core/utils/equatable.dart';
import 'comment_cursor_entity.dart';
import 'comment_entity.dart';

/// One page of a post's top-level comments. [nextCursor] is null on the last page.
class CommentPageEntity extends Equatable {
  final List<CommentEntity> comments;
  final CommentCursorEntity? nextCursor;

  const CommentPageEntity({required this.comments, this.nextCursor});

  @override
  List<Object?> get props => [comments, nextCursor];
}
