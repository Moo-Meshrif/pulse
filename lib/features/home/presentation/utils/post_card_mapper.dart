import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../post/domain/entity/post_entity.dart';
import '../../../post/presentation/utils/content_audience_display.dart';
import '../../../post/presentation/utils/post_card_data.dart';
import '../../../post/presentation/utils/post_card_media.dart';
import '../../../post/presentation/utils/post_options_data.dart';
import '../../../post/presentation/utils/share_access_of.dart';

/// What the card draws for [post]: the name people know them by, the place, the small audience icon, the
/// feeling and the tagged people. [userId] is the signed-in user, so their own post reads "You".
PostCardData postCardData(
  PostEntity post,
  List<PostCardMedia> media, {
  String? userId,
  List<PostCardMedia> originalMedia = const [],
}) {
  final original = post.original;
  final fullName = post.fullName?.trim();
  return PostCardData(
    id: post.id,
    authorId: post.authorId,
    authorName: fullName == null || fullName.isEmpty ? post.username : fullName,
    authorAvatarUrl: post.avatarUrl,
    city: post.location,
    createdAt: post.createdAt,
    caption: post.caption,
    media: media,
    likeCount: post.likeCount,
    commentCount: post.commentCount,
    isLiked: post.likedByMe,
    isSaved: post.savedByMe,
    audienceIcon: post.visibility.icon,
    isOnlyMe: post.visibility == ContentAudience.onlyMe,
    isMine: post.authorId == userId,
    viewerId: userId,
    commentsEnabled: post.commentsEnabled,
    mood: post.mood,
    tags: post.tags,
    tagCount: post.tagCount,
    isShare: post.isShare,
    canShare: shareAccessOf(post, userId: userId).isShown,
    original: original == null
        ? null
        : postCardData(original, originalMedia, userId: userId),
  );
}

/// What the options sheet needs: whose post it is and what is set on it.
PostOptionsData postOptionsData(PostEntity post, {required String? userId}) =>
    PostOptionsData(
      postId: post.id,
      isMine: post.authorId == userId,
      username: post.username,
      isSaved: post.savedByMe,
      commentsEnabled: post.commentsEnabled,
      visibility: post.visibility,
      iAmTagged: post.iAmTagged && post.authorId != userId,
      isShare: post.isShare,
      shareAccessOverride: post.isShare
          ? shareAccessOf(post, userId: userId)
          : null,
    );
