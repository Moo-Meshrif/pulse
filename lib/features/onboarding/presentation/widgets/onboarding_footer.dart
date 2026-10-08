import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/widgets.dart';
import 'page_dots.dart';
import 'sign_in_link.dart';

/// Footer of one onboarding page. It lives inside the page's scroll view, so it sits at the bottom on tall
/// screens and scrolls with the content on short ones.
class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onGetStarted,
    required this.onSignIn,
  });

  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLast = index == count - 1;
    final dots = PageDots(count: count, index: index);

    return Padding(
      padding: isLast
          ? OnboardingDimens.lastPageFooterPadding
          : OnboardingDimens.footerPadding,
      child: isLast
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                dots,
                SizedBox(height: OnboardingDimens.dotsToGetStartedGap),
                PrimaryButton(
                  label: l10n.getStarted,
                  onPressed: onGetStarted,
                  expand: true,
                ),
                SizedBox(height: OnboardingDimens.getStartedToSignInGap),
                SignInLink(onPressed: onSignIn),
              ],
            )
          : Row(
              children: [
                dots,
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    // Wrap the height: a bounded Align would fill the free height and centre the button in it.
                    heightFactor: 1,
                    child: PrimaryButton(
                      label: l10n.next,
                      onPressed: onNext,
                      trailingIconAsset: AppAssets.arrowForward,
                      trailingIconSize: OnboardingDimens.nextArrowSize,
                      trailingIconGap: OnboardingDimens.nextLabelToArrowGap,
                      horizontalPadding: OnboardingDimens.nextHorizontalPadding,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
