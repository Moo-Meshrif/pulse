import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../story/domain/entity/story_rail_item_entity.dart';
import '../../../story/domain/entity/story_upload_status.dart';

part 'story_rail_state.freezed.dart';

@freezed
abstract class StoryRailState with _$StoryRailState {
  const StoryRailState._();

  const factory StoryRailState({
    /// The people with an active story: you first when you have one, then unseen, then latest.
    @Default(<StoryRailItemEntity>[]) List<StoryRailItemEntity> items,

    /// How posting your own story is going.
    @Default(StoryUploadIdle()) StoryUploadStatus upload,
  }) = _StoryRailState;

  /// Your own story on the rail, once you have posted one.
  StoryRailItemEntity? get me {
    for (final item in items) {
      if (item.isMe) return item;
    }
    return null;
  }
}
