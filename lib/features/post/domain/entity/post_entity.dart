import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'post_media_entity.dart';
import 'post_mood_entity.dart';
import 'post_tag_entity.dart';

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
  final PostMoodEntity? mood;

  /// Everyone tagged, in tag order (at most 20).
  final List<PostTagEntity> tags;

  /// All the people tagged, which can be more than [tags] holds.
  final int tagCount;
  final bool iAmTagged;

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
    this.mood,
    this.tags = const [],
    this.tagCount = 0,
    this.iAmTagged = false,
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
    mood,
    tags,
    tagCount,
    iAmTagged,
  ];
}
