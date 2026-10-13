import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entity/story_rail_item_entity.dart';
import 'story_header.dart';
import 'story_progress_bars.dart';

/// The top of the viewer while there is no story to show yet (loading, a person whose stories are still
/// coming): one empty progress bar and the person's avatar and name, then the close button, so a slow
/// load never traps anyone. No time and no "···" until there is a story. Without a [person] (a link that
/// carries none) it is the close button alone. Put it in a Stack.
class StoryLoadingTop extends StatelessWidget {
  const StoryLoadingTop({super.key, this.person, required this.onClose});

  final StoryRailItemEntity? person;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final person = this.person;
    final barsTop =
        MediaQuery.viewPaddingOf(context).top + StoryDimens.barBelowInset;
    if (person == null) return _CloseOnly(top: barsTop, onClose: onClose);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: barsTop,
          left: StoryDimens.barSide,
          right: StoryDimens.barSide,
          // One empty bar: the stories of the person are not known until they load.
          child: const StoryProgressBars(
            count: 1,
            index: 0,
            progress: AlwaysStoppedAnimation(0),
          ),
        ),
        Positioned(
          top: barsTop + StoryDimens.headerBelowBars,
          left: 0,
          right: 0,
          child: StoryHeader(person: person, postedAt: null, onClose: onClose),
        ),
      ],
    );
  }
}

class _CloseOnly extends StatelessWidget {
  const _CloseOnly({required this.top, required this.onClose});

  final double top;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      PositionedDirectional(
        top:
            top +
            StoryDimens.headerBelowBars +
            (StoryDimens.headerHeight - StoryDimens.headerButton) / 2,
        end: StoryDimens.headerEnd,
        child: Semantics(
          button: true,
          label: context.l10n.close,
          excludeSemantics: true,
          child: InkResponse(
            onTap: onClose,
            radius: StoryDimens.headerButton / 2,
            child: SizedBox.square(
              dimension: StoryDimens.headerButton,
              child: Center(
                child: AppSvgIcon(
                  AppAssets.close,
                  size: StoryDimens.closeIcon,
                  color: context.appColors.storyOnDark,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
