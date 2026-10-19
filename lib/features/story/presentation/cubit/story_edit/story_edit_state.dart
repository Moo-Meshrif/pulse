import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/captured_story_media.dart';
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
    @Default(false) bool isSharing,
    @Default(false) bool isSaving,

    /// One-shot: the story was handed to the upload; the screen goes back to Home.
    @Default(false) bool isShared,

    /// One-shot message for the screen.
    StoryEditNotice? notice,
  }) = _StoryEditState;
}
