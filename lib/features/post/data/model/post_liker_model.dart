import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `post_likers()`: someone who liked a post, with where the signed-in user's follow of them stands.
class PostLikerModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? likedAt;

  /// `none`, `pending` or `accepted`: the signed-in user's follow of this person.
  final String? followStatus;

  /// This person follows the signed-in user.
  final bool? followsMe;

  /// How many people the signed-in user may see on the post (the same on every row).
  final int? total;

  const PostLikerModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.likedAt,
    this.followStatus,
    this.followsMe,
    this.total,
  });

  factory PostLikerModel.fromJson(Map<String, dynamic> json) => PostLikerModel(
    id: JsonMapper.string(json['id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    likedAt: JsonMapper.date(json['liked_at']),
    followStatus: JsonMapper.string(json['follow_status']),
    followsMe: JsonMapper.boolean(json['follows_me']),
    total: JsonMapper.integer(json['total']),
  );

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    likedAt,
    followStatus,
    followsMe,
    total,
  ];
}
