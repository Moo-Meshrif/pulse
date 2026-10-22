import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/home/presentation/dimens/home_dimens.dart';
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
    pending: pending,
    isScrollingDown: down,
    isExpired: expired,
  );

  group('the pill', () {
    test('shows when posts wait and the person is not at the top', () {
      expect(pill(), isTrue);
    });

    test('does not show with nothing waiting, at the top, or expired', () {
      expect(pill(pending: 0), isFalse);
      expect(pill(offset: 0), isFalse);
      expect(pill(offset: 300), isTrue);
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

  test('at the top is the very top, a few pixels at most', () {
    expect(FeedFloatersRules.isAtTop(0), isTrue);
    expect(FeedFloatersRules.isAtTop(-20), isTrue);
    expect(FeedFloatersRules.isAtTop(HomeDimens.atTopOffset), isTrue);
    expect(FeedFloatersRules.isAtTop(HomeDimens.atTopOffset + 1), isFalse);
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
