import 'package:flutter/widgets.dart';

import '../../../../../core/extensions/l10n.dart';

enum StoryAgeUnit {
  now,
  minutes,
  hours,
  days;

  String l10n(BuildContext context, int count) {
    final l10n = context.l10n;
    return switch (this) {
      now => l10n.storyAgeNow,
      minutes => l10n.storyAgeMinutes(count),
      hours => l10n.storyAgeHours(count),
      days => l10n.storyAgeDays(count),
    };
  }
}
