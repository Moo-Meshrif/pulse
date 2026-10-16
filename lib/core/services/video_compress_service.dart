import 'dart:async';

import 'package:flutter_compress/flutter_compress.dart';
import 'package:injectable/injectable.dart';

import '../error/failures.dart';
import '../utils/equatable.dart';

/// A video after [VideoCompressService.compress]. [isOriginal] is true when shrinking would not have made
/// it smaller and [path] is the source file itself (never delete it then).
class CompressedVideo extends Equatable {
  const CompressedVideo({
    required this.path,
    required this.sizeBytes,
    required this.durationMs,
    required this.isOriginal,
  });

  final String path;
  final int sizeBytes;
  final int durationMs;
  final bool isOriginal;

  @override
  List<Object?> get props => [path, sizeBytes, durationMs, isOriginal];
}

/// Re-encodes videos on the device with its hardware encoder, one at a time (each one is heavy on CPU,
/// battery and heat).
abstract interface class VideoCompressService {
  /// Writes an H.264 copy of [path] whose longest side is at most [maxLongSide] pixels, at about
  /// [videoBitrate] and [audioBitrate] bits per second. [onProgress] is told how far it is (0..1). Throws
  /// [UnexpectedFailure] when the encode fails.
  Future<CompressedVideo> compress(
    String path, {
    required int maxLongSide,
    required int videoBitrate,
    required int audioBitrate,
    void Function(double progress)? onProgress,
  });

  /// Deletes a copy made by [compress]; a failure is ignored.
  Future<void> delete(String path);

  /// Deletes every copy made by [compress], such as ones left by a send that was dropped.
  Future<void> deleteAll();
}

/// [VideoCompressService] over `flutter_compress` (Media3 Transformer on Android, AVAssetWriter on iOS).
/// Copies are written to the plugin's cache folder.
@LazySingleton(as: VideoCompressService)
final class PackageVideoCompressService implements VideoCompressService {
  static const _bitsPerKilobit = 1000;

  /// Ends the previous encode before the next one starts.
  Future<void> _previous = Future<void>.value();

  FlutterCompress get _api => FlutterCompress.instance;

  @override
  Future<CompressedVideo> compress(
    String path, {
    required int maxLongSide,
    required int videoBitrate,
    required int audioBitrate,
    void Function(double progress)? onProgress,
  }) {
    final done = Completer<void>();
    final previous = _previous;
    _previous = done.future;
    return previous
        .then(
          (_) => _encode(
            path,
            maxLongSide: maxLongSide,
            videoBitrate: videoBitrate,
            audioBitrate: audioBitrate,
            onProgress: onProgress,
          ),
        )
        .whenComplete(done.complete);
  }

  Future<CompressedVideo> _encode(
    String path, {
    required int maxLongSide,
    required int videoBitrate,
    required int audioBitrate,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final result = await _api.compress(
        path,
        VideoCompressConfig(
          videoBitrateKbps: videoBitrate ~/ _bitsPerKilobit,
          audioBitrateKbps: audioBitrate ~/ _bitsPerKilobit,
          // H.264 plays everywhere; the plugin would pick H.265.
          codec: VideoCodec.h264,
          // Both caps at the long side bound it in either orientation; it only scales down.
          maxWidth: maxLongSide,
          maxHeight: maxLongSide,
          container: VideoContainer.mp4,
        ),
        onProgress: onProgress == null ? null : (p) => onProgress(p.progress),
      );
      return CompressedVideo(
        path: result.outputPath,
        sizeBytes: result.compressedSizeBytes,
        durationMs: result.durationMs,
        isOriginal: result.skipped,
      );
    } on Object {
      throw const UnexpectedFailure();
    }
  }

  @override
  Future<void> delete(String path) async {
    try {
      await _api.releaseOutput(path);
    } on Object {
      // A leftover copy is cleared with the cache.
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _api.clearCache();
    } on Object {
      // Nothing to do: the OS may clear the cache too.
    }
  }
}
