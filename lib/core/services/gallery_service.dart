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

  /// Downloads the video at [url] into a temporary file and returns its path; the caller deletes it.
  Future<String> downloadVideo(String url);

  /// Saves the video file at [path]. Throws [PermissionFailure] like [saveImage].
  Future<void> saveVideoFile(String path);

  /// Asks for the library now if it was not asked yet, so a long job does not wait for the dialog at its
  /// end. Throws [PermissionFailure] when it is off limits.
  Future<void> ensureAccess();
}

/// [GalleryService] over `gal`.
@LazySingleton(as: GalleryService)
final class GalGalleryService implements GalleryService {
  static const _retryDelay = Duration(milliseconds: 500);

  GalGalleryService(this._http);

  final http.Client _http;

  @override
  Future<void> saveImage(Uint8List bytes) =>
      _guarded(() => Gal.putImageBytes(bytes));

  @override
  Future<void> saveVideoFromUrl(String url) => Guard.run(() async {
    final path = await _download(url);
    try {
      await _save(() => Gal.putVideo(path));
    } finally {
      await _deleteFile(path);
    }
  });

  @override
  Future<String> downloadVideo(String url) => Guard.run(() => _download(url));

  Future<String> _download(String url) async {
    final response = await _http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw ServerFailure(statusCode: response.statusCode);
    }
    final file = File(
      '${Directory.systemTemp.path}/pulse_${DateTime.now().microsecondsSinceEpoch}.mp4',
    );
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> ensureAccess() => _guarded(() async {});

  @override
  Future<void> saveVideoFile(String path) => _guarded(() => Gal.putVideo(path));

  Future<void> _guarded(Future<void> Function() save) =>
      Guard.run(() => _save(save));

  /// Asks for the library first (the first save of a fresh install used to fail while the dialog was up),
  /// and tries once more when a save fails for another reason.
  Future<void> _save(Future<void> Function() save) async {
    try {
      if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
        throw const PermissionFailure();
      }
      try {
        await save();
      } on GalException catch (error) {
        if (error.type == GalExceptionType.accessDenied) rethrow;
        await Future<void>.delayed(_retryDelay);
        await save();
      }
    } on GalException catch (error) {
      if (error.type == GalExceptionType.accessDenied) {
        throw const PermissionFailure();
      }
      rethrow;
    }
  }
}
