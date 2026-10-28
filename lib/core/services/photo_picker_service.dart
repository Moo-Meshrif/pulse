import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
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

/// The frame a picked photo is cropped to before it is used.
enum PhotoCrop {
  /// A square, previewed as a circle (profile photo).
  avatar(CropAspectRatio(ratioX: 1, ratioY: 1)),

  /// A wide banner (the profile cover, 390:170).
  cover(CropAspectRatio(ratioX: 390, ratioY: 170));

  const PhotoCrop(this.ratio);

  final CropAspectRatio ratio;
}

/// The camera and the photo library. Returns null when the user cancels or refuses the permission, so
/// callers only handle "got a picture" or "did not".
abstract interface class PhotoPickerService {
  /// With [crop] the person frames the picture first; cancelling the crop returns null.
  Future<PickedPhoto?> pick(PhotoSource source, {PhotoCrop? crop});
}

/// [PhotoPickerService] over `image_picker`.
@LazySingleton(as: PhotoPickerService)
final class ImagePickerPhotoPickerService implements PhotoPickerService {
  static const _maxSide = 1024.0;
  static const _quality = 85;

  final _picker = ImagePicker();

  @override
  Future<PickedPhoto?> pick(PhotoSource source, {PhotoCrop? crop}) async {
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
      if (crop == null) {
        return PickedPhoto(
          bytes: await file.readAsBytes(),
          contentType: file.mimeType ?? 'image/jpeg',
        );
      }
      final cropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: crop.ratio,
        maxWidth: _maxSide.round(),
        maxHeight: _maxSide.round(),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: _quality,
        uiSettings: [
          AndroidUiSettings(
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: crop == PhotoCrop.avatar
                ? CropStyle.circle
                : CropStyle.rectangle,
          ),
          IOSUiSettings(
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            cropStyle: crop == PhotoCrop.avatar
                ? CropStyle.circle
                : CropStyle.rectangle,
          ),
        ],
      );
      if (cropped == null) return null;
      return PickedPhoto(
        bytes: await cropped.readAsBytes(),
        contentType: 'image/jpeg',
      );
    } on Object {
      // A refused permission or no camera: nothing to show beyond "no picture was chosen".
      return null;
    }
  }
}
