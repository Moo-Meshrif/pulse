import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/home/presentation/utils/feed_floaters_rules.dart';

void main() {
  const viewport = 800.0;

  bool pill({
    double offset = 2000,
    int pending = 3,
    bool down = false,
    bool expired = false,
  }) => FeedFloatersRules.showPill(
    offset: offset,
    viewport: viewport,
    pending: pending,
    isScrollingDown: down,
    isExpired: expired,
  );

  group('the pill', () {
    test('shows when posts wait and the person is more than a screen down', () {
      expect(pill(), isTrue);
    });

    test('does not show with nothing waiting, near the top, or expired', () {
      expect(pill(pending: 0), isFalse);
      expect(pill(offset: viewport), isFalse);
      expect(pill(offset: 0), isFalse);
      expect(pill(expired: true), isFalse);
    });

    test('steps aside while scrolling down', () {
      expect(pill(down: true), isFalse);
    });
  });

  group('the back to top button', () {
    bool button({double offset = 4000, int pending = 0}) =>
        FeedFloatersRules.showBackToTop(
          offset: offset,
          viewport: viewport,
          pending: pending,
        );

    test('shows after three screens with nothing waiting', () {
      expect(button(), isTrue);
      expect(button(offset: viewport * 3), isFalse);
    });

    test('leaves the place to the pill when posts wait', () {
      expect(button(pending: 2), isFalse);
    });
  });

  test('near the top is one screen or less', () {
    expect(FeedFloatersRules.isNearTop(viewport, viewport), isTrue);
    expect(FeedFloatersRules.isNearTop(viewport + 1, viewport), isFalse);
  });

  test('a very deep scroll jumps first, a moderate one does not', () {
    expect(FeedFloatersRules.jumpsFirst(viewport * 6 + 1, viewport), isTrue);
    expect(FeedFloatersRules.jumpsFirst(viewport * 6, viewport), isFalse);
  });

  test('the label is plain for one post, counts to nine, then 9+', () {
    expect(FeedFloatersRules.labelFor(1), NewPostsLabel.plain);
    expect(FeedFloatersRules.labelFor(2), NewPostsLabel.count);
    expect(FeedFloatersRules.labelFor(9), NewPostsLabel.count);
    expect(FeedFloatersRules.labelFor(10), NewPostsLabel.many);
  });
}
