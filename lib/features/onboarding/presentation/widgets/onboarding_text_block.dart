import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';

/// Title + body under the panel, start-aligned. The block's top is fixed, so a one-line
/// title leaves the body higher than a two-line one.
class OnboardingTextBlock extends StatelessWidget {
  const OnboardingTextBlock({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: OnboardingDimens.textBlockPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: AppText(
              title,
              style: context.text.onboardingTitle,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: OnboardingDimens.titleBodyGap),
          AppText(
            body,
            style: context.text.subtitle,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
