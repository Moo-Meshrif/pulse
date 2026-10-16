import '../../../../core/utils/equatable.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../data/enums/media_type.dart';
import '../../data/model/post_media_model.dart';

/// A photo or video picked for a new post, already resized and measured.
class NewPostMediaEntity extends Equatable {
  /// The file on this device.
  final String filePath;
  final bool isVideo;
  final int width;
  final int height;

  /// Videos only.
  final int? durationMs;
  final String? blurhash;

  const NewPostMediaEntity({
    required this.filePath,
    required this.isVideo,
    required this.width,
    required this.height,
    this.durationMs,
    this.blurhash,
  });

  MediaToSend toSend() => MediaToSend(
    filePath: filePath,
    isVideo: isVideo,
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
    filePath,
    isVideo,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
