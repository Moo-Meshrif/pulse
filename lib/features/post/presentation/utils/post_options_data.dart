import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'enums/share_access.dart';

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

  /// The post shares another one.
  final bool isShare;

  /// Set for a share (its original decides); a plain post follows its own audience.
  final ShareAccess? shareAccessOverride;

  const PostOptionsData({
    required this.postId,
    required this.isMine,
    required this.username,
    this.isSaved = false,
    this.commentsEnabled = true,
    this.visibility = ContentAudience.public,
    this.iAmTagged = false,
    this.isShare = false,
    this.shareAccessOverride,
  });

  /// What the Share tile opens; none hides it (docs/specs/post/screens/s12-share-sheet.md).
  ShareAccess get shareAccess =>
      shareAccessOverride ??
      ShareAccess.of(visibility: visibility, isMine: isMine);

  /// Copy link only exists for a public post.
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
    isShare,
    shareAccess,
  ];
}
