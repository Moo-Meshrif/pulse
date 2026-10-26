import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A comment or a reply as `post_comments`, `comment_replies`, `add_comment` and `edit_comment` return it.
class CommentModel extends Equatable {
  final String? id;
  final String? postId;

  /// The top-level comment a reply belongs to; null for a top-level comment.
  final String? parentId;
  final String? authorId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? body;
  final DateTime? createdAt;
  final DateTime? editedAt;
  final int? likeCount;
  final bool? likedByMe;
  final bool? isPostAuthor;

  /// The replies you can see (a top-level comment only).
  final int? replyCount;

  /// The first replies that came with a top-level comment.
  final List<CommentModel>? replies;

  /// The comment a link opened; it is first in the page and not part of its paging.
  final bool? isFocus;

  /// The sort position of a top-level row, the first part of the paging cursor.
  final int? rank;

  const CommentModel({
    this.id,
    this.postId,
    this.parentId,
    this.authorId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.body,
    this.createdAt,
    this.editedAt,
    this.likeCount,
    this.likedByMe,
    this.isPostAuthor,
    this.replyCount,
    this.replies,
    this.isFocus,
    this.rank,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
    id: JsonMapper.string(json['id']),
    postId: JsonMapper.string(json['post_id']),
    parentId: JsonMapper.string(json['parent_id']),
    authorId: JsonMapper.string(json['author_id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    body: JsonMapper.string(json['body']),
    createdAt: JsonMapper.date(json['created_at']),
    editedAt: JsonMapper.date(json['edited_at']),
    likeCount: JsonMapper.integer(json['like_count']),
    likedByMe: JsonMapper.boolean(json['liked_by_me']),
    isPostAuthor: JsonMapper.boolean(json['is_post_author']),
    replyCount: JsonMapper.integer(json['reply_count']),
    replies: JsonMapper.list(
      json['replies'],
      (item) =>
          item is Map<String, dynamic> ? CommentModel.fromJson(item) : null,
    ),
    isFocus: JsonMapper.boolean(json['is_focus']),
    rank: JsonMapper.integer(json['rank']),
  );

  /// The copy kept on the device, read back by [CommentModel.fromJson].
  Map<String, dynamic> toJson() => {
    'id': id,
    'post_id': postId,
    'parent_id': parentId,
    'author_id': authorId,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'body': body,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'edited_at': editedAt?.toUtc().toIso8601String(),
    'like_count': likeCount,
    'liked_by_me': likedByMe,
    'is_post_author': isPostAuthor,
    'reply_count': replyCount,
    'replies': replies?.map((reply) => reply.toJson()).toList(),
    'is_focus': isFocus,
    'rank': rank,
  };

  @override
  List<Object?> get props => [
    id,
    postId,
    parentId,
    authorId,
    username,
    fullName,
    avatarUrl,
    body,
    createdAt,
    editedAt,
    likeCount,
    likedByMe,
    isPostAuthor,
    replyCount,
    replies,
    isFocus,
    rank,
  ];
}
