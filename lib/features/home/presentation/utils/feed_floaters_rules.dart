import '../dimens/home_dimens.dart';

/// When the "New posts" pill and the back to top button show, from where the feed is scrolled to
/// (docs/specs/home/screens/s2-new-posts-pill.md). Distances are in viewport heights.
abstract final class FeedFloatersRules {
  /// The person is near the top: new posts can go in at once, nothing they read moves much.
  static bool isNearTop(double offset, double viewport) =>
      offset <= viewport * HomeDimens.pillViewports;

  /// The pill shows while posts wait and the person is further down than one screen. It steps aside
  /// while they scroll down, and after its time ran out until the next batch.
  static bool showPill({
    required double offset,
    required double viewport,
    required int pending,
    required bool isScrollingDown,
    required bool isExpired,
  }) =>
      pending > 0 &&
      !isExpired &&
      !isScrollingDown &&
      !isNearTop(offset, viewport);

  /// The round button shows when nothing waits and the person is more than three screens down.
  static bool showBackToTop({
    required double offset,
    required double viewport,
    required int pending,
  }) => pending == 0 && offset > viewport * HomeDimens.backToTopViewports;

  /// Very deep: jump to one screen from the top first, so the scroll back is short.
  static bool jumpsFirst(double offset, double viewport) =>
      offset > viewport * HomeDimens.jumpFirstViewports;

  /// 1 post says "New posts"; 2 to 9 say the count; more say "9+".
  static NewPostsLabel labelFor(int pending) {
    if (pending <= 1) return NewPostsLabel.plain;
    return pending > HomeDimens.pillMaxCount
        ? NewPostsLabel.many
        : NewPostsLabel.count;
  }
}

enum NewPostsLabel { plain, count, many }
