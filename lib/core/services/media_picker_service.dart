import 'dart:io';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

import '../utils/equatable.dart';

/// A photo or video chosen from the library. [durationMs] is set for a video.
class PickedMedia extends Equatable {
  const PickedMedia({
    required this.path,
    required this.isVideo,
    this.durationMs,
    this.width,
    this.height,
  });

  final String path;
  final bool isVideo;
  final int? durationMs;
  final int? width;
  final int? height;

  @override
  List<Object?> get props => [path, isVideo, durationMs, width, height];
}

/// The photo library for photos and videos together. Returns null when the person cancels or the picker
/// fails, so callers handle "got one" or "did not". The library needs no camera or microphone permission.
abstract interface class MediaPickerService {
  Future<PickedMedia?> pick();
}

/// [MediaPickerService] over `image_picker`; a video's length and size are read with `video_player`.
@LazySingleton(as: MediaPickerService)
final class ImagePickerMediaPickerService implements MediaPickerService {
  final _picker = ImagePicker();

  @override
  Future<PickedMedia?> pick() async {
    try {
      final file = await _picker.pickMedia();
      if (file == null) return null;
      final mime = file.mimeType ?? '';
      final isVideo =
          mime.startsWith('video/') ||
          const [
            '.mp4',
            '.mov',
            '.m4v',
            '.webm',
            '.3gp',
          ].any(file.path.toLowerCase().endsWith);
      return isVideo ? await _video(file.path) : await _image(file.path);
    } on Object {
      return null;
    }
  }

  Future<PickedMedia> _video(String path) async {
    final controller = VideoPlayerController.file(File(path));
    try {
      await controller.initialize();
      final value = controller.value;
      return PickedMedia(
        path: path,
        isVideo: true,
        durationMs: value.duration.inMilliseconds,
        width: value.size.width.round(),
        height: value.size.height.round(),
      );
    } finally {
      await controller.dispose();
    }
  }

  Future<PickedMedia> _image(String path) async {
    final codec = await ui.instantiateImageCodec(
      await File(path).readAsBytes(),
    );
    final frame = await codec.getNextFrame();
    final media = PickedMedia(
      path: path,
      isVideo: false,
      width: frame.image.width,
      height: frame.image.height,
    );
    frame.image.dispose();
    codec.dispose();
    return media;
  }
}
