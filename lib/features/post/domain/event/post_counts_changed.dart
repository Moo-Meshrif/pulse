import '../../../../core/utils/equatable.dart';

/// A screen other than the feed (the post page) changed a post's likes, comments or save. The feed puts
/// them on its card. Sent on the `EventBus`.
class PostCountsChanged extends Equatable {
  const PostCountsChanged({
    required this.postId,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
    required this.savedByMe,
  });

  final String postId;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final bool savedByMe;

  @override
  List<Object?> get props => [
    postId,
    likeCount,
    commentCount,
    likedByMe,
    savedByMe,
  ];
}
