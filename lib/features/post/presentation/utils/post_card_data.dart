import '../../../../core/utils/equatable.dart';
import 'post_card_media.dart';

/// What [PostCard] draws about a post: plain values with the media links already signed.
class PostCardData extends Equatable {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatarUrl;
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
  ];
}
