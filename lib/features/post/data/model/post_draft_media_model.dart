import '../../../../core/utils/json_mapper.dart';

/// One photo or video of a saved draft. [path] and [poster] are full paths on this device when read;
/// they are stored as file names inside the draft's folder.
class PostDraftMediaModel {
  const PostDraftMediaModel({
    this.id,
    this.path,
    this.isVideo,
    this.width,
    this.height,
    this.durationMs,
    this.sizeBytes,
    this.blurhash,
    this.poster,
  });

  /// Names the file on the server.
  final String? id;
  final String? path;
  final bool? isVideo;
  final int? width;
  final int? height;
  final int? durationMs;
  final int? sizeBytes;
  final String? blurhash;

  /// A frame of a video, shown on its tile.
  final String? poster;

  factory PostDraftMediaModel.fromJson(Map<String, dynamic> json) =>
      PostDraftMediaModel(
        id: JsonMapper.string(json['id']),
        path: JsonMapper.string(json['path']),
        isVideo: JsonMapper.boolean(json['is_video']),
        width: JsonMapper.integer(json['width']),
        height: JsonMapper.integer(json['height']),
        durationMs: JsonMapper.integer(json['duration_ms']),
        sizeBytes: JsonMapper.integer(json['size_bytes']),
        blurhash: JsonMapper.string(json['blurhash']),
        poster: JsonMapper.string(json['poster']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'is_video': isVideo,
    'width': width,
    'height': height,
    'duration_ms': durationMs,
    'size_bytes': sizeBytes,
    'blurhash': blurhash,
    'poster': poster,
  };

  PostDraftMediaModel withFiles(String? path, String? poster) =>
      PostDraftMediaModel(
        id: id,
        path: path,
        isVideo: isVideo,
        width: width,
        height: height,
        durationMs: durationMs,
        sizeBytes: sizeBytes,
        blurhash: blurhash,
        poster: poster,
      );
}
