import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/enums/image_resize_preset.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/camera_device.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/features/story/data/datasource/story_camera_hint_datasource.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/presentation/cubit/story_camera_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_camera_notice.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_camera_status.dart';

class _Device extends Mock implements CameraDevice {}

class _Picker extends Mock implements MediaPickerService {}

class _Hint extends Mock implements StoryCameraHintDatasource {}

void main() {
  late _Device device;
  late _Picker picker;
  late _Hint hint;

  setUpAll(() {
    registerFallbackValue(ImageResizePreset.standard);
    registerFallbackValue(CameraLens.back);
  });

  setUp(() {
    device = _Device();
    picker = _Picker();
    hint = _Hint();
    when(() => hint.isSeen).thenReturn(false);
    when(() => hint.markSeen()).thenAnswer((_) async {});
    when(
      () => device.open(
        lens: any(named: 'lens'),
        withAudio: any(named: 'withAudio'),
      ),
    ).thenAnswer((_) async {});
    when(() => device.close()).thenAnswer((_) async {});
    when(() => device.hasFlash).thenReturn(true);
    when(() => device.setFlash(on: any(named: 'on'))).thenAnswer((_) async {});
    when(() => device.takePhoto()).thenAnswer(
      (_) async =>
          const CapturedFile(path: '/p.jpg', width: 1080, height: 1920),
    );
    when(() => device.startRecording()).thenAnswer((_) async {});
    when(() => device.stopRecording(keep: any(named: 'keep'))).thenAnswer(
      (i) async => i.namedArguments[#keep] == false
          ? null
          : const CapturedFile(path: '/v.mp4', width: 1080, height: 1920),
    );
  });

  StoryCameraCubit build() => StoryCameraCubit(device, picker, hint);

  test('the hint shows until a story was captured', () async {
    final cubit = build();
    expect(cubit.state.hintVisible, isTrue);
    await cubit.start();
    await cubit.takePhoto();
    expect(cubit.state.hintVisible, isFalse);
    verify(() => hint.markSeen()).called(1);
    await cubit.close();

    when(() => hint.isSeen).thenReturn(true);
    final again = build();
    expect(again.state.hintVisible, isFalse);
    await again.close();
  });

  group('start', () {
    test('opens the camera and reads the flash', () async {
      final cubit = build();
      await cubit.start(withAudio: false);
      expect(cubit.state.status, StoryCameraStatus.ready);
      expect(cubit.state.hasFlash, isTrue);
      verify(() => device.open(lens: CameraLens.back, withAudio: false));
      await cubit.close();
    });

    test(
      'a camera that cannot open is unavailable, and start retries',
      () async {
        when(
          () => device.open(
            lens: any(named: 'lens'),
            withAudio: any(named: 'withAudio'),
          ),
        ).thenThrow(const CameraFailure());
        final cubit = build();
        await cubit.start();
        expect(cubit.state.status, StoryCameraStatus.unavailable);

        when(
          () => device.open(
            lens: any(named: 'lens'),
            withAudio: any(named: 'withAudio'),
          ),
        ).thenAnswer((_) async {});
        await cubit.start();
        expect(cubit.state.status, StoryCameraStatus.ready);
        await cubit.close();
      },
    );

    test('stop lets go of the camera', () async {
      final cubit = build();
      await cubit.start();
      await cubit.stop();
      expect(cubit.state.status, StoryCameraStatus.idle);
      verify(() => device.close()).called(greaterThanOrEqualTo(1));
      await cubit.close();
    });
  });

  group('flash and flip', () {
    test('flash toggles on and off', () async {
      final cubit = build();
      await cubit.start();
      await cubit.toggleFlash();
      expect(cubit.state.isFlashOn, isTrue);
      verify(() => device.setFlash(on: true)).called(1);
      await cubit.toggleFlash();
      expect(cubit.state.isFlashOn, isFalse);
      await cubit.close();
    });

    test(
      'flip switches lens and reopens; a front camera has no flash',
      () async {
        final cubit = build();
        await cubit.start();
        await cubit.toggleFlash();
        when(() => device.hasFlash).thenReturn(false);
        await cubit.flip();
        expect(cubit.state.lens, CameraLens.front);
        expect(cubit.state.hasFlash, isFalse);
        expect(cubit.state.isFlashOn, isFalse);
        verify(() => device.open(lens: CameraLens.front, withAudio: true));

        await cubit.toggleFlash();
        verify(() => device.setFlash(on: true))
            .called(1); // only the first toggle
        await cubit.close();
      },
    );
  });

  group('photo', () {
    test('a tap makes a photo and hands it on', () async {
      final cubit = build();
      await cubit.start();
      await cubit.takePhoto();
      final media = cubit.state.captured!;
      expect(media.type, StoryMediaType.image);
      expect(media.path, '/p.jpg');
      expect(media.width, 1080);
      await cubit.close();
    });

    test('a failed photo shows a notice and frees the shutter', () async {
      when(() => device.takePhoto()).thenThrow(const CameraFailure());
      final cubit = build();
      await cubit.start();
      await cubit.takePhoto();
      expect(cubit.state.notice, StoryCameraNotice.captureFailed);
      expect(cubit.state.isBusy, isFalse);
      expect(cubit.state.captured, isNull);
      await cubit.close();
    });

    test('nothing is captured while the camera is not ready', () async {
      final cubit = build();
      await cubit.takePhoto();
      verifyNever(() => device.takePhoto());
      await cubit.close();
    });

    test('clearCaptured frees the shutter for the next shot', () async {
      final cubit = build();
      await cubit.start();
      await cubit.takePhoto();
      cubit.clearCaptured();
      expect(cubit.state.captured, isNull);
      expect(cubit.state.canCapture, isTrue);
      await cubit.close();
    });
  });

  group('video', () {
    test('a hold of 3 seconds is a video of that length', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        cubit.startRecording();
        async.flushMicrotasks();
        expect(cubit.state.isRecording, isTrue);
        async.elapse(const Duration(seconds: 3));
        expect(cubit.state.elapsed, const Duration(seconds: 3));
        cubit.stopRecording();
        async.flushMicrotasks();
        final media = cubit.state.captured!;
        expect(media.type, StoryMediaType.video);
        expect(media.durationMs, 3000);
        expect(cubit.state.isRecording, isFalse);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('under a second becomes a photo and the video is dropped', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        cubit.startRecording();
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 600));
        cubit.stopRecording();
        async.flushMicrotasks();
        verify(() => device.stopRecording(keep: false)).called(1);
        expect(cubit.state.captured!.type, StoryMediaType.image);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('stops by itself at 60 seconds', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        cubit.startRecording();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 61));
        async.flushMicrotasks();
        final media = cubit.state.captured!;
        expect(media.type, StoryMediaType.video);
        expect(media.durationMs, 60000);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('release after the limit does not capture twice', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        cubit.startRecording();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 61));
        async.flushMicrotasks();
        cubit.stopRecording(); // the finger lifts afterwards
        async.flushMicrotasks();
        verify(() => device.stopRecording(keep: any(named: 'keep'))).called(1);
        cubit.close();
        async.flushMicrotasks();
      });
    });

    test('cancel drops the recording', () {
      fakeAsync((async) {
        final cubit = build();
        cubit.start();
        async.flushMicrotasks();
        cubit.startRecording();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        cubit.cancelRecording();
        async.flushMicrotasks();
        verify(() => device.stopRecording(keep: false)).called(1);
        expect(cubit.state.isRecording, isFalse);
        expect(cubit.state.captured, isNull);
        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.elapsed, Duration.zero);
        cubit.close();
        async.flushMicrotasks();
      });
    });
  });

  group('gallery', () {
    test('a photo goes on', () async {
      when(() => picker.pick(preset: any(named: 'preset'))).thenAnswer(
        (_) async => const PickedMedia(
          path: '/g.jpg',
          isVideo: false,
          width: 800,
          height: 600,
        ),
      );
      final cubit = build();
      await cubit.pickFromGallery();
      expect(cubit.state.captured!.type, StoryMediaType.image);
      expect(cubit.state.captured!.durationMs, isNull);
      // Photos come back shrunk for a full screen.
      verify(() => picker.pick(preset: ImageResizePreset.fullScreen)).called(1);
      await cubit.close();
    });

    test('a video up to 60 seconds goes on', () async {
      when(() => picker.pick(preset: any(named: 'preset'))).thenAnswer(
        (_) async =>
            const PickedMedia(path: '/g.mp4', isVideo: true, durationMs: 60000),
      );
      final cubit = build();
      await cubit.pickFromGallery();
      expect(cubit.state.captured!.type, StoryMediaType.video);
      expect(cubit.state.captured!.durationMs, 60000);
      await cubit.close();
    });

    test('a longer video is refused with a notice', () async {
      when(() => picker.pick(preset: any(named: 'preset'))).thenAnswer(
        (_) async =>
            const PickedMedia(path: '/g.mp4', isVideo: true, durationMs: 61000),
      );
      final cubit = build();
      await cubit.pickFromGallery();
      expect(cubit.state.captured, isNull);
      expect(cubit.state.notice, StoryCameraNotice.videoTooLong);
      await cubit.close();
    });

    test('cancelling the picker does nothing; no camera is needed', () async {
      when(() => picker.pick(preset: any(named: 'preset')))
          .thenAnswer((_) async => null);
      final cubit = build();
      await cubit.pickFromGallery();
      expect(cubit.state.captured, isNull);
      expect(cubit.state.status, StoryCameraStatus.idle);
      verifyNever(
        () => device.open(
          lens: any(named: 'lens'),
          withAudio: any(named: 'withAudio'),
        ),
      );
      await cubit.close();
    });
  });
}
