import '../../../../core/utils/equatable.dart';

/// A comment, or a reply to one, with who wrote it and what you did to it.
class CommentEntity extends Equatable {
  final String id;
  final String postId;

  /// The top-level comment a reply belongs to; null for a top-level comment.
  final String? parentId;
  final String authorId;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;
  final int likeCount;
  final bool likedByMe;

  /// Written by the author of the post (shows the "Author" badge).
  final bool isPostAuthor;

  /// How many replies you can see (a top-level comment only).
  final int replyCount;

  /// The first replies that came with a top-level comment.
  final List<CommentEntity> replies;

  /// The comment a link opened: it is first in the list and highlighted.
  final bool isFocus;

  /// The sort position of a top-level row; the first part of the paging cursor.
  final int rank;

  const CommentEntity({
    required this.id,
    required this.postId,
    this.parentId,
    required this.authorId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    required this.body,
    required this.createdAt,
    this.editedAt,
    required this.likeCount,
    required this.likedByMe,
    required this.isPostAuthor,
    required this.replyCount,
    this.replies = const [],
    this.isFocus = false,
    this.rank = 0,
  });

  bool get isReply => parentId != null;
  bool get isEdited => editedAt != null;

  CommentEntity copyWith({
    String? body,
    DateTime? editedAt,
    int? likeCount,
    bool? likedByMe,
    int? replyCount,
    List<CommentEntity>? replies,
  }) => CommentEntity(
    id: id,
    postId: postId,
    parentId: parentId,
    authorId: authorId,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    body: body ?? this.body,
    createdAt: createdAt,
    editedAt: editedAt ?? this.editedAt,
    likeCount: likeCount ?? this.likeCount,
    likedByMe: likedByMe ?? this.likedByMe,
    isPostAuthor: isPostAuthor,
    replyCount: replyCount ?? this.replyCount,
    replies: replies ?? this.replies,
    isFocus: isFocus,
    rank: rank,
  );

  /// The name people know them by: the full name when there is one.
  String get shownName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? username : name;
  }

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
