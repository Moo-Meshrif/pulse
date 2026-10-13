import '../../data/model/story_model.dart';

/// Where a person's playlist opens: the first story you have not seen, or the first one when you saw
/// them all.
int storyStartIndex(List<StoryModel> stories) {
  final unseen = stories.indexWhere((s) => s.seenByMe != true);
  return unseen < 0 ? 0 : unseen;
}
