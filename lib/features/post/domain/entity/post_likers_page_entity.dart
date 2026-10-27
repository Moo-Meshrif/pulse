import '../../../../core/utils/equatable.dart';
import 'post_liker_entity.dart';
import 'post_likers_cursor_entity.dart';

/// One page of a post's likers. [total] is how many people the signed-in user may see on the post;
/// [nextCursor] is null on the last page.
class PostLikersPageEntity extends Equatable {
  final List<PostLikerEntity> likers;
  final int? total;
  final PostLikersCursorEntity? nextCursor;

  const PostLikersPageEntity({
    required this.likers,
    this.total,
    this.nextCursor,
  });

  @override
  List<Object?> get props => [likers, total, nextCursor];
}
