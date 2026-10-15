import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/follow_state.dart';

/// A row of `post_tagged_people()`: someone tagged on a post and how you stand with them.
class TaggedPersonModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final FollowState? followState;

  const TaggedPersonModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.followState,
  });

  factory TaggedPersonModel.fromJson(Map<String, dynamic> json) =>
      TaggedPersonModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        followState: FollowState.fromWire(
          JsonMapper.string(json['follow_state']),
        ),
      );

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, followState];
}
