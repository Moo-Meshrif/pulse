import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../../../../shared/content/data/enums/content_audience.dart';
import '../enums/mood_kind.dart';
import 'post_media_model.dart';
import 'post_tag_model.dart';

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
  final MoodKind? moodKind;
  final String? moodKey;
  final String? moodText;
  final int? tagCount;

  /// Everyone tagged, in tag order (at most 20).
  final List<PostTagModel>? tags;
  final bool? iAmTagged;

  /// True for a post that shares another post; it has no media of its own.
  final bool? isShare;
  final String? sharedPostId;

  /// The original of a share (feed columns only, no counts); null when it was deleted or you can't see it.
  final PostModel? sharedPost;

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
    this.moodKind,
    this.moodKey,
    this.moodText,
    this.tagCount,
    this.tags,
    this.iAmTagged,
    this.isShare,
    this.sharedPostId,
    this.sharedPost,
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
    moodKind: MoodKind.fromWire(JsonMapper.string(json['mood_kind'])),
    moodKey: JsonMapper.string(json['mood_key']),
    moodText: JsonMapper.string(json['mood_text']),
    tagCount: JsonMapper.integer(json['tag_count']),
    tags: JsonMapper.list(
      json['tags'],
      (item) =>
          item is Map<String, dynamic> ? PostTagModel.fromJson(item) : null,
    ),
    iAmTagged: JsonMapper.boolean(json['i_am_tagged']),
    isShare: JsonMapper.boolean(json['is_share']),
    sharedPostId: JsonMapper.string(json['shared_post_id']),
    sharedPost: json['shared_post'] is Map<String, dynamic>
        ? PostModel.fromJson(json['shared_post'] as Map<String, dynamic>)
        : null,
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
    moodKind,
    moodKey,
    moodText,
    tagCount,
    tags,
    iAmTagged,
    isShare,
    sharedPostId,
    sharedPost,
  ];
}
