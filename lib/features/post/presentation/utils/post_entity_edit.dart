import '../../../../shared/content/data/enums/content_audience.dart';
import '../../../post/domain/entity/post_entity.dart';

/// The fields of a post that Home changes in place after an action.
extension PostEntityEdit on PostEntity {
  PostEntity copyWith({
    int? likeCount,
    bool? likedByMe,
    bool? savedByMe,
    bool? commentsEnabled,
    ContentAudience? visibility,
    bool? iAmTagged,
  }) => PostEntity(
    id: id,
    authorId: authorId,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    caption: caption,
    location: location,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount,
    commentsEnabled: commentsEnabled ?? this.commentsEnabled,
    visibility: visibility ?? this.visibility,
    createdAt: createdAt,
    likedByMe: likedByMe ?? this.likedByMe,
    savedByMe: savedByMe ?? this.savedByMe,
    media: media,
    mood: mood,
    tags: tags,
    tagCount: tagCount,
    iAmTagged: iAmTagged ?? this.iAmTagged,
    isShare: isShare,
    original: original,
  );

  /// A share whose original was deleted: it shows as unavailable.
  PostEntity withoutOriginal() => PostEntity(
    id: id,
    authorId: authorId,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    caption: caption,
    location: location,
    likeCount: likeCount,
    commentCount: commentCount,
    commentsEnabled: commentsEnabled,
    visibility: visibility,
    createdAt: createdAt,
    likedByMe: likedByMe,
    savedByMe: savedByMe,
    media: media,
    mood: mood,
    tags: tags,
    tagCount: tagCount,
    iAmTagged: iAmTagged,
    isShare: isShare,
  );

  /// The post without [userId]'s tag: they removed it.
  PostEntity withoutTag(String userId) => PostEntity(
    id: id,
    authorId: authorId,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    caption: caption,
    location: location,
    likeCount: likeCount,
    commentCount: commentCount,
    commentsEnabled: commentsEnabled,
    visibility: visibility,
    createdAt: createdAt,
    likedByMe: likedByMe,
    savedByMe: savedByMe,
    media: media,
    mood: mood,
    tags: [
      for (final tag in tags)
        if (tag.userId != userId) tag,
    ],
    tagCount: tagCount > 0 ? tagCount - 1 : 0,
    iAmTagged: false,
    isShare: isShare,
    original: original,
  );
}
