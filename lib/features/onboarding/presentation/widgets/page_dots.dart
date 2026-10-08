import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';

/// Page indicator, announced as "Page N of M". Animation is instant when the system asks to reduce motion.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : OnboardingDimens.pageAnimationDuration;
    return Semantics(
      label: context.l10n.onboardingPageIndicator(index + 1, count),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) SizedBox(width: OnboardingDimens.dotGap),
            AnimatedContainer(
              duration: duration,
              curve: OnboardingDimens.pageAnimationCurve,
              width: i == index
                  ? OnboardingDimens.dotActiveWidth
                  : OnboardingDimens.dotSize,
              height: OnboardingDimens.dotSize,
              decoration: BoxDecoration(
                color: i == index ? colors.primary : colors.switchOff,
                borderRadius: BorderRadius.circular(OnboardingDimens.dotRadius),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
