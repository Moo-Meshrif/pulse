import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../error/failures.dart';
import '../error/guard.dart';

/// The device's photo library: saving a picture or a video into it.
abstract interface class GalleryService {
  /// Saves an encoded picture (JPEG or PNG bytes). Throws [PermissionFailure] when the library is off
  /// limits.
  Future<void> saveImage(Uint8List bytes);

  /// Downloads the video at [url] and saves it. Throws [PermissionFailure] like [saveImage].
  Future<void> saveVideoFromUrl(String url);

  /// Saves the video file at [path]. Throws [PermissionFailure] like [saveImage].
  Future<void> saveVideoFile(String path);
}

/// [GalleryService] over `gal`.
@LazySingleton(as: GalleryService)
final class GalGalleryService implements GalleryService {
  GalGalleryService(this._http);

  final http.Client _http;

  @override
  Future<void> saveImage(Uint8List bytes) =>
      _guarded(() => Gal.putImageBytes(bytes));

  @override
  Future<void> saveVideoFromUrl(String url) => Guard.run(() async {
    final response = await _http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw ServerFailure(statusCode: response.statusCode);
    }
    final file = File(
      '${Directory.systemTemp.path}/pulse_${DateTime.now().microsecondsSinceEpoch}.mp4',
    );
    await file.writeAsBytes(response.bodyBytes);
    try {
      await _save(() => Gal.putVideo(file.path));
    } finally {
      if (await file.exists()) await file.delete();
    }
  });

  @override
  Future<void> saveVideoFile(String path) => _guarded(() => Gal.putVideo(path));

  Future<void> _guarded(Future<void> Function() save) =>
      Guard.run(() => _save(save));

  Future<void> _save(Future<void> Function() save) async {
    try {
      await save();
    } on GalException catch (error) {
      if (error.type == GalExceptionType.accessDenied) {
        throw const PermissionFailure();
      }
      rethrow;
    }
  }
}
