import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'post_media_entity.dart';

/// A post in a feed, with its author and what you did to it. Public: Home draws the card from it.
class PostEntity extends Equatable {
  final String id;
  final String authorId;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? caption;
  final String? location;
  final int likeCount;
  final int commentCount;
  final bool commentsEnabled;
  final ContentAudience visibility;
  final DateTime createdAt;
  final bool likedByMe;
  final bool savedByMe;
  final List<PostMediaEntity> media;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.caption,
    this.location,
    required this.likeCount,
    required this.commentCount,
    required this.commentsEnabled,
    required this.visibility,
    required this.createdAt,
    required this.likedByMe,
    required this.savedByMe,
    required this.media,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    username,
    fullName,
    avatarUrl,
    caption,
    location,
    likeCount,
    commentCount,
    commentsEnabled,
    visibility,
    createdAt,
    likedByMe,
    savedByMe,
    media,
  ];
}
