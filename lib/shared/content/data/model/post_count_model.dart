import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// The current counts of one post (or short), from `post_counts`.
class PostCountModel extends Equatable {
  final String? id;
  final int? likeCount;
  final int? commentCount;
  final bool? likedByMe;

  const PostCountModel({
    this.id,
    this.likeCount,
    this.commentCount,
    this.likedByMe,
  });

  factory PostCountModel.fromJson(Map<String, dynamic> json) => PostCountModel(
    id: JsonMapper.string(json['id']),
    likeCount: JsonMapper.integer(json['like_count']),
    commentCount: JsonMapper.integer(json['comment_count']),
    likedByMe: JsonMapper.boolean(json['liked_by_me']),
  );

  @override
  List<Object?> get props => [id, likeCount, commentCount, likedByMe];
}
