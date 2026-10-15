import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// Onboarding values (docs/specs/onboarding/01-design-tokens.md), 390 x 844 design sizes scaled with
/// [AppScale.size]. Tap targets never shrink. Getters, not constants: the scale follows the window.
abstract final class OnboardingDimens {
  // Top bar: padding 16 12 0 20 (top, trailing, bottom, leading).
  static EdgeInsetsDirectional get topBarPadding =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(20),
        AppScale.scale(16),
        AppScale.scale(12),
        0,
      );
  // With the back arrow the leading padding is 8 ("8 on the back-arrow side"): the 44 box
  // starts at x=8, so the 24 icon sits at x=18, as in the screenshots.
  static EdgeInsetsDirectional get topBarBackPadding =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(8),
        AppScale.scale(16),
        AppScale.scale(12),
        0,
      );
  static const double topBarHitHeight = 44; // tap target: fixed
  static double get skipHorizontalPadding => AppScale.scale(10);
  static const double backButtonSize = 44; // tap target: fixed
  static double get backIconSize => AppScale.scale(24);
  // Illustration panel: margin "20 20 0" in CSS shorthand = top 20, sides 20, bottom 0; height 420, radius 32.
  static EdgeInsetsDirectional get panelMargin =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(20),
        AppScale.scale(20),
        AppScale.scale(20),
        0,
      );
  static double get panelHeight => AppScale.scale(420);
  // Width / height of the illustration art (350 x 420, with 12% tolerance for the slight cover crop on wider phones).
  static const double panelAspect = 350 / 420 * 1.12;
  static double get panelRadius => AppRadius.onboardingPanel;
  // Text block: padding 32 24 0, title/body gap 12.
  static EdgeInsetsDirectional get textBlockPadding =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(24),
        AppScale.scale(32),
        AppScale.scale(24),
        AppScale.scale(12),
      );
  static double get titleBodyGap => AppScale.scale(12);
  // Footer: padding 0 24 36.
  static EdgeInsetsDirectional get footerPadding =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(24),
        0,
        AppScale.scale(24),
        AppScale.scale(36),
      );
  // Page dots: active 24x8, others 8x8, radius 4, gap 6.
  static double get dotActiveWidth => AppScale.scale(24);
  static double get dotSize => AppScale.scale(8);
  static double get dotRadius => AppScale.scale(4);
  static double get dotGap => AppScale.scale(6);
  // Buttons: height 56, pill radius 28, Next padding 0 28, arrow 20.
  static const double buttonHeight = 56; // tap target: fixed
  static const double buttonRadius = 28;
  static double get nextHorizontalPadding => AppScale.scale(28);
  static double get nextArrowSize => AppScale.scale(20);
  static double get nextLabelToArrowGap => AppScale.scale(8);
  // Page 3 footer, measured from the S3 screenshot (+-1 dp; the specs only gave unconfirmed
  // defaults 24 / 8 / bottom 36 for these): dots -> Get started 20, Get started -> Sign in row 15,
  // bottom padding 27.
  static EdgeInsetsDirectional get lastPageFooterPadding =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(24),
        0,
        AppScale.scale(24),
        AppScale.scale(27),
      );
  static double get dotsToGetStartedGap => AppScale.scale(20);
  static double get getStartedToSignInGap => AppScale.scale(15);
  static const double signInRowHeight = 44; // tap target: fixed
  // Motion: dots and page slide.
  static const pageAnimationDuration = Duration(milliseconds: 250);
  static const pageAnimationCurve = Curves.easeInOut;
}
