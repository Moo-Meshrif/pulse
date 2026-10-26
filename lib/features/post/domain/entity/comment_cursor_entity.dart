import '../../../../core/utils/equatable.dart';

/// Where the next page of comments starts: the last top-level comment of the page before.
class CommentCursorEntity extends Equatable {
  final int rank;
  final DateTime createdAt;
  final String id;

  const CommentCursorEntity({
    required this.rank,
    required this.createdAt,
    required this.id,
  });

  @override
  List<Object?> get props => [rank, createdAt, id];
}
