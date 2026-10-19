import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/model/story_viewer_model.dart';
import '../../utils/enums/story_viewers_status.dart';

part 'story_viewers_state.freezed.dart';

@freezed
abstract class StoryViewersState with _$StoryViewersState {
  const factory StoryViewersState({
    @Default(StoryViewersStatus.loading) StoryViewersStatus status,

    /// Newest first.
    @Default([]) List<StoryViewerModel> viewers,

    /// The story's full view count (every row repeats it); the count the story card knew before the
    /// first page arrived.
    @Default(0) int total,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,

    /// The last page failed: the list stays, a retry line shows at its end.
    @Default(false) bool loadMoreFailed,
  }) = _StoryViewersState;
}
