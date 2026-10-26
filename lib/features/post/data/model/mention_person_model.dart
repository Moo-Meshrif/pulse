import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `comment_mention_candidates()`: someone who can be mentioned in a comment.
class MentionPersonModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;

  const MentionPersonModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory MentionPersonModel.fromJson(Map<String, dynamic> json) =>
      MentionPersonModel(
        id: JsonMapper.string(json['id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
      );

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl];
}
