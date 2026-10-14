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

  const PostOptionsData({
    required this.postId,
    required this.isMine,
    required this.username,
    this.isSaved = false,
    this.commentsEnabled = true,
    this.visibility = ContentAudience.public,
  });

  /// Copy link and Share only exist for a public post.
  bool get isPublic => visibility == ContentAudience.public;

  @override
  List<Object?> get props => [
    postId,
    isMine,
    username,
    isSaved,
    commentsEnabled,
    visibility,
  ];
}
