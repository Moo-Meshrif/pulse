import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';

/// Page indicator: the active dot is a 24x8 pill in `primary`, the others 8x8 `switchOff`.
/// Width and color animate over 250 ms ease-in-out (instant when the system asks to
/// reduce motion). Announced as "Page N of M".
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
