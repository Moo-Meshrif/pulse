import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// The row of `liked_by_preview()`: the person named in "Liked by", how many others, and up to two avatars.
class LikedByPreviewModel extends Equatable {
  final String? firstId;
  final String? firstUsername;
  final String? firstFullName;
  final int? others;
  final List<LikedByAvatarModel>? avatars;

  /// The signed-in user is the only person who liked the post.
  final bool? onlyMe;

  const LikedByPreviewModel({
    this.firstId,
    this.firstUsername,
    this.firstFullName,
    this.others,
    this.avatars,
    this.onlyMe,
  });

  factory LikedByPreviewModel.fromJson(Map<String, dynamic> json) =>
      LikedByPreviewModel(
        firstId: JsonMapper.string(json['first_id']),
        firstUsername: JsonMapper.string(json['first_username']),
        firstFullName: JsonMapper.string(json['first_full_name']),
        others: JsonMapper.integer(json['others']),
        avatars: JsonMapper.list(
          json['avatars'],
          (item) => item is Map<String, dynamic>
              ? LikedByAvatarModel.fromJson(item)
              : null,
        ),
        onlyMe: JsonMapper.boolean(json['only_me']),
      );

  @override
  List<Object?> get props => [
    firstId,
    firstUsername,
    firstFullName,
    others,
    avatars,
    onlyMe,
  ];
}

/// One avatar of the "Liked by" row.
class LikedByAvatarModel extends Equatable {
  final String? id;
  final String? name;
  final String? avatarUrl;

  const LikedByAvatarModel({this.id, this.name, this.avatarUrl});

  factory LikedByAvatarModel.fromJson(Map<String, dynamic> json) =>
      LikedByAvatarModel(
        id: JsonMapper.string(json['id']),
        name: JsonMapper.string(json['name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
      );

  @override
  List<Object?> get props => [id, name, avatarUrl];
}
