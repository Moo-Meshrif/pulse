import '../../../../core/utils/equatable.dart';
import '../../../../core/utils/json_mapper.dart';
import '../enums/media_type.dart';

/// One photo or video of a post: an item of `home_feed().media`, and of `create_post`'s `p_media`.
class PostMediaModel extends Equatable {
  final int? position;
  final MediaType? type;

  /// Object path in the private `post-media` bucket.
  final String? path;

  /// Poster frame of a video.
  final String? thumbPath;
  final int? width;
  final int? height;

  /// Videos only.
  final int? durationMs;
  final String? blurhash;

  const PostMediaModel({
    this.position,
    this.type,
    this.path,
    this.thumbPath,
    this.width,
    this.height,
    this.durationMs,
    this.blurhash,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) => PostMediaModel(
    position: JsonMapper.integer(json['position']),
    type: MediaType.fromWire(JsonMapper.string(json['type'])),
    path: JsonMapper.string(json['path']),
    thumbPath: JsonMapper.string(json['thumb_path']),
    width: JsonMapper.integer(json['width']),
    height: JsonMapper.integer(json['height']),
    durationMs: JsonMapper.integer(json['duration_ms']),
    blurhash: JsonMapper.string(json['blurhash']),
  );

  /// An item of `create_post`'s `p_media`; the server takes the position from the order.
  Map<String, dynamic> toJson() => {
    'type': type?.wire,
    'path': path,
    'thumb_path': thumbPath,
    'width': width,
    'height': height,
    'duration_ms': durationMs,
    'blurhash': blurhash,
  };

  @override
  List<Object?> get props => [
    position,
    type,
    path,
    thumbPath,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
