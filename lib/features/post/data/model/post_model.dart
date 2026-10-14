import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import 'post_media_model.dart';

/// A row of `home_feed()`: a post with its author and what you did to it.
class PostModel extends Equatable {
  final String? id;
  final String? authorId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? caption;
  final String? location;
  final int? likeCount;
  final int? commentCount;
  final bool? commentsEnabled;
  final ContentAudience? visibility;
  final DateTime? createdAt;
  final bool? likedByMe;
  final bool? savedByMe;
  final List<PostMediaModel>? media;

  const PostModel({
    this.id,
    this.authorId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.caption,
    this.location,
    this.likeCount,
    this.commentCount,
    this.commentsEnabled,
    this.visibility,
    this.createdAt,
    this.likedByMe,
    this.savedByMe,
    this.media,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: JsonMapper.string(json['id']),
    authorId: JsonMapper.string(json['author_id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    caption: JsonMapper.string(json['caption']),
    location: JsonMapper.string(json['location']),
    likeCount: JsonMapper.integer(json['like_count']),
    commentCount: JsonMapper.integer(json['comment_count']),
    commentsEnabled: JsonMapper.boolean(json['comments_enabled']),
    visibility: ContentAudience.fromWire(json['visibility']),
    createdAt: JsonMapper.date(json['created_at']),
    likedByMe: JsonMapper.boolean(json['liked_by_me']),
    savedByMe: JsonMapper.boolean(json['saved_by_me']),
    media: JsonMapper.list(
      json['media'],
      (item) =>
          item is Map<String, dynamic> ? PostMediaModel.fromJson(item) : null,
    ),
  );

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
