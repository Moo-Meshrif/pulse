import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/story_model.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import '../utils/enums/story_pause_reason.dart';
import '../utils/enums/story_viewer_status.dart';
import '../utils/story_start_index.dart';

part 'story_viewer_state.freezed.dart';

@freezed
abstract class StoryViewerState with _$StoryViewerState {
  const StoryViewerState._();

  const factory StoryViewerState({
    @Default(StoryViewerStatus.loading) StoryViewerStatus status,

    Failure? failure,

    @Default([]) List<StoryRailItemEntity> people,
    @Default(0) int personIndex,

    /// Stories by author id; a person is missing until their list arrives.
    @Default({}) Map<String, List<StoryModel>> stories,

    @Default({}) Set<String> failedAuthors,

    @Default(0) int storyIndex,
    @Default({}) Set<StoryPauseReason> pauses,

    /// Grows when the first story of the first person is asked to go back: the story starts again.
    @Default(0) int restarts,

    /// One-shot: the last story was passed, the screen closes.
    @Default(false) bool isFinished,
  }) = _StoryViewerState;

  bool get isPaused => pauses.isNotEmpty;

  bool get isHolding => pauses.contains(StoryPauseReason.hold);

  StoryRailItemEntity? get person =>
      personIndex < people.length ? people[personIndex] : null;

  List<StoryModel>? get currentStories {
    final id = person?.authorId;
    return id == null ? null : stories[id];
  }

  StoryModel? get story {
    final list = currentStories;
    if (list == null || storyIndex >= list.length) return null;
    return list[storyIndex];
  }

  StoryModel? storyOf(int index) {
    if (index == personIndex) return story;
    if (index >= people.length) return null;
    final list = stories[people[index].authorId];
    return list == null || list.isEmpty ? null : list[storyStartIndex(list)];
  }
}
