import 'package:flutter/foundation.dart' show VoidCallback;

/// What the card tells its list. A callback is null while its feature does not exist yet; the control is
/// still drawn.
class PostCardCallbacks {
  const PostCardCallbacks({
    this.onProfile,
    this.onOptions,
    this.onLike,
    this.onDoubleTapLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onOptions;
  final VoidCallback? onLike;

  /// Like only, never unlike: the card calls it when the post is not liked yet.
  final VoidCallback? onDoubleTapLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
}
