import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';

/// What the options sheet needs to know about the post it was opened from.
class PostOptionsData extends Equatable {
  final String postId;
  final bool isMine;
  final String username;
  final bool isSaved;
  final bool commentsEnabled;
  final ContentAudience visibility;

  /// You are tagged in it and it is not your post: the sheet offers to remove your tag.
  final bool iAmTagged;

  const PostOptionsData({
    required this.postId,
    required this.isMine,
    required this.username,
    this.isSaved = false,
    this.commentsEnabled = true,
    this.visibility = ContentAudience.public,
    this.iAmTagged = false,
  });

  /// Copy link and Share only exist for a public post.
  bool get isPublic => visibility == ContentAudience.public;

  /// Nobody else sees an Only me post, so comments cannot be turned on or off.
  bool get isOnlyMe => visibility == ContentAudience.onlyMe;

  @override
  List<Object?> get props => [
    postId,
    isMine,
    username,
    isSaved,
    commentsEnabled,
    visibility,
    iAmTagged,
  ];
}
