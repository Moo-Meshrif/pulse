import '../../../../core/utils/equatable.dart';

/// Where the next page of likers starts: the last person of the page before.
class PostLikersCursorEntity extends Equatable {
  final DateTime likedAt;
  final String id;

  const PostLikersCursorEntity({required this.likedAt, required this.id});

  @override
  List<Object?> get props => [likedAt, id];
}
