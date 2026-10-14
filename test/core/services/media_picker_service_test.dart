import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/image_resize_preset.dart';
import 'package:pulse/core/services/media_picker_service.dart';

class _ImagePicker extends Mock implements ImagePicker {}

/// A 2 x 3 PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAIAAAADCAIAAAA2iEnWAAAAEElEQVR4nGP4z8AARAwoFABE0AX7pM/egAAAAABJRU5ErkJggg==',
);

void main() {
  late _ImagePicker imagePicker;
  late MediaPickerService service;
  late Directory dir;

  setUp(() {
    imagePicker = _ImagePicker();
    service = ImagePickerMediaPickerService.withPicker(imagePicker);
    dir = Directory.systemTemp.createTempSync('picker_test');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  void whenPicks(List<XFile> files) => when(
    () => imagePicker.pickMultipleMedia(
      limit: any(named: 'limit'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    ),
  ).thenAnswer((_) async => files);

  test('asks the library to shrink photos to the preset', () async {
    whenPicks([]);
    await service.pickMany(limit: 4);
    verify(
      () => imagePicker.pickMultipleMedia(
        limit: 4,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 80,
      ),
    ).called(1);

    await service.pickMany(limit: 4, preset: ImageResizePreset.max);
    verify(
      () => imagePicker.pickMultipleMedia(
        limit: 4,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      ),
    ).called(1);
  });

  testWidgets('a photo comes back measured with its file size', (tester) async {
    final file = File('${dir.path}/a.png')..writeAsBytesSync(_png);
    whenPicks([XFile(file.path, mimeType: 'image/png')]);

    final picked = (await tester.runAsync(() => service.pickMany(limit: 3)))!;

    expect(picked, hasLength(1));
    expect(picked.single.isVideo, isFalse);
    expect(picked.single.width, 2);
    expect(picked.single.height, 3);
    expect(picked.single.sizeBytes, _png.length);
  });

  test('a failing library gives an empty list', () async {
    when(
      () => imagePicker.pickMultipleMedia(
        limit: any(named: 'limit'),
        maxWidth: any(named: 'maxWidth'),
        maxHeight: any(named: 'maxHeight'),
        imageQuality: any(named: 'imageQuality'),
      ),
    ).thenThrow(Exception('denied'));
    expect(await service.pickMany(limit: 3), isEmpty);
  });
}
