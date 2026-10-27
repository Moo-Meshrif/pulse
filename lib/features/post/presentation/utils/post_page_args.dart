import 'feed_post.dart';

/// What opens the post page: the post id, the post already loaded (shown at once, then refreshed), the
/// comment a notification points at, and whether the field takes the cursor.
class PostPageArgs {
  const PostPageArgs({
    required this.postId,
    this.post,
    this.focusCommentId,
    this.focusComposer = false,
  });

  final String postId;
  final FeedPost? post;
  final String? focusCommentId;
  final bool focusComposer;
}
