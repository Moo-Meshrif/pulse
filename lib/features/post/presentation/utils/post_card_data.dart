import '../../../../core/utils/equatable.dart';
import '../../domain/entity/post_mood_entity.dart';
import '../../domain/entity/post_tag_entity.dart';
import 'post_card_media.dart';

/// What [PostCard] draws about a post: plain values with the media links already signed.
class PostCardData extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;

  /// The place the author added; null or empty when none.
  final String? city;
  final DateTime createdAt;
  final String? caption;
  final List<PostCardMedia> media;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;

  /// The small icon after the time for a post that is not public (users, star, lock); null for a public one.
  final String? audienceIcon;

  /// True for an Only me post: nobody else sees it, so its action bar has only Save.
  final bool isOnlyMe;

  /// The post is the signed-in user's: the headline says "You".
  final bool isMine;
  final bool commentsEnabled;
  final PostMoodEntity? mood;

  /// The first people tagged (names for the headline); [tagCount] is how many in all.
  final List<PostTagEntity> tags;
  final int tagCount;

  /// The signed-in user, so their own tag on a photo can remove itself.
  final String? viewerId;

  const PostCardData({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatarUrl,
    this.city,
    required this.createdAt,
    this.caption,
    this.media = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.audienceIcon,
    this.isOnlyMe = false,
    this.isMine = false,
    this.commentsEnabled = true,
    this.mood,
    this.tags = const [],
    this.tagCount = 0,
    this.viewerId,
  });

  @override
  List<Object?> get props => [
    id,
    authorId,
    authorName,
    authorAvatarUrl,
    city,
    createdAt,
    caption,
    media,
    likeCount,
    commentCount,
    isLiked,
    isSaved,
    audienceIcon,
    isOnlyMe,
    isMine,
    commentsEnabled,
    mood,
    tags,
    tagCount,
    viewerId,
  ];
}
