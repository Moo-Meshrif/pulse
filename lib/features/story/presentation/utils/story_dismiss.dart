import '../dimens/story_constants.dart';

bool storyDragCloses({required double distance, required double velocity}) =>
    distance > StoryGestures.closeDistance ||
    velocity > StoryGestures.closeVelocity;

double storyDragScale(double distance) {
  final t = (distance / StoryGestures.closeDistance).clamp(0.0, 1.0);
  return 1 - (1 - StoryGestures.closeScale) * t;
}

double storyDragFade(double distance) =>
    1 - (distance / (StoryGestures.closeDistance * 3)).clamp(0.0, 1.0);
