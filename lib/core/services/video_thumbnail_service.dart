import 'dart:typed_data';

import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:injectable/injectable.dart';

import '../error/failures.dart';

/// A poster frame for a video file.
abstract interface class VideoThumbnailService {
  /// Writes a JPEG of the video's first frame and returns its path. Throws [UnexpectedFailure] when none
  /// can be made.
  Future<String> thumbnail(String videoPath);

  /// A small JPEG of the frame at [timeMs], for a strip of the video. Throws [UnexpectedFailure] when none
  /// can be made.
  Future<Uint8List> frameAt(String videoPath, {required int timeMs});
}

/// [VideoThumbnailService] over `flutter_video_thumbnail_plus`.
@LazySingleton(as: VideoThumbnailService)
final class PackageVideoThumbnailService implements VideoThumbnailService {
  static const _quality = 80;
  static const _maxHeight = 1280;
  static const _stripHeight = 160;

  @override
  Future<String> thumbnail(String videoPath) async {
    try {
      final path = await FlutterVideoThumbnailPlus.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.jpeg,
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

  @override
  Future<Uint8List> frameAt(String videoPath, {required int timeMs}) async {
    try {
      final bytes = await FlutterVideoThumbnailPlus.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.jpeg,
        maxHeight: _stripHeight,
        timeMs: timeMs,
        quality: _quality,
      );
      if (bytes == null) throw const UnexpectedFailure();
      return bytes;
    } on Failure {
      rethrow;
    } on Object {
      throw const UnexpectedFailure();
    }
  }
}
