import 'package:flutter/foundation.dart' show ValueChanged, VoidCallback;

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
    this.onTaggedPerson,
    this.onTaggedPeople,
    this.onLocation,
    this.onRemoveMyTag,
  });

  final VoidCallback? onProfile;
  final VoidCallback? onOptions;
  final VoidCallback? onLike;

  /// Like only, never unlike: the card calls it when the post is not liked yet.
  final VoidCallback? onDoubleTapLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  /// A tagged person's name in the headline, with their user id.
  final ValueChanged<String>? onTaggedPerson;

  /// "N others" in the headline: the list of everyone tagged.
  final VoidCallback? onTaggedPeople;

  /// The place under the headline.
  final VoidCallback? onLocation;

  /// Your own label on a photo: remove your tag.
  final VoidCallback? onRemoveMyTag;
}
