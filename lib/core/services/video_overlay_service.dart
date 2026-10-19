import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../error/failures.dart';

/// Draws a transparent picture (stickers, text) over every frame of a video on the device with its
/// hardware encoder, one at a time (each one is heavy on CPU, battery and heat).
abstract interface class VideoOverlayService {
  /// Writes an H.264 copy of the video at [videoPath] with [overlayPng] stretched over the whole frame, and
  /// returns its path. [onProgress] is told how far it is (0..1). Throws [UnexpectedFailure] when it fails.
  Future<String> burn(
    String videoPath,
    Uint8List overlayPng, {
    void Function(double progress)? onProgress,
  });

  /// Deletes a copy made by [burn]; a failure is ignored.
  Future<void> delete(String path);
}

/// [VideoOverlayService] over the app's own `pulse/video_overlay` channel (Media3 Transformer on Android,
/// AVFoundation on iOS). Copies are written to the temporary folder.
@LazySingleton(as: VideoOverlayService)
final class ChannelVideoOverlayService implements VideoOverlayService {
  ChannelVideoOverlayService() {
    _channel.setMethodCallHandler(_onNativeCall);
  }

  static const _channel = MethodChannel('pulse/video_overlay');

  /// Ends the previous job before the next one starts.
  Future<void> _previous = Future<void>.value();

  void Function(double progress)? _onProgress;

  @override
  Future<String> burn(
    String videoPath,
    Uint8List overlayPng, {
    void Function(double progress)? onProgress,
  }) {
    final done = Completer<void>();
    final previous = _previous;
    _previous = done.future;
    return previous
        .then((_) => _run(videoPath, overlayPng, onProgress))
        .whenComplete(done.complete);
  }

  Future<String> _run(
    String videoPath,
    Uint8List overlayPng,
    void Function(double progress)? onProgress,
  ) async {
    _onProgress = onProgress;
    try {
      final output = await _channel.invokeMethod<String>('burn', {
        'videoPath': videoPath,
        'overlayPng': overlayPng,
      });
      if (output == null) throw const UnexpectedFailure();
      return output;
    } on Object {
      throw const UnexpectedFailure();
    } finally {
      _onProgress = null;
    }
  }

  Future<void> _onNativeCall(MethodCall call) async {
    if (call.method == 'progress') {
      _onProgress?.call((call.arguments as num).toDouble().clamp(0.0, 1.0));
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _channel.invokeMethod<void>('delete', {'path': path});
    } on Object {
      // A leftover copy is cleared with the cache.
    }
  }
}
