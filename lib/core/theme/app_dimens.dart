import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Spacing scale (dp) from docs/specs/_theme/spacing-radius-shadows.md. Getters over [AppScale.scale]:
/// every token below (spacing, radius, shadow) is scaled with the window, so a feature that uses
/// them scales for free. Never `const`: the factor changes with the window.
abstract final class AppSpacing {
  static double get s4 => AppScale.scale(4);
  static double get s8 => AppScale.scale(8);
  static double get s12 => AppScale.scale(12);
  static double get s14 => AppScale.scale(14);
  static double get s16 => AppScale.scale(16);
  static double get s20 => AppScale.scale(20);
  static double get s24 => AppScale.scale(24);
  static double get s32 => AppScale.scale(32);

  /// Screen header side padding (8 on the back-arrow side).
  static double get headerSide => AppScale.scale(16);
  static double get headerBackSide => AppScale.scale(8);
  static double get cardMargin => AppScale.scale(12);
  static double get formSide => AppScale.scale(24);
  static double get fieldGap => AppScale.scale(14);
  static double get labelGap => AppScale.scale(6);
}

abstract final class AppRadius {
  static double get input => AppScale.scale(14);
  static double get media => AppScale.scale(16);
  static double get settingsTile => AppScale.scale(12);
  static double get card => AppScale.scale(22);
  static double get bottomSheetTop => AppScale.scale(28);
  static double get onboardingPanel => AppScale.scale(32);

  /// Pills, chips, buttons and switches are fully rounded: `height / 2`.
  static double pill(double height) => height / 2;
}

abstract final class AppShadows {
  /// "Onboarding cards": 0 12 30 #161A19 at 10-14%. The spec gives a range; 12% is the midpoint.
  static List<BoxShadow> get onboardingCards => [
    BoxShadow(
      color: const Color(0x1F161A19),
      offset: Offset(0, AppScale.scale(12)),
      blurRadius: AppScale.scale(30),
    ),
  ];
}

/// Values of the onboarding flow (docs/specs/onboarding/01-design-tokens.md, 02-components.md).
///
/// Sizes are the 390 x 844 design values, scaled responsively with [AppScale.size] (smaller on small phones, larger on tablets and desktop, clamped). Tap targets (44 dp boxes, the 56 dp button) never shrink.
/// Getters, not constants: the scale follows the window (`AppScaleScope`).
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
  static double get logoMarkSize => AppScale.scale(26);
  static double get logoMarkRadius => AppScale.scale(8);
  static double get logoToWordmarkGap => AppScale.scale(8);

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
        0,
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
