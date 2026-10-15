import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
import '../../dimens/home_dimens.dart';
import 'rail_avatar.dart';
import 'rail_rings.dart';

/// Your photo (or an empty soft circle before you have a story) inside a ring drawn [progress] of the way.
class RingedPhoto extends StatelessWidget {
  const RingedPhoto({
    super.key,
    required this.me,
    required this.progress,
    required this.color,
    this.track,
  });

  final StoryRailItemEntity? me;
  final double progress;
  final Color color;
  final Color? track;

  @override
  Widget build(BuildContext context) {
    final inset = StoryRailDimens.uploadRing + StoryRailDimens.railRingGap;
    final photo = StoryRailDimens.railAvatar - 2 * inset;
    final person = me;
    return CustomPaint(
      painter: ProgressRingPainter(
        progress: progress,
        color: color,
        track: track,
        width: StoryRailDimens.uploadRing,
      ),
      child: SizedBox.square(
        dimension: StoryRailDimens.railAvatar,
        child: Padding(
          padding: EdgeInsets.all(inset),
          child: person == null
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.appColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                )
              : Opacity(
                  opacity: StoryRailDimens.uploadPhotoOpacity,
                  child: RailAvatar(person: person, size: photo),
                ),
        ),
      ),
    );
  }
}
