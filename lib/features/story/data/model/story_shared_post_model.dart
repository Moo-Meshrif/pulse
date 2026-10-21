import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/story_media_type.dart';

/// The post a story's sticker shows (`author_stories().shared_post`): what the sticker draws, no counts.
class StorySharedPostModel extends Equatable {
  final String? id;
  final String? authorId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? caption;
  final DateTime? createdAt;
  final List<StorySharedPostMediaModel>? media;

  /// A signed link to [pictureKey]'s file; set by the datasource, null if it could not be made.
  final String? pictureUrl;

  const StorySharedPostModel({
    this.id,
    this.authorId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.caption,
    this.createdAt,
    this.media,
    this.pictureUrl,
  });

  factory StorySharedPostModel.fromJson(Map<String, dynamic> json) =>
      StorySharedPostModel(
        id: JsonMapper.string(json['id']),
        authorId: JsonMapper.string(json['author_id']),
        username: JsonMapper.string(json['username']),
        fullName: JsonMapper.string(json['full_name']),
        avatarUrl: JsonMapper.string(json['avatar_url']),
        caption: JsonMapper.string(json['caption']),
        createdAt: JsonMapper.date(json['created_at']),
        media: JsonMapper.list(
          json['media'],
          (item) => item is Map<String, dynamic>
              ? StorySharedPostMediaModel.fromJson(item)
              : null,
        ),
      );

  /// The file the sticker draws: the first photo, or the poster frame of a first video. Null without media.
  String? get pictureKey {
    final first = media?.firstOrNull;
    return first?.type == StoryMediaType.video ? first?.thumbPath : first?.path;
  }

  StorySharedPostModel withPictureUrl(String? url) => StorySharedPostModel(
    id: id,
    authorId: authorId,
    username: username,
    fullName: fullName,
    avatarUrl: avatarUrl,
    caption: caption,
    createdAt: createdAt,
    media: media,
    pictureUrl: url,
  );

  @override
  List<Object?> get props => [
    id,
    authorId,
    username,
    fullName,
    avatarUrl,
    caption,
    createdAt,
    media,
    pictureUrl,
  ];
}

/// A photo or video of [StorySharedPostModel]; a video has a poster frame at [thumbPath].
class StorySharedPostMediaModel extends Equatable {
  final StoryMediaType? type;

  /// Object path in the private `post-media` bucket.
  final String? path;
  final String? thumbPath;
  final int? width;
  final int? height;
  final String? blurhash;

  const StorySharedPostMediaModel({
    this.type,
    this.path,
    this.thumbPath,
    this.width,
    this.height,
    this.blurhash,
  });

  factory StorySharedPostMediaModel.fromJson(Map<String, dynamic> json) =>
      StorySharedPostMediaModel(
        type: StoryMediaType.fromWire(JsonMapper.string(json['type'])),
        path: JsonMapper.string(json['path']),
        thumbPath: JsonMapper.string(json['thumb_path']),
        width: JsonMapper.integer(json['width']),
        height: JsonMapper.integer(json['height']),
        blurhash: JsonMapper.string(json['blurhash']),
      );

  @override
  List<Object?> get props => [type, path, thumbPath, width, height, blurhash];
}
