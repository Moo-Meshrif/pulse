import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_age_unit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_tap_action.dart';
import 'package:pulse/features/story/presentation/utils/story_age.dart';
import 'package:pulse/features/story/presentation/utils/story_dismiss.dart';
import 'package:pulse/features/story/presentation/utils/story_start_index.dart';
import 'package:pulse/features/story/presentation/utils/story_tap_zone.dart';

void main() {
  group('storyTapAction', () {
    StoryTapAction at(double dx, TextDirection d) =>
        storyTapAction(dx: dx, width: 300, direction: d);

    test('LTR: the first third goes back, the rest goes on', () {
      expect(at(10, TextDirection.ltr), StoryTapAction.previous);
      expect(at(99, TextDirection.ltr), StoryTapAction.previous);
      expect(at(100, TextDirection.ltr), StoryTapAction.next);
      expect(at(290, TextDirection.ltr), StoryTapAction.next);
    });

    test('RTL: the zones swap', () {
      expect(at(290, TextDirection.rtl), StoryTapAction.previous);
      expect(at(10, TextDirection.rtl), StoryTapAction.next);
      expect(at(150, TextDirection.rtl), StoryTapAction.next);
    });
  });

  test('a playlist opens at the first unseen story, or the first one', () {
    StoryModel s(bool seen) => StoryModel(seenByMe: seen);
    expect(storyStartIndex([s(true), s(true), s(false), s(false)]), 2);
    expect(storyStartIndex([s(false), s(false)]), 0);
    expect(storyStartIndex([s(true), s(true)]), 0);
    expect(storyStartIndex(const []), 0);
  });

  group('storyAge', () {
    final now = DateTime.utc(2026, 10, 13, 12);
    StoryAge age(Duration ago) => storyAge(now.subtract(ago), now);

    test('units and counts', () {
      expect(age(const Duration(seconds: 30)).unit, StoryAgeUnit.now);
      expect(age(const Duration(minutes: 5)), (
        unit: StoryAgeUnit.minutes,
        count: 5,
      ));
      expect(age(const Duration(minutes: 119)), (
        unit: StoryAgeUnit.hours,
        count: 1,
      ));
      expect(age(const Duration(hours: 23)), (
        unit: StoryAgeUnit.hours,
        count: 23,
      ));
      expect(age(const Duration(hours: 25)), (
        unit: StoryAgeUnit.days,
        count: 1,
      ));
    });

    test('a time in the future is now', () {
      expect(age(const Duration(minutes: -5)).unit, StoryAgeUnit.now);
    });
  });

  group('swipe down', () {
    test('closes past 120 dp or on a quick flick, not before', () {
      expect(storyDragCloses(distance: 121, velocity: 0), isTrue);
      expect(storyDragCloses(distance: 50, velocity: 701), isTrue);
      expect(storyDragCloses(distance: 120, velocity: 700), isFalse);
      expect(storyDragCloses(distance: 30, velocity: 100), isFalse);
    });

    test('the story shrinks to 0.9 at the close distance and no further', () {
      expect(storyDragScale(0), 1);
      expect(storyDragScale(60), closeTo(0.95, 1e-9));
      expect(storyDragScale(120), closeTo(0.9, 1e-9));
      expect(storyDragScale(500), closeTo(0.9, 1e-9));
    });
  });
}
