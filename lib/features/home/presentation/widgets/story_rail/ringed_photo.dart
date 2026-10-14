import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
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
    final inset = StoryDimens.uploadRing + StoryDimens.railRingGap;
    final photo = StoryDimens.railAvatar - 2 * inset;
    final person = me;
    return CustomPaint(
      painter: ProgressRingPainter(
        progress: progress,
        color: color,
        track: track,
        width: StoryDimens.uploadRing,
      ),
      child: SizedBox.square(
        dimension: StoryDimens.railAvatar,
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
                  opacity: StoryDimens.uploadPhotoOpacity,
                  child: RailAvatar(person: person, size: photo),
                ),
        ),
      ),
    );
  }
}
