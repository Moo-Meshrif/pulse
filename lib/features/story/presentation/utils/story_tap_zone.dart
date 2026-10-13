import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_dimens.dart';
import 'enums/story_tap_action.dart';

/// The first third of the screen at its start side goes back, the rest goes on. "Start" is the right in
/// Arabic, so the zones swap there.
StoryTapAction storyTapAction({
  required double dx,
  required double width,
  required TextDirection direction,
}) {
  final fromStart = direction == TextDirection.rtl ? width - dx : dx;
  return fromStart < width * StoryGestures.previousZone
      ? StoryTapAction.previous
      : StoryTapAction.next;
}
