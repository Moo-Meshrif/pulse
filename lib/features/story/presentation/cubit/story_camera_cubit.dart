import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/camera_device.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../core/state/base_cubit.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../data/datasource/story_camera_hint_datasource.dart';
import '../../data/enums/story_media_type.dart';
import '../../domain/entity/captured_story_media.dart';
import '../utils/enums/story_camera_notice.dart';
import '../utils/enums/story_camera_status.dart';
import 'story_camera_state.dart';

/// The story camera (docs/specs/story/screens/s2-create-camera.md): the lens and flash, a photo on tap,
/// a video on hold (1 to 60 seconds; shorter is a photo), and the library. A capture ends in [captured],
/// which the screen carries to the edit screen.
@injectable
class StoryCameraCubit extends BaseCubit<StoryCameraState> {
  StoryCameraCubit(this._device, this._picker, StoryCameraHintDatasource hint)
    : _hint = hint,
      super(StoryCameraState(hintVisible: !hint.isSeen));

  static const tick = Duration(milliseconds: 100);

  final CameraDevice _device;
  final MediaPickerService _picker;
  final StoryCameraHintDatasource _hint;

  Timer? _timer;
  bool _withAudio = true;

  /// Opens the camera on the current lens. [withAudio] false when the microphone is refused.
  Future<void> start({bool withAudio = true}) async {
    _withAudio = withAudio;
    emit(state.copyWith(status: StoryCameraStatus.starting));
    try {
      await _device.open(lens: state.lens, withAudio: withAudio);
      emit(
        state.copyWith(
          status: StoryCameraStatus.ready,
          hasFlash: _device.hasFlash,
          isFlashOn: false,
        ),
      );
    } on Failure {
      emit(state.copyWith(status: StoryCameraStatus.unavailable));
    }
  }

  /// The live picture of the open camera.
  Widget preview() => _device.preview();

  /// Lets go of the camera (the app went to the background); [start] opens it again.
  Future<void> stop() async {
    await cancelRecording();
    await _device.close();
    emit(state.copyWith(status: StoryCameraStatus.idle));
  }

  Future<void> flip() async {
    if (!state.canCapture) return;
    emit(
      state.copyWith(
        lens: state.lens == CameraLens.back
            ? CameraLens.front
            : CameraLens.back,
      ),
    );
    await start(withAudio: _withAudio);
  }

  Future<void> toggleFlash() async {
    if (!state.hasFlash || state.status != StoryCameraStatus.ready) return;
    final on = !state.isFlashOn;
    try {
      await _device.setFlash(on: on);
      emit(state.copyWith(isFlashOn: on));
    } on Failure {
      emit(state.copyWith(notice: StoryCameraNotice.captureFailed));
    }
  }

  Future<void> takePhoto() async {
    if (!state.canCapture) return;
    emit(state.copyWith(isBusy: true));
    await _takePhoto();
  }

  Future<void> _takePhoto() async {
    try {
      final file = await _device.takePhoto();
      _capture(
        CapturedStoryMedia(
          path: file.path,
          type: StoryMediaType.image,
          width: file.width,
          height: file.height,
        ),
      );
    } on Failure {
      emit(
        state.copyWith(isBusy: false, notice: StoryCameraNotice.captureFailed),
      );
    }
  }

  Future<void> startRecording() async {
    if (!state.canCapture) return;
    try {
      await _device.startRecording();
    } on Failure {
      emit(state.copyWith(notice: StoryCameraNotice.captureFailed));
      return;
    }
    emit(state.copyWith(isRecording: true, elapsed: Duration.zero));
    _timer = Timer.periodic(tick, (_) {
      final elapsed = state.elapsed + tick;
      emit(state.copyWith(elapsed: elapsed));
      if (elapsed >= StoryTiming.maxVideo) stopRecording();
    });
  }

  /// Release of the shutter (or the 60 s limit): the video goes on; under a second it becomes a photo.
  Future<void> stopRecording() async {
    if (!state.isRecording) return;
    _timer?.cancel();
    _timer = null;
    final elapsed = state.elapsed;
    emit(state.copyWith(isRecording: false, isBusy: true));
    try {
      if (elapsed < StoryTiming.minVideo) {
        await _device.stopRecording(keep: false);
        await _takePhoto();
        return;
      }
      final file = await _device.stopRecording();
      if (file == null) {
        emit(state.copyWith(isBusy: false));
        return;
      }
      _capture(
        CapturedStoryMedia(
          path: file.path,
          type: StoryMediaType.video,
          width: file.width,
          height: file.height,
          durationMs: elapsed.inMilliseconds,
        ),
      );
    } on Failure {
      emit(
        state.copyWith(isBusy: false, notice: StoryCameraNotice.captureFailed),
      );
    }
  }

  /// Drops a recording in progress (the screen was closed).
  Future<void> cancelRecording() async {
    _timer?.cancel();
    _timer = null;
    if (!state.isRecording) return;
    emit(state.copyWith(isRecording: false, elapsed: Duration.zero));
    try {
      await _device.stopRecording(keep: false);
    } on Failure {
      // Nothing left to save either way.
    }
  }

  /// The library: a photo, or a video of at most 60 seconds. Works without any camera permission.
  Future<void> pickFromGallery() async {
    final media = await _picker.pick();
    if (media == null) return;
    final duration = Duration(milliseconds: media.durationMs ?? 0);
    if (media.isVideo && duration > StoryTiming.maxVideo) {
      emit(state.copyWith(notice: StoryCameraNotice.videoTooLong));
      return;
    }
    _capture(
      CapturedStoryMedia(
        path: media.path,
        type: media.isVideo ? StoryMediaType.video : StoryMediaType.image,
        width: media.width,
        height: media.height,
        durationMs: media.isVideo ? media.durationMs : null,
      ),
    );
  }

  /// The screen took [StoryCameraState.captured].
  void clearCaptured() => emit(state.copyWith(captured: null, isBusy: false));

  void clearNotice() => emit(state.copyWith(notice: null));

  void _capture(CapturedStoryMedia media) {
    unawaited(_hint.markSeen());
    emit(state.copyWith(captured: media, hintVisible: false, isBusy: true));
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _device.close();
    return super.close();
  }
}
