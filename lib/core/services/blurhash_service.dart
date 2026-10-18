import 'dart:io';

import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/painting.dart' show FileImage, ResizeImage;
import 'package:injectable/injectable.dart';

/// The blurhash of a picture file, shown while the picture loads.
abstract interface class BlurhashService {
  /// The hash of the picture at [path], or null when it cannot be made in time: a picture still shares
  /// without a placeholder.
  Future<String?> blurhash(String path);
}

/// [BlurhashService] over `blurhash_ffi`.
@LazySingleton(as: BlurhashService)
final class PackageBlurhashService implements BlurhashService {
  static const _timeout = Duration(seconds: 3);

  /// A blurhash is a few colour blobs, so it is made from a small copy of the photo.
  static const _side = 64;

  @override
  Future<String?> blurhash(String path) async {
    try {
      return await BlurhashFFI.encode(
        ResizeImage(FileImage(File(path)), width: _side),
      ).timeout(_timeout);
    } on Object {
      return null;
    }
  }
}
