import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../enums/photo_source.dart';
import '../utils/equatable.dart';

/// A picture the user chose: its bytes and MIME type, ready to upload.
class PickedPhoto extends Equatable {
  const PickedPhoto({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;

  @override
  List<Object?> get props => [bytes, contentType];
}

/// The camera and the photo library. Returns null when the user cancels or refuses the permission, so
/// callers only handle "got a picture" or "did not".
abstract interface class PhotoPickerService {
  Future<PickedPhoto?> pick(PhotoSource source);
}

/// [PhotoPickerService] over `image_picker`.
@LazySingleton(as: PhotoPickerService)
final class ImagePickerPhotoPickerService implements PhotoPickerService {
  static const _maxSide = 1024.0;
  static const _quality = 85;

  final _picker = ImagePicker();

  @override
  Future<PickedPhoto?> pick(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: switch (source) {
          PhotoSource.camera => ImageSource.camera,
          PhotoSource.gallery => ImageSource.gallery,
        },
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      if (file == null) return null;
      return PickedPhoto(
        bytes: await file.readAsBytes(),
        contentType: file.mimeType ?? 'image/jpeg',
      );
    } on Object {
      // A refused permission or no camera: nothing to show beyond "no picture was chosen".
      return null;
    }
  }
}
