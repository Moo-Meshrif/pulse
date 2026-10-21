import '../../../../core/utils/json_mapper.dart';

/// A person tagged in a saved draft, with their spot on a photo when one was set.
class PostDraftTagModel {
  const PostDraftTagModel({
    this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.mediaPosition,
    this.x,
    this.y,
  });

  final String? userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final int? mediaPosition;
  final double? x;
  final double? y;

  factory PostDraftTagModel.fromJson(Map<String, dynamic> json) =>
      PostDraftTagModel(
        userId: JsonMapper.string(json['user_id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        mediaPosition: JsonMapper.integer(json['media_position']),
        x: JsonMapper.decimal(json['x']),
        y: JsonMapper.decimal(json['y']),
      );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'media_position': mediaPosition,
    'x': x,
    'y': y,
  };
}
