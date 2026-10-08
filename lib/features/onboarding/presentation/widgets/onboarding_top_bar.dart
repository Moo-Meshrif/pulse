import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_scale.dart';
import '../../../../core/widgets/widgets.dart';
import '../utils/enums/onboarding_top_bar_leading.dart';

/// Top bar of an onboarding page: logo or back arrow on the leading side, an optional
/// Skip on the trailing side. Screen 1: logo + Skip; 2: back + Skip; 3: back only.
class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.leading,
    this.onBack,
    this.onSkip,
  }) : assert(leading != OnboardingTopBarLeading.back || onBack != null);

  final OnboardingTopBarLeading leading;
  final VoidCallback? onBack;

  /// `null` hides Skip.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) => Padding(
    padding: leading == OnboardingTopBarLeading.back
        ? OnboardingDimens.topBarBackPadding
        : OnboardingDimens.topBarPadding,
    child: Row(
      children: [
        switch (leading) {
          OnboardingTopBarLeading.logo => const Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: LogoLockup(),
            ),
          ),
          OnboardingTopBarLeading.back => _BackButton(onPressed: onBack!),
        },
        if (leading == OnboardingTopBarLeading.back) const Spacer(),
        if (onSkip != null) _SkipButton(onPressed: onSkip!),
      ],
    ),
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.back,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onPressed,
      radius: OnboardingDimens.backButtonSize / 2,
      child: SizedBox.square(
        dimension: OnboardingDimens.backButtonSize,
        child: Center(
          child: AppSvgIcon(
            AppAssets.arrowBack,
            size: OnboardingDimens.backIconSize,
            color: context.appColors.textPrimary,
            directional: true,
          ),
        ),
      ),
    ),
  );
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final style = context.text.button.copyWith(
      fontSize: AppScale.scale(15),
      fontWeight: FontWeight.w600,
      color: context.appColors.textSecondary,
    );
    return InkResponse(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: OnboardingDimens.topBarHitHeight,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: OnboardingDimens.skipHorizontalPadding,
          ),
          child: Center(
            widthFactor: 1,
            child: Semantics(
              button: true,
              child: AppText(context.l10n.skip, style: style),
            ),
          ),
        ),
      ),
    );
  }
}
