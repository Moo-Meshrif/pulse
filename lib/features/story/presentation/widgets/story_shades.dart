import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

class StoryShades extends StatelessWidget {
  const StoryShades({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final top = colors.storyShadeTop;
    final bottom = colors.storyShadeBottom;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: StoryDimens.shadeTop,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [top, top.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: StoryDimens.shadeBottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bottom.withValues(alpha: 0), bottom],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
