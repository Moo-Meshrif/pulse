import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// One segment per story of the person: finished ones full, the playing one filling with [progress],
/// the rest empty. They fill from the start side (the right in Arabic).
class StoryProgressBars extends StatelessWidget {
  const StoryProgressBars({
    super.key,
    required this.count,
    required this.index,
    required this.progress,
  });

  final int count;

  final int index;

  final ValueListenable<double> progress;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(width: StoryDimens.barGap),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(StoryDimens.barRadius),
              child: SizedBox(
                height: StoryDimens.barHeight,
                child: ColoredBox(
                  color: colors.storyTrack,
                  child: i == index
                      ? ValueListenableBuilder<double>(
                          valueListenable: progress,
                          builder: (_, value, _) =>
                              _Fill(fraction: value, color: colors.storyOnDark),
                        )
                      : _Fill(
                          fraction: i < index ? 1 : 0,
                          color: colors.storyOnDark,
                        ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Fill extends StatelessWidget {
  const _Fill({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: FractionallySizedBox(
      widthFactor: fraction.clamp(0.0, 1.0),
      child: ColoredBox(color: color, child: const SizedBox.expand()),
    ),
  );
}
