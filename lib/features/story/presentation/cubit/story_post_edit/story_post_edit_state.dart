import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/utils/story_post_args.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/enums/story_edit_notice.dart';
import '../../utils/story_post_background.dart';
import '../../utils/story_sticker.dart';

part 'story_post_edit_state.freezed.dart';

@freezed
abstract class StoryPostEditState with _$StoryPostEditState {
  const factory StoryPostEditState({
    required StoryPostArgs post,

    /// The six backgrounds the palette tool offers; the first follows the post's picture once it is read.
    required List<StoryPostBackground> backgrounds,
    @Default(StoryPostStickerStyle.card) StoryPostStickerStyle style,

    /// Where the post sticker sits (fractions of the screen), how big and how it is turned (degrees).
    @Default(0.5) double x,
    @Default(StoryPostDimens.defaultY) double y,
    @Default(1.0) double scale,
    @Default(StoryPostDimens.defaultTilt) double rotation,
    @Default(0) int backgroundIndex,

    /// The swatches show where the hint was.
    @Default(false) bool isPaletteOpen,

    /// The text on the story.
    @Default([]) List<StorySticker> stickers,
    @Default(false) bool isSharing,
    @Default(false) bool isSaving,

    /// One-shot: the story was handed to the upload; the screen goes back to Home.
    @Default(false) bool isShared,

    /// One-shot message for the screen.
    StoryEditNotice? notice,
  }) = _StoryPostEditState;
}
