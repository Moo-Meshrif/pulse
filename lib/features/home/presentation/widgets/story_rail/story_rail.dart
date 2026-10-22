import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../story/domain/entity/story_rail_item_entity.dart';
import '../../cubit/story_rail/story_rail_cubit.dart';
import '../../cubit/story_rail/story_rail_state.dart';
import '../../dimens/home_dimens.dart';
import 'rail_label.dart';
import 'story_item.dart';
import 'your_story_item.dart';

/// The row of people: "Your story" first, then everyone else with a story (your own story is the first tile) (docs/specs/home/02-components.md
/// C2). It scrolls sideways without a scrollbar. Its height fits the longest name (one or two lines), so
/// short names leave no gap above the feed.
class StoryRail extends StatelessWidget {
  const StoryRail({super.key});

  int _labelLines(BuildContext context, List<String> labels) {
    final style = context.text.caption;
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    var lines = 1;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: RailLabel.maxLinesFor(label),
      )..layout(maxWidth: StoryRailDimens.railAvatar);
      lines = max(lines, painter.computeLineMetrics().length);
      painter.dispose();
    }
    return lines;
  }

  double _height(BuildContext context, List<String> labels) {
    final lines = _labelLines(context, labels);
    final line = TextPainter(
      text: TextSpan(text: 'A', style: context.text.caption),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final lineHeight = line.height;
    line.dispose();
    return StoryRailDimens.railRowPadding.vertical +
        StoryRailDimens.railAvatar +
        StoryRailDimens.railLabelGap +
        (lineHeight * lines).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<StoryRailCubit, StoryRailState>(
        buildWhen: (before, state) => before.items != state.items,
        builder: (context, state) {
          final others = state.items.where((item) => !item.isMe).toList();
          final labels = [
            context.l10n.storyYourStory,
            for (final person in others) person.username,
          ];
          return SizedBox(
            height: _height(context, labels),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: _People(others: others),
            ),
          );
        },
      );
}

class _People extends StatelessWidget {
  const _People({required this.others});

  final List<StoryRailItemEntity> others;

  @override
  Widget build(BuildContext context) => ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: StoryRailDimens.railRowPadding,
    itemCount: others.length + 1,
    separatorBuilder: (_, _) => SizedBox(width: StoryRailDimens.railGap),
    itemBuilder: (context, index) {
      if (index == 0) {
        return const Align(
          alignment: Alignment.topCenter,
          child: YourStoryItem(),
        );
      }
      final person = others[index - 1];
      return Align(
        alignment: Alignment.topCenter,
        child: StoryItem(key: ValueKey(person.authorId), person: person),
      );
    },
  );
}
