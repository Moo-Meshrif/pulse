import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
import '../../../../story/domain/entity/story_viewer_args.dart';
import 'rail_avatar.dart';
import 'rail_label.dart';

/// One person on the rail: their photo in a ring (green while there is something new, grey once seen) and
/// their username. Opens their stories, growing from the circle.
class StoryItem extends StatelessWidget {
  const StoryItem({super.key, required this.person, this.label, this.onAdd});

  final StoryRailItemEntity person;

  /// Replaces the username under the circle ("Your story" for your own).
  final String? label;

  /// Shows a small plus on the circle that calls this: your own item, to add another story.
  final VoidCallback? onAdd;

  void _open(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(box.size.center(Offset.zero));
    AppNavigator.push<void>(
      context,
      AppRoutes.storyOf(person.authorId),
      rootNavigator: true,
      arguments: StoryViewerArgs(origin: origin, person: person),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final inset = StoryDimens.railRing + StoryDimens.railRingGap;
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label ?? person.username,
      child: GestureDetector(
        onTap: () => _open(context),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Badged(
              onAdd: onAdd,
              child: Container(
                width: StoryDimens.railAvatar,
                height: StoryDimens.railAvatar,
                padding: EdgeInsets.all(StoryDimens.railRingGap),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: person.allSeen ? colors.border : colors.primary,
                    width: StoryDimens.railRing,
                  ),
                ),
                child: RailAvatar(
                  person: person,
                  size: StoryDimens.railAvatar - 2 * inset,
                ),
              ),
            ),
            RailLabel(label ?? person.username),
          ],
        ),
      ),
    );
  }
}

class _Badged extends StatelessWidget {
  const _Badged({required this.child, required this.onAdd});

  final Widget child;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final onAdd = this.onAdd;
    if (onAdd == null) return child;
    final colors = context.appColors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onAdd,
            child: Container(
              width: StoryDimens.railBadge,
              height: StoryDimens.railBadge,
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.surface,
                  width: StoryDimens.railBadgeBorder,
                ),
              ),
              child: Icon(
                Icons.add,
                size: StoryDimens.railBadge - 6,
                color: colors.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
