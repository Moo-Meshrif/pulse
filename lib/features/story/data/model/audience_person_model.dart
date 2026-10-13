import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// A row of `audience_people()`: one of your followers, and whether they are on the list being edited.
class AudiencePersonModel extends Equatable {
  final String? userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final bool? selected;

  /// On the other list (Close friends vs Hide story from): a person is on one of them only.
  final bool? isInOtherList;

  const AudiencePersonModel({
    this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.selected,
    this.isInOtherList,
  });

  factory AudiencePersonModel.fromJson(Map<String, dynamic> json) =>
      AudiencePersonModel(
        userId: JsonMapper.string(json['user_id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        selected: JsonMapper.boolean(json['selected']),
        isInOtherList: JsonMapper.boolean(json['in_other_list']),
      );

  @override
  List<Object?> get props => [
    userId,
    username,
    fullName,
    avatarUrl,
    selected,
    isInOtherList,
  ];
}
