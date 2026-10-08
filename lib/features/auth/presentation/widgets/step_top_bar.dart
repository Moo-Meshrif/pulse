import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import 'auth_back_button.dart';

/// The top bar of sign-up steps 1-6 (docs/specs/auth/02-components.md C7). Progress fills from the start
/// (right to left in RTL); [onSkip] adds a "Skip" button.
class StepTopBar extends StatelessWidget {
  const StepTopBar({
    super.key,
    required this.step,
    required this.isRequired,
    required this.onBack,
    this.onSkip,
  });

  static const totalSteps = 6;

  /// 1 to 6.
  final int step;
  final bool isRequired;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final stepText = context.l10n.stepOf(step);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: AppSpacing.headerSide,
        start: AppSpacing.headerBackSide,
        end: AppSpacing.headerSide,
      ),
      child: Row(
        children: [
          AuthBackButton(onPressed: onBack),
          Expanded(
            child: Semantics(
              container: true,
              label: stepText,
              value: '$step/$totalSteps',
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            stepText,
                            style: context.text.label,
                            color: colors.textSecondary,
                          ),
                        ),
                        AppText(
                          isRequired
                              ? context.l10n.required
                              : context.l10n.optional,
                          style: context.text.label,
                          color: isRequired
                              ? colors.primary
                              : colors.textSecondary,
                        ),
                      ],
                    ),
                    SizedBox(height: AuthDimens.stepBarSegmentsGap),
                    Row(
                      spacing: AuthDimens.progressSegmentGap,
                      children: [
                        for (var i = 1; i <= totalSteps; i++)
                          Expanded(
                            child: AnimatedContainer(
                              duration: AuthDimens.progressDuration,
                              curve: Curves.easeInOut,
                              height: AuthDimens.progressSegmentHeight,
                              decoration: BoxDecoration(
                                color: i <= step
                                    ? colors.primary
                                    : colors.switchOff,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill(
                                    AuthDimens.progressSegmentHeight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onSkip != null)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  AuthDimens.tapTarget,
                  AuthDimens.tapTarget,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: colors.textSecondary,
              ),
              child: AppText(
                context.l10n.skip,
                style: context.text.button,
                color: colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
