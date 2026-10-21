import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';

/// A photo or video picked for a new post, already resized and measured.
class NewPostMediaEntity extends Equatable {
  /// Names its file on the server, so it stays the same when the media moves; null names it by position.
  final String? id;

  /// The file on this device.
  final String filePath;
  final bool isVideo;

  /// A video's frame on this device, sent as its thumb; null makes one at upload.
  final String? thumbFilePath;
  final int width;
  final int height;

  /// Videos only.
  final int? durationMs;
  final String? blurhash;

  const NewPostMediaEntity({
    this.id,
    required this.filePath,
    required this.isVideo,
    this.thumbFilePath,
    required this.width,
    required this.height,
    this.durationMs,
    this.blurhash,
  });

  MediaToSend toSend() => MediaToSend(
    filePath: filePath,
    isVideo: isVideo,
    thumbFilePath: thumbFilePath,
    width: width,
    height: height,
    durationMs: durationMs,
  );

  /// This file as the media of the post, once it is at [sent].
  PostMediaModel toModel(SentMedia sent) => PostMediaModel(
    type: isVideo ? MediaType.video : MediaType.image,
    path: sent.path,
    thumbPath: sent.thumbPath,
    width: width,
    height: height,
    durationMs: durationMs,
    blurhash: blurhash,
  );

  @override
  List<Object?> get props => [
    id,
    filePath,
    isVideo,
    thumbFilePath,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
