import 'enums/story_age_unit.dart';

typedef StoryAge = ({StoryAgeUnit unit, int count});

/// The age of [postedAt] at [now]: under a minute is "now", then whole minutes, hours and days. A time
/// in the future (clock drift) counts as now.
StoryAge storyAge(DateTime postedAt, DateTime now) {
  final elapsed = now.difference(postedAt);
  if (elapsed.inMinutes < 1) return (unit: StoryAgeUnit.now, count: 0);
  if (elapsed.inHours < 1) {
    return (unit: StoryAgeUnit.minutes, count: elapsed.inMinutes);
  }
  if (elapsed.inDays < 1) {
    return (unit: StoryAgeUnit.hours, count: elapsed.inHours);
  }
  return (unit: StoryAgeUnit.days, count: elapsed.inDays);
}
