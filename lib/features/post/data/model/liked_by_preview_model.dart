import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// The row of `liked_by_preview()` (or one row of `liked_by_previews()`): the person named in "Liked by", how many others, and up to two avatars.
class LikedByPreviewModel extends Equatable {
  /// The post the row is for; only `liked_by_previews()` sends it.
  final String? postId;
  final String? firstId;
  final String? firstUsername;
  final String? firstFullName;
  final int? others;
  final List<LikedByAvatarModel>? avatars;

  /// The signed-in user is the only person who liked the post.
  final bool? onlyMe;

  const LikedByPreviewModel({
    this.postId,
    this.firstId,
    this.firstUsername,
    this.firstFullName,
    this.others,
    this.avatars,
    this.onlyMe,
  });

  factory LikedByPreviewModel.fromJson(Map<String, dynamic> json) =>
      LikedByPreviewModel(
        postId: JsonMapper.string(json['post_id']),
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
    postId,
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
