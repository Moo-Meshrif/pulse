import '../../../../core/utils/equatable.dart';
import 'feed_cursor_entity.dart';
import 'post_entity.dart';

/// One page of the home feed. [nextCursor] is null on the last page.
class FeedPageEntity extends Equatable {
  final List<PostEntity> posts;
  final FeedCursorEntity? nextCursor;

  const FeedPageEntity({required this.posts, this.nextCursor});

  @override
  List<Object?> get props => [posts, nextCursor];
}
