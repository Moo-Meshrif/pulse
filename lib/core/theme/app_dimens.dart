import 'package:flutter/material.dart';

import 'app_scale.dart';

/// Spacing scale (dp) from docs/specs/_theme/spacing-radius-shadows.md. Getters over [AppScale.scale],
/// never `const`: the factor changes with the window.
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

  /// Dialog card (= bottom sheet top, 28).
  static double get dialog => AppScale.scale(28);
  static double get checkbox => AppScale.scale(6);
  static double get logoTile => AppScale.scale(14);
  static double get iconTile => AppScale.scale(22);

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

  /// Dialog card: 0 12 30 #161A19 @ 12%, the same shadow as the onboarding cards.
  static List<BoxShadow> get dialog => onboardingCards;
}

/// Shared dialog shell and its content (docs/specs/auth/01-design-tokens.md, 02-components.md C14).
abstract final class DialogDimens {
  /// Backdrop blur under the scrim (sigma x and y). A blur radius is not a layout size: not scaled.
  static const double backdropBlurSigma = 12;

  /// The card is `screen width - 2 * margin`, at most [maxWidth].
  static double get margin => AppScale.scale(24);
  static double get maxWidth => AppScale.scale(342);
  static EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(24),
    vertical: AppScale.scale(28),
  );
  static double get iconCircle => AppScale.scale(56);
  static double get icon => AppScale.scale(24);
  static double get iconToTitleGap => AppScale.scale(16);
  static double get titleToMessageGap => AppScale.scale(8);
  static double get messageToActionsGap => AppScale.scale(24);
  static double get actionGap => AppScale.scale(12);
  static double get stackedActionGap => AppScale.scale(8);

  static const Duration transition = Duration(milliseconds: 180);
  static const double enterScale = 0.96;
}

/// The loading indicator shown while a screen waits for its first data.
abstract final class LoadingDimens {
  static double get size => AppScale.scale(32);
  static const double stroke = 3; // unscaled: stroke
}

/// The splash (docs/specs/auth/screens/s13-splash.md). All `[estimated]` from the screenshots (Q26).
abstract final class SplashDimens {
  static double get logoTile => AppScale.scale(72);
  static double get logoTileRadius => AppScale.scale(22);
  static double get logoToWordmarkGap => AppScale.scale(14);
  static double get spinnerSize => AppScale.scale(28);
  static const double spinnerStroke = 3; // unscaled: stroke
  static double get spinnerBottom =>
      AppScale.scale(38); // above the bottom safe area
  static double get headerTop => AppScale.scale(24); // below the top safe area
  static double get problemCircle => AppScale.scale(96);
  static double get problemIcon => AppScale.scale(40);
  static double get circleToTitleGap => AppScale.scale(24);
  static double get titleToBodyGap => AppScale.scale(8);
  static double get bodySide => AppScale.scale(40);
}

/// Pill buttons of the auth flow: primary states, outline, soft, danger
/// (docs/specs/auth/01-design-tokens.md "button states", "outline pill button").
abstract final class AuthButtonDimens {
  /// Primary button disabled fill: `primary` @ 40%.
  static const double disabledOpacity = 0.4;
  static double get spinnerSize => AppScale.scale(20);
  static const double spinnerStroke = 2; // unscaled: stroke
  static const double outlineBorderWidth = 1; // unscaled: hairline
  /// Outline pills have no fixed height: vertical padding 15 (+ 16/700 label).
  static double get outlineVerticalPadding => AppScale.scale(15);

  /// Soft and danger pills (dialog actions, S9, S10).
  static const double pillHeight = 48; // tap target: fixed
}

/// Auth form fields, tiles, chips, checkbox, avatars, OTP, progress and strength bars
/// (docs/specs/auth/01-design-tokens.md "New / differs", 02-components.md).
abstract final class AuthDimens {
  // Input: padding 15 v / 16 h, no fixed height; 1 px border, 1.5 on focus and error.
  static EdgeInsets get inputPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(16),
    vertical: AppScale.scale(15),
  );
  static const double inputBorderWidth = 1; // unscaled: hairline
  static const double inputActiveBorderWidth = 1.5; // unscaled: focus / error
  // Password eye: 22 icon in a 44 tap target.
  static double get eyeIcon => AppScale.scale(22);
  static const double eyeTapTarget = 44; // tap target: fixed

  // Logo tile 48 (radius 14) and icon tile 72 (radius 22, icon 32).
  static double get logoTile => AppScale.scale(48);
  static double get iconTile => AppScale.scale(72);
  static double get iconTileIcon => AppScale.scale(32);
  static double get tileToTitleGap => AppScale.scale(24);

  // Sign-up progress: 6 segments, height 4, gap 4.
  static double get progressSegmentHeight => AppScale.scale(4);
  static double get progressSegmentGap => AppScale.scale(4);
  static const Duration progressDuration = Duration(milliseconds: 200);

  // Password strength: 4 segments, height 4, gap 6; the short S11 variant is 68 wide, gap 4.
  static double get strengthSegmentHeight => AppScale.scale(4);
  static double get strengthSegmentGap => AppScale.scale(6);
  static double get strengthShortSegmentWidth => AppScale.scale(68);
  static double get strengthShortSegmentGap => AppScale.scale(4);

  // OTP box ~50 x 60 [estimated], gap 8, radius 14; borders: idle 1, filled/error 1.5, focused 2.
  static double get otpBoxWidth => AppScale.scale(50);
  static double get otpBoxHeight => AppScale.scale(60);
  static double get otpBoxGap => AppScale.scale(8);
  static const double otpMinBoxWidth = 44; // tap target: fixed
  static const double otpIdleBorderWidth = 1; // unscaled: hairline
  static const double otpFilledBorderWidth = 1.5; // unscaled
  static const double otpFocusedBorderWidth = 2; // unscaled

  // Chips: interest h44, gender h40, h-padding 18, label 15/700 (`name`); selected shows a 16 check + gap 6.
  static double get interestChipHeight => AppScale.scale(44);
  static double get genderChipHeight => AppScale.scale(40);
  static double get segmentedChipHeight => AppScale.scale(40); // [estimated]
  static double get chipHorizontalPadding => AppScale.scale(18);
  static double get chipWrapSpacing => AppScale.scale(10);
  static double get interestChipRunSpacing => AppScale.scale(12);
  static double get chipCheckSize => AppScale.scale(16);
  static double get chipCheckGap => AppScale.scale(6);
  static const double chipMinTapHeight = 44; // tap target: fixed
  static const double chipBorderWidth = 1; // unscaled: hairline

  // Avatars: upload circle 88 (dashed 1.5, camera 28, badge 28 + plus 14), list circle 48.
  static double get avatarUpload => AppScale.scale(88);
  static const double avatarDashedWidth = 1.5; // unscaled: stroke
  static double get avatarCameraIcon => AppScale.scale(28);
  static double get avatarBadge => AppScale.scale(28);
  static double get avatarBadgePlus => AppScale.scale(14);
  static double get avatarList => AppScale.scale(48);

  // Checkbox: 24 square, radius 6, check 16 (20 on S11).
  static double get checkbox => AppScale.scale(24);
  static double get checkboxCompact => AppScale.scale(20);
  static double get checkboxCheck => AppScale.scale(16);
  static const double checkboxBorderWidth = 1; // unscaled: hairline
  static double get checkboxToLabelGap => AppScale.scale(12);

  // Password rules list (S11): a 6 dot, or a check once met, in a fixed slot so the text never shifts.
  static double get ruleDot => AppScale.scale(6);
  static double get ruleIconSlot => AppScale.scale(14);
  static double get ruleCheck => AppScale.scale(14);
  static double get ruleIconGap => AppScale.scale(8);
  static double get ruleRowGap => AppScale.scale(8);
  static double get checkboxCheckCompact => AppScale.scale(14);

  // Step bar (S3-S8): back / Skip tap targets 44.
  static const double tapTarget = 44; // tap target: fixed
  static double get stepBarIcon => AppScale.scale(24);
  static double get stepBarSegmentsGap => AppScale.scale(8);

  // "or continue with" divider: 1 px lines, gap 12.
  static const double dividerLineWidth = 1; // unscaled: hairline
  static double get dividerGap => AppScale.scale(12);
  static const double dividerLabelMaxShare =
      0.6; // share of the row the label may take before it wraps
  static double get socialGap => AppScale.scale(12);

  // Sign in (S1): logo ~56 from the top [estimated], 32 above the form, 24 above the button and the
  // divider, 20 above the social row, the footer ~28 above the bottom.
  static double get signInTopGap => AppScale.scale(56);
  static double get signInFormGap => AppScale.scale(32);
  static double get signInSectionGap => AppScale.scale(24);
  static double get signInSocialGap => AppScale.scale(20);
  static double get signInFooterBottom => AppScale.scale(28);
  static const double linkTapHeight = 44; // tap target: fixed

  // Forgot password (S2): the lock tile ~24 under the back arrow [estimated], 32 above the field, 24
  // above the button. S9 footer: 20 above the links, 8 between them.
  static double get forgotTileTopGap => AppScale.scale(24);
  static double get headerToFormGap => AppScale.scale(32);
  static double get formToButtonGap => AppScale.scale(24);
  static double get linkRowTopGap => AppScale.scale(20);
  static double get linkRowGap => AppScale.scale(8);
}

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
