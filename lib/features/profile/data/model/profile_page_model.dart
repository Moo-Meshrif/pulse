import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of the `profile_by_id` function: what a profile page shows. The wire shape; never phone,
/// birthday or email.
class ProfilePageModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? bio;
  final String? city;
  final String? avatarUrl;
  final String? coverUrl;
  final bool? isVerified;
  final bool? isPrivate;
  final int? postsCount;
  final int? followersCount;
  final int? followingCount;

  /// `none`, `pending` or `accepted`: the caller's follow of this person.
  final String? iFollow;
  final bool? followsMe;
  final bool? canMessage;
  final bool? blockedByMe;

  const ProfilePageModel({
    this.id,
    this.username,
    this.fullName,
    this.bio,
    this.city,
    this.avatarUrl,
    this.coverUrl,
    this.isVerified,
    this.isPrivate,
    this.postsCount,
    this.followersCount,
    this.followingCount,
    this.iFollow,
    this.followsMe,
    this.canMessage,
    this.blockedByMe,
  });

  factory ProfilePageModel.fromJson(Map<String, dynamic> json) =>
      ProfilePageModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        bio: JsonMapper.string(json['bio']),
        city: JsonMapper.string(json['city']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        coverUrl: JsonMapper.string(json['cover_url']),
        isVerified: JsonMapper.boolean(json['is_verified']),
        isPrivate: JsonMapper.boolean(json['is_private']),
        postsCount: JsonMapper.integer(json['posts_count']),
        followersCount: JsonMapper.integer(json['followers_count']),
        followingCount: JsonMapper.integer(json['following_count']),
        iFollow: JsonMapper.string(json['i_follow']),
        followsMe: JsonMapper.boolean(json['follows_me']),
        canMessage: JsonMapper.boolean(json['can_message']),
        blockedByMe: JsonMapper.boolean(json['blocked_by_me']),
      );

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    bio,
    city,
    avatarUrl,
    coverUrl,
    isVerified,
    isPrivate,
    postsCount,
    followersCount,
    followingCount,
    iFollow,
    followsMe,
    canMessage,
    blockedByMe,
  ];
}
