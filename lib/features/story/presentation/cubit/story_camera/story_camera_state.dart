import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/services/camera_device.dart';
import '../../../domain/entity/captured_story_media.dart';
import '../../utils/enums/story_camera_notice.dart';
import '../../utils/enums/story_camera_status.dart';

part 'story_camera_state.freezed.dart';

@freezed
abstract class StoryCameraState with _$StoryCameraState {
  const StoryCameraState._();

  const factory StoryCameraState({
    @Default(StoryCameraStatus.idle) StoryCameraStatus status,
    @Default(CameraLens.back) CameraLens lens,
    @Default(false) bool hasFlash,
    @Default(false) bool isFlashOn,
    @Default(false) bool isRecording,
    @Default(Duration.zero) Duration elapsed,

    /// A photo or video is being saved (shutter released): further taps do nothing.
    @Default(false) bool isBusy,
    @Default(true) bool hintVisible,

    /// One-shot: a photo or video is ready for the edit screen; the screen takes it and clears it.
    CapturedStoryMedia? captured,

    /// One-shot message for the screen.
    StoryCameraNotice? notice,
  }) = _StoryCameraState;

  bool get canCapture =>
      status == StoryCameraStatus.ready && !isBusy && !isRecording;
}
