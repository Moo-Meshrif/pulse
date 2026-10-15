import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `tag_search()`: a person you can look up to tag. [canTag] is false when their settings
/// do not let you tag them.
class TagPersonModel extends Equatable {
  final String? id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool? canTag;

  const TagPersonModel({
    this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.canTag,
  });

  factory TagPersonModel.fromJson(Map<String, dynamic> json) => TagPersonModel(
    id: JsonMapper.string(json['id']),
    username: JsonMapper.string(json['username']),
    fullName: JsonMapper.string(json['full_name']),
    avatarUrl: JsonMapper.string(json['avatar_url']),
    canTag: JsonMapper.boolean(json['can_tag']),
  );

  @override
  List<Object?> get props => [id, username, fullName, avatarUrl, canTag];
}
