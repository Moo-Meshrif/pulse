/// Alphas applied to `AppColors.onDark` (white) and `AppColors.black` on story screens (source-tokens.md §2-§7).
abstract final class StoryOpacity {
  static const double replyBorder = 0.7;
  static const double replyHint = 0.9;
  static const double time = 0.8;
  static const double recordTrack = 0.3;
  static const double hint = 0.85;
  static const double pausedChip = 0.45;

  /// The header while a sheet holds the story ([estimated]: the board only says "faded").
  static const double pausedHeader = 0.4;
  static const double viewersDim = 0.35;

  /// The delete circle of the viewers sheet: `dangerOnDark` over the dark sheet ([estimated] from the board).
  static const double dangerTint = 0.18;
}

/// Story durations and limits (source-tokens.md §2.1, §8).
abstract final class StoryTiming {
  static const image = Duration(seconds: 5);
  static const maxVideo = Duration(seconds: 60);
  static const minVideo = Duration(seconds: 1);
  static const markSeenAfter = Duration(seconds: 1);
  static const bufferLoaderDelay = Duration(milliseconds: 400);
  static const lifetime = Duration(hours: 24);
}

/// Story gestures (source-tokens.md §2.1).
abstract final class StoryGestures {
  /// The left share of the screen that goes to the previous story; the rest goes to the next one.
  static const double previousZone = 1 / 3;
  static const double closeDistance = 120; // unscaled: drag distance threshold
  static const double closeVelocity = 700;
  static const double closeScale = 0.9;
}

/// Story motion (source-tokens.md §8).
abstract final class StoryMotion {
  static const uiFade = Duration(milliseconds: 150);
  static const heroOpen = Duration(milliseconds: 280);
  static const personSwipe = Duration(milliseconds: 300);
  static const dragSnapBack = Duration(milliseconds: 200);
  static const likePop = Duration(milliseconds: 200);
  static const likeRestScale = 1.0;
  static const likePopScale = 1.25;
  static const uploadRing = Duration(milliseconds: 240);
  static const reducedMotionFade = Duration(milliseconds: 150);
}
