import '../../../../core/utils/equatable.dart';
import '../../../follow/data/enums/follow_status.dart';

/// Someone who liked a post, with where the signed-in user's follow of them stands.
class PostLikerEntity extends Equatable {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime likedAt;
  final FollowStatus follow;

  /// This person follows the signed-in user ("Follow back").
  final bool followsMe;

  const PostLikerEntity({
    required this.id,
    required this.username,
    required this.likedAt,
    required this.follow,
    required this.followsMe,
    this.fullName,
    this.avatarUrl,
  });

  /// The name to show: the full name, else the username.
  String get displayName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? username : name;
  }

  PostLikerEntity withFollow(FollowStatus status) => PostLikerEntity(
    id: id,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    likedAt: likedAt,
    follow: status,
    followsMe: followsMe,
  );

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    likedAt,
    follow,
    followsMe,
  ];
}
