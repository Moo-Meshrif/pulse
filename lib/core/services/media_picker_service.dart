import 'dart:io';
import 'dart:ui' as ui;

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/painting.dart' show FileImage;
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:video_player/video_player.dart';

import '../enums/image_resize_preset.dart';
import '../utils/equatable.dart';

/// A photo or video chosen from the library. [durationMs] is set for a video; [blurhash] for a photo
/// picked with [MediaPickerService.pickMany].
class PickedMedia extends Equatable {
  const PickedMedia({
    required this.path,
    required this.isVideo,
    this.durationMs,
    this.width,
    this.height,
    this.sizeBytes,
    this.blurhash,
  });

  final String path;
  final bool isVideo;
  final int? durationMs;
  final int? width;
  final int? height;
  final int? sizeBytes;
  final String? blurhash;

  @override
  List<Object?> get props => [
    path,
    isVideo,
    durationMs,
    width,
    height,
    sizeBytes,
    blurhash,
  ];
}

/// The photo library for photos and videos together. Returns null when the person cancels or the picker
/// fails, so callers handle "got one" or "did not". The library needs no camera or microphone permission.
abstract interface class MediaPickerService {
  Future<PickedMedia?> pick();

  /// Up to [limit] photos and videos at once. Photos come back shrunk to [preset] with their size and
  /// blurhash; videos with their length, size and file size. Empty when the person cancels or it fails.
  Future<List<PickedMedia>> pickMany({
    required int limit,
    ImageResizePreset preset = ImageResizePreset.active,
  });
}

/// [MediaPickerService] over `image_picker`; a video's length and size are read with `video_player`.
@LazySingleton(as: MediaPickerService)
final class ImagePickerMediaPickerService implements MediaPickerService {
  static const _blurhashTimeout = Duration(seconds: 3);

  ImagePickerMediaPickerService() : _picker = ImagePicker();

  @visibleForTesting
  ImagePickerMediaPickerService.withPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<PickedMedia?> pick() async {
    try {
      final file = await _picker.pickMedia();
      if (file == null) return null;
      return _isVideo(file) ? await _video(file.path) : await _image(file.path);
    } on Object {
      return null;
    }
  }

  @override
  Future<List<PickedMedia>> pickMany({
    required int limit,
    ImageResizePreset preset = ImageResizePreset.active,
  }) async {
    try {
      final files = await _picker.pickMultipleMedia(
        limit: limit,
        maxWidth: preset.maxSide.toDouble(),
        maxHeight: preset.maxSide.toDouble(),
        imageQuality: preset.quality,
      );
      return [
        for (final file in files.take(limit))
          _isVideo(file) ? await _video(file.path) : await _photo(file.path),
      ];
    } on Object {
      return const [];
    }
  }

  bool _isVideo(XFile file) =>
      (file.mimeType ?? '').startsWith('video/') ||
      const [
        '.mp4',
        '.mov',
        '.m4v',
        '.webm',
        '.3gp',
      ].any(file.path.toLowerCase().endsWith);

  Future<PickedMedia> _photo(String path) async {
    final media = await _image(path);
    return PickedMedia(
      path: path,
      isVideo: false,
      width: media.width,
      height: media.height,
      sizeBytes: await File(path).length(),
      blurhash: await _blurhash(path),
    );
  }

  /// A photo still shares without a placeholder when the hash cannot be made in time.
  Future<String?> _blurhash(String path) async {
    try {
      return await BlurhashFFI.encode(FileImage(File(path)))
          .timeout(_blurhashTimeout);
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
        sizeBytes: await File(path).length(),
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
