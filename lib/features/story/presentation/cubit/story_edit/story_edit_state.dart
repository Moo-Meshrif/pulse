import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/captured_story_media.dart';
import '../../dimens/story_constants.dart';
import '../../utils/enums/story_edit_notice.dart';
import '../../utils/story_sticker.dart';

part 'story_edit_state.freezed.dart';

@freezed
abstract class StoryEditState with _$StoryEditState {
  const factory StoryEditState({
    required CapturedStoryMedia media,
    @Default([]) List<StorySticker> stickers,

    /// Video only: the preview plays without sound.
    @Default(false) bool isMuted,

    /// Video over 60 s only: where the shared part starts and ends, in milliseconds. It starts as the first
    /// 60 s and the user moves either end, but never makes it longer than that.
    @Default(0) int trimStartMs,
    @Default(0) int trimEndMs,

    /// Video over 60 s only: frames along the video for the trim bar; empty until they are read.
    @Default(<Uint8List>[]) List<Uint8List> trimFrames,
    @Default(false) bool isSharing,
    @Default(false) bool isSaving,

    /// How far saving a video is (0..1), while [isSaving].
    @Default(0) double saveProgress,

    /// One-shot: the story was handed to the upload; the screen goes back to Home.
    @Default(false) bool isShared,

    /// One-shot message for the screen.
    StoryEditNotice? notice,
  }) = _StoryEditState;
}

extension StoryEditTrim on StoryEditState {
  int get _durationMs => media.durationMs ?? 0;

  /// A video longer than a story can be: the shared part is chosen.
  bool get isTrimmable => _durationMs > StoryTiming.maxVideo.inMilliseconds;

  /// How much of the video is shared.
  int get trimLengthMs => isTrimmable ? trimEndMs - trimStartMs : _durationMs;
}
