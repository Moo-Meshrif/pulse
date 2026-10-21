import '../../domain/entity/post_entity.dart';
import 'enums/share_access.dart';

/// The post a send icon shares: the post itself, or the original of a share (null when that is gone).
PostEntity? shareTarget(PostEntity post) => post.isShare ? post.original : post;

/// What the Share sheet offers for [post] to [userId]: a share follows the rules of its original.
ShareAccess shareAccessOf(PostEntity post, {required String? userId}) {
  final target = shareTarget(post);
  if (target == null) return ShareAccess.none;
  return ShareAccess.of(
    visibility: target.visibility,
    isMine: target.authorId == userId,
  );
}
