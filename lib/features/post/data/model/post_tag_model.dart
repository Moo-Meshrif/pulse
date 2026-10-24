import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A person tagged on a post: an item of `home_feed().tags`, and of `create_post`'s `p_tags`. A spot
/// ([mediaPosition], [x], [y] in 0..1) is set when the tag sits on one photo.
class PostTagModel extends Equatable {
  final String? userId;
  final String? username;
  final String? fullName;
  final int? mediaPosition;
  final double? x;
  final double? y;

  const PostTagModel({
    this.userId,
    this.username,
    this.fullName,
    this.mediaPosition,
    this.x,
    this.y,
  });

  factory PostTagModel.fromJson(Map<String, dynamic> json) => PostTagModel(
    userId: JsonMapper.string(json['user_id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    mediaPosition: JsonMapper.integer(json['media_position']),
    x: JsonMapper.decimal(json['x']),
    y: JsonMapper.decimal(json['y']),
  );

  /// An item of `p_tags`; the server knows the names.
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'media_position': mediaPosition,
    'x': x,
    'y': y,
  };

  /// Every field, for the copy kept on the device (the item of `home_feed().tags` again).
  Map<String, dynamic> toStoredJson() => {
    ...toJson(),
    'username': username,
    'full_name': fullName,
  };

  @override
  List<Object?> get props => [userId, username, fullName, mediaPosition, x, y];
}
