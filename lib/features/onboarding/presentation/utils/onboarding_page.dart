import 'package:flutter/widgets.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/l10n.dart';
import '../../../../core/theme/app_colors.dart';

/// What differs between the three onboarding pages: panel fill, illustration and copy.
/// The layout is shared (docs/specs/onboarding/00-overview.md).
class OnboardingPage {
  const OnboardingPage({
    required this.fill,
    required this.imageAsset,
    required this.title,
    required this.body,
  });

  final Color Function(AppColors colors) fill;
  final String Function(Locale locale) imageAsset;
  final String Function(AppLocalizations l10n) title;
  final String Function(AppLocalizations l10n) body;
}

final onboardingPages = <OnboardingPage>[
  OnboardingPage(
    fill: (c) => c.primarySoft,
    imageAsset: AppAssets.onboarding1,
    title: (l) => l.onboarding1Title,
    body: (l) => l.onboarding1Body,
  ),
  OnboardingPage(
    fill: (c) => c.textPrimary,
    imageAsset: AppAssets.onboarding2,
    title: (l) => l.onboarding2Title,
    body: (l) => l.onboarding2Body,
  ),
  OnboardingPage(
    fill: (c) => c.primarySoft,
    imageAsset: AppAssets.onboarding3,
    title: (l) => l.onboarding3Title,
    body: (l) => l.onboarding3Body,
  ),
];
