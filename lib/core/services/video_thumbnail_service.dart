import 'package:injectable/injectable.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../error/failures.dart';

/// A poster frame for a video file.
abstract interface class VideoThumbnailService {
  /// Writes a JPEG of the video's first frame and returns its path. Throws [UnexpectedFailure] when none
  /// can be made.
  Future<String> thumbnail(String videoPath);
}

/// [VideoThumbnailService] over `video_thumbnail`.
@LazySingleton(as: VideoThumbnailService)
final class PackageVideoThumbnailService implements VideoThumbnailService {
  static const _quality = 80;
  static const _maxHeight = 1280;

  @override
  Future<String> thumbnail(String videoPath) async {
    try {
      final path = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxHeight: _maxHeight,
        quality: _quality,
      );
      if (path == null) throw const UnexpectedFailure();
      return path;
    } on Failure {
      rethrow;
    } on Object {
      throw const UnexpectedFailure();
    }
  }
}
