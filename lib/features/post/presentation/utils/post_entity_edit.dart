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
  );
}
