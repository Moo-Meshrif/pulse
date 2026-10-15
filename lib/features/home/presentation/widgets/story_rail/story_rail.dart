import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/story_rail_cubit.dart';
import '../../cubit/story_rail_state.dart';
import '../../dimens/home_dimens.dart';
import 'story_item.dart';
import 'your_story_item.dart';

/// The row of people: "Your story" first, then everyone else with a story (your own story is the first tile) (docs/specs/home/02-components.md
/// C2). It scrolls sideways without a scrollbar.
class StoryRail extends StatelessWidget {
  const StoryRail({super.key});

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: StoryRailDimens.railRowPadding,
      child: const _People(),
    ),
  );
}

class _People extends StatelessWidget {
  const _People();

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StoryRailCubit, StoryRailState>(
        buildWhen: (before, state) => before.items != state.items,
        builder: (context, state) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const YourStoryItem(),
            for (final person in state.items.where((item) => !item.isMe)) ...[
              SizedBox(width: StoryRailDimens.railGap),
              StoryItem(key: ValueKey(person.authorId), person: person),
            ],
          ],
        ),
      );
}
