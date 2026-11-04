import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';

/// One tile of a profile's post grid (a row of `user_posts` / `saved_posts`): the post and its first
/// picture. [sortAt] and [id] together are the paging cursor.
class ProfileGridItemModel extends Equatable {
  final String? id;
  final String? authorId;
  final DateTime? sortAt;
  final int? mediaCount;

  /// `image` or `video`.
  final String? firstType;
  final String? firstPath;
  final String? firstThumbPath;
  final String? firstBlurhash;

  const ProfileGridItemModel({
    this.id,
    this.authorId,
    this.sortAt,
    this.mediaCount,
    this.firstType,
    this.firstPath,
    this.firstThumbPath,
    this.firstBlurhash,
  });

  factory ProfileGridItemModel.fromJson(Map<String, dynamic> json) =>
      ProfileGridItemModel(
        id: JsonMapper.string(json['id']),
        authorId: JsonMapper.string(json['author_id']),
        sortAt: DateTime.tryParse(JsonMapper.string(json['sort_at']) ?? '')
            ?.toUtc(),
        mediaCount: JsonMapper.integer(json['media_count']),
        firstType: JsonMapper.string(json['first_type']),
        firstPath: JsonMapper.string(json['first_path']),
        firstThumbPath: JsonMapper.string(json['first_thumb_path']),
        firstBlurhash: JsonMapper.string(json['first_blurhash']),
      );

  /// The storage path of the tile's picture: a video's thumbnail, a photo itself.
  String? get thumbPath => firstThumbPath ?? firstPath;

  @override
  List<Object?> get props => [
    id,
    authorId,
    sortAt,
    mediaCount,
    firstType,
    firstPath,
    firstThumbPath,
    firstBlurhash,
  ];
}
