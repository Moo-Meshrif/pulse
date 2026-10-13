import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../error/failures.dart';

enum CameraLens { back, front }

/// A photo or video the camera produced: where it is, and its size in pixels when known.
class CapturedFile {
  const CapturedFile({required this.path, this.width, this.height});

  final String path;
  final int? width;
  final int? height;
}

/// The device camera for one capture screen: open it on a lens, show [preview], take a photo or record.
/// Every failure to start or capture is a [CameraFailure]. Tests use a fake.
abstract interface class CameraDevice {
  /// Opens [lens]; [withAudio] false records silent videos (the microphone is refused).
  Future<void> open({required CameraLens lens, required bool withAudio});

  Future<void> close();

  /// The open lens has a flash (a front camera has none).
  bool get hasFlash;

  Future<void> setFlash({required bool on});

  Future<CapturedFile> takePhoto();

  Future<void> startRecording();

  /// Ends the recording. With [keep] false the file is deleted and null returned.
  Future<CapturedFile?> stopRecording({bool keep = true});

  /// The live picture, filling its parent cover-fit.
  Widget preview();
}

/// [CameraDevice] over the `camera` package.
@Injectable(as: CameraDevice)
final class PackageCameraDevice implements CameraDevice {
  CameraController? _controller;
  CameraLens _lens = CameraLens.back;

  @override
  Future<void> open({required CameraLens lens, required bool withAudio}) async {
    await close();
    try {
      final cameras = await availableCameras();
      final wanted = lens == CameraLens.front
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final description = cameras.firstWhere(
        (c) => c.lensDirection == wanted,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: withAudio,
      );
      await controller.initialize();
      _controller = controller;
      _lens = lens;
    } on CameraException {
      throw const CameraFailure();
    } on StateError {
      throw const CameraFailure(); // no camera at all
    }
  }

  @override
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  @override
  bool get hasFlash => _lens == CameraLens.back;

  @override
  Future<void> setFlash({required bool on}) async {
    final controller = _controller;
    if (controller == null) return;
    // The torch: it lights at once (the person sees it work) and stays lit for a photo and a video.
    await _guarded(
      () => controller.setFlashMode(on ? FlashMode.torch : FlashMode.off),
    );
  }

  @override
  Future<CapturedFile> takePhoto() async {
    final controller = _requireOpen();
    final file = await _guarded(controller.takePicture);
    final bytes = await File(file.path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final result = CapturedFile(
      path: file.path,
      width: frame.image.width,
      height: frame.image.height,
    );
    frame.image.dispose();
    codec.dispose();
    return result;
  }

  @override
  Future<void> startRecording() async {
    final controller = _requireOpen();
    await _guarded(controller.startVideoRecording);
  }

  @override
  Future<CapturedFile?> stopRecording({bool keep = true}) async {
    final controller = _requireOpen();
    final file = await _guarded(controller.stopVideoRecording);
    if (!keep) {
      final video = File(file.path);
      if (await video.exists()) await video.delete();
      return null;
    }
    final size = controller.value.previewSize;
    // The preview size is reported landscape; the screen is portrait.
    return CapturedFile(
      path: file.path,
      width: size?.height.round(),
      height: size?.width.round(),
    );
  }

  @override
  Widget preview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    final size = controller.value.previewSize!;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.height,
          height: size.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  CameraController _requireOpen() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraFailure();
    }
    return controller;
  }

  Future<T> _guarded<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on CameraException {
      throw const CameraFailure();
    }
  }
}
