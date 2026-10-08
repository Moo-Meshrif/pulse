import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/splash_problem.dart';

/// The splash when it could not decide (offline, can't reach Pulse), with a pinned "Try again".
class SplashProblemView extends StatelessWidget {
  const SplashProblemView({
    super.key,
    required this.problem,
    required this.onRetry,
  });

  final SplashProblem problem;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return PinnedBottomCta(
      cta: PrimaryButton(
        label: context.l10n.tryAgain,
        onPressed: onRetry,
        expand: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: SplashDimens.headerTop),
                  child: const LogoLockup(),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SplashDimens.bodySide,
                        vertical: SplashDimens.circleToTitleGap,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox.square(
                              dimension: SplashDimens.problemCircle,
                              child: Center(
                                child: AppSvgIcon(
                                  problem.icon,
                                  size: SplashDimens.problemIcon,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: SplashDimens.circleToTitleGap),
                          Semantics(
                            header: true,
                            child: AppText(
                              problem.title(context),
                              style: context.text.messagesTitle,
                              color: colors.textPrimary,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: SplashDimens.titleToBodyGap),
                          AppText(
                            problem.body(context),
                            style: context.text.bodySm,
                            color: colors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
