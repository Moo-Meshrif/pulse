import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/blurhash_service.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/video_compress_service.dart';
import 'package:pulse/core/services/video_overlay_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/enums/story_overlay_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/model/story_overlay_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/domain/entity/captured_story_media.dart';
import 'package:pulse/features/story/presentation/cubit/story_edit/story_edit_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_edit_notice.dart';

class _Uploads extends Mock implements StoryUploadRepository {}

class _Thumbs extends Mock implements VideoThumbnailService {}

class _NoBlurhash implements BlurhashService {
  @override
  Future<String?> blurhash(String path) async => null;
}

class _Gallery extends Mock implements GalleryService {}

class _Compressor extends Mock implements VideoCompressService {}

class _VideoOverlay extends Mock implements VideoOverlayService {}

class _Account extends Mock implements GetLastAccountUseCase {}

const _photo = CapturedStoryMedia(
  path: '/p.jpg',
  type: StoryMediaType.image,
  width: 1080,
  height: 1920,
);
const _video = CapturedStoryMedia(
  path: '/v.mp4',
  type: StoryMediaType.video,
  width: 720,
  height: 1280,
  durationMs: 12000,
);

void main() {
  late _Uploads uploads;
  late _Thumbs thumbs;
  late _Gallery gallery;
  late _VideoOverlay videoOverlay;
  late _Account account;

  setUpAll(() {
    registerFallbackValue(
      NewStoryModel(
        filePath: '',
        type: StoryMediaType.image,
        width: 1,
        height: 1,
      ),
    );
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    uploads = _Uploads();
    thumbs = _Thumbs();
    gallery = _Gallery();
    videoOverlay = _VideoOverlay();
    account = _Account();
    when(() => account()).thenReturn(null);
    when(() => uploads.enqueue(any())).thenReturn(true);
    when(() => thumbs.thumbnail(any())).thenAnswer((_) async => '/t.jpg');
    when(gallery.ensureAccess).thenAnswer((_) async {});
    when(() => gallery.saveImage(any())).thenAnswer((_) async {});
    when(() => gallery.saveVideoFile(any())).thenAnswer((_) async {});
    when(
      () => videoOverlay.burn(
        any(),
        any(),
        edit: any(named: 'edit'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => '/b.mp4');
    when(() => videoOverlay.delete(any())).thenAnswer((_) async {});
  });

  StoryEditCubit build([CapturedStoryMedia media = _photo]) => StoryEditCubit(
    uploads,
    thumbs,
    _NoBlurhash(),
    gallery,
    videoOverlay,
    _Compressor(),
    account,
    media,
  );

  group('stickers', () {
    test('text is added in the middle, white, trimmed', () {
      final cubit = build()..addText('  Golden hour  ');
      final overlay = cubit.state.stickers.single.overlay;
      expect(overlay.type, StoryOverlayType.text);
      expect(overlay.text, 'Golden hour');
      expect([overlay.x, overlay.y], [0.5, 0.45]);
      expect(overlay.color, '#FFFFFF');
    });

    test('empty text adds nothing', () {
      final cubit = build()..addText('   ');
      expect(cubit.state.stickers, isEmpty);
    });

    test('at most 20 stickers, then a notice', () {
      final cubit = build();
      for (var i = 0; i < 21; i++) {
        cubit.addText('s$i');
      }
      expect(cubit.state.stickers, hasLength(20));
      expect(cubit.state.notice, StoryEditNotice.stickerLimit);
    });

    test('transform keeps positions as fractions inside the frame', () {
      final cubit = build()..addText('a');
      final id = cubit.state.stickers.single.id;
      cubit.transform(id, x: 1.4, y: -0.2, scale: 2, rotation: 30);
      final o = cubit.state.stickers.single.overlay;
      expect([o.x, o.y, o.scale, o.rotation], [1.0, 0.0, 2, 30]);
    });

    test('retyping changes the words; emptying removes the sticker', () {
      final cubit = build()..addText('a');
      final id = cubit.state.stickers.single.id;
      cubit.updateText(id, 'b');
      expect(cubit.state.stickers.single.overlay.text, 'b');
      cubit.updateText(id, ' ');
      expect(cubit.state.stickers, isEmpty);
    });

    test('a new place replaces the old location card', () {
      final cubit = build()
        ..addText('a')
        ..setLocation('Cairo')
        ..setLocation(' Giza ');
      final overlays = [for (final s in cubit.state.stickers) s.overlay];
      expect(overlays, hasLength(2));
      expect(overlays.last.type, StoryOverlayType.location);
      expect(overlays.last.text, 'Giza');
    });

    test('remove drops only that sticker', () {
      final cubit = build()
        ..addText('a')
        ..addText('b');
      cubit.remove(cubit.state.stickers.first.id);
      expect(cubit.state.stickers.single.overlay.text, 'b');
    });
  });

  test('mute toggles', () {
    final cubit = build(_video)..toggleMute();
    expect(cubit.state.isMuted, isTrue);
    cubit.toggleMute();
    expect(cubit.state.isMuted, isFalse);
  });

  group('share', () {
    test('a photo goes to the upload with its stickers as fractions', () async {
      final cubit = build()..addText('Hi');
      await cubit.share();
      final story =
          verify(() => uploads.enqueue(captureAny())).captured.single
              as NewStoryModel;
      expect(story.filePath, '/p.jpg');
      expect(story.type, StoryMediaType.image);
      expect([story.width, story.height], [1080, 1920]);
      expect(story.durationMs, isNull);
      expect(story.thumbFilePath, isNull);
      expect(story.overlays, [
        isA<StoryOverlayModel>().having((o) => o.text, 'text', 'Hi'),
      ]);
      expect(cubit.state.isShared, isTrue);
      verifyNever(() => thumbs.thumbnail(any()));
    });

    test('a video gets a poster frame and its duration', () async {
      final cubit = build(_video);
      await cubit.share();
      final story =
          verify(() => uploads.enqueue(captureAny())).captured.single
              as NewStoryModel;
      expect(story.thumbFilePath, '/t.jpg');
      expect(story.durationMs, 12000);
      expect(cubit.state.isShared, isTrue);
    });

    test('unknown size falls back to a 1080 x 1920 frame', () async {
      final cubit = build(
        const CapturedStoryMedia(path: '/p.jpg', type: StoryMediaType.image),
      );
      await cubit.share();
      final story =
          verify(() => uploads.enqueue(captureAny())).captured.single
              as NewStoryModel;
      expect([story.width, story.height], [1080, 1920]);
    });

    test('another story still posting: notice, stays on the screen', () async {
      when(() => uploads.enqueue(any())).thenReturn(false);
      final cubit = build();
      await cubit.share();
      expect(cubit.state.isShared, isFalse);
      expect(cubit.state.isSharing, isFalse);
      expect(cubit.state.notice, StoryEditNotice.uploadBusy);
    });

    test('a poster frame that fails is a share failure', () async {
      when(() => thumbs.thumbnail(any())).thenThrow(const UnexpectedFailure());
      final cubit = build(_video);
      await cubit.share();
      expect(cubit.state.notice, StoryEditNotice.shareFailed);
      expect(cubit.state.isShared, isFalse);
      verifyNever(() => uploads.enqueue(any()));
    });
  });

  group('save', () {
    test('a photo is saved from the snapshot bytes', () async {
      final cubit = build();
      await cubit.saveImage(Uint8List.fromList([1, 2]));
      verify(() => gallery.saveImage(any())).called(1);
      expect(cubit.state.notice, StoryEditNotice.saved);
      expect(cubit.state.isSaving, isFalse);
    });

    test('no snapshot is a failed save', () async {
      final cubit = build();
      await cubit.saveImage(null);
      expect(cubit.state.notice, StoryEditNotice.saveFailed);
    });

    test('a video without stickers is saved as it is', () async {
      final cubit = build(_video);
      await cubit.saveVideo(null);
      verify(() => gallery.saveVideoFile('/v.mp4')).called(1);
      verifyNever(
        () => videoOverlay.burn(
          any(),
          any(),
          edit: any(named: 'edit'),
          onProgress: any(named: 'onProgress'),
        ),
      );
      expect(cubit.state.notice, StoryEditNotice.saved);
    });

    test(
      'a video with stickers is burned, saved, and the copy deleted',
      () async {
        final cubit = build(_video)..addText('Hi');
        await cubit.saveVideo(Uint8List.fromList([1]));
        verifyInOrder([
          () => videoOverlay.burn(
            '/v.mp4',
            any(),
            edit: any(named: 'edit'),
            onProgress: any(named: 'onProgress'),
          ),
          () => gallery.saveVideoFile('/b.mp4'),
          () => videoOverlay.delete('/b.mp4'),
        ]);
        verifyNever(() => gallery.saveVideoFile('/v.mp4'));
        expect(cubit.state.notice, StoryEditNotice.saved);
      },
    );

    test('a failed burn is a failed save and saves nothing', () async {
      when(
        () => videoOverlay.burn(
          any(),
          any(),
          edit: any(named: 'edit'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const UnexpectedFailure());
      final cubit = build(_video)..addText('Hi');
      await cubit.saveVideo(Uint8List.fromList([1]));
      verifyNever(() => gallery.saveVideoFile(any()));
      expect(cubit.state.notice, StoryEditNotice.saveFailed);
    });

    test('a failed gallery save still deletes the copy', () async {
      when(() => gallery.saveVideoFile(any()))
          .thenThrow(const PermissionFailure());
      final cubit = build(_video)..addText('Hi');
      await cubit.saveVideo(Uint8List.fromList([1]));
      verify(() => videoOverlay.delete('/b.mp4')).called(1);
      expect(cubit.state.notice, StoryEditNotice.saveFailed);
    });

    test('stickers but no snapshot is a failed save', () async {
      final cubit = build(_video)..addText('Hi');
      await cubit.saveVideo(null);
      verifyNever(
        () => videoOverlay.burn(
          any(),
          any(),
          edit: any(named: 'edit'),
          onProgress: any(named: 'onProgress'),
        ),
      );
      expect(cubit.state.notice, StoryEditNotice.saveFailed);
    });

    test('a refused library is a failed save', () async {
      when(() => gallery.saveVideoFile(any()))
          .thenThrow(const PermissionFailure());
      final cubit = build(_video);
      await cubit.saveVideo(null);
      expect(cubit.state.notice, StoryEditNotice.saveFailed);
    });
  });
}
