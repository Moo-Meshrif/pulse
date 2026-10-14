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

  /// Floating nav bar: 0 12 32 #161A19 @ 16% (docs/specs/control/01-design-tokens.md).
  static List<BoxShadow> get navBar => [
    BoxShadow(
      color: const Color(0x29161A19),
      offset: Offset(0, AppScale.scale(12)),
      blurRadius: AppScale.scale(32),
    ),
  ];

  /// The circle behind the selected tab of the nav bar. No offset, so it is the same on every side. It has
  /// to fade out within the 12 dp between the circle and the bar's edge ((68 - 44) / 2): a wider one is cut
  /// off at the top and bottom and the circle reads as an oval.
  static List<BoxShadow> get navActiveTab => [
    BoxShadow(color: const Color(0x1F161A19), blurRadius: AppScale.scale(8)),
  ];

  /// Bottom sheet: 0 -10 40 #161A19 @ 18%.
  static List<BoxShadow> get bottomSheet => [
    BoxShadow(
      color: const Color(0x2E161A19),
      offset: Offset(0, -AppScale.scale(10)),
      blurRadius: AppScale.scale(40),
    ),
  ];

  /// Story sticker (location): 0 6 16 black @ 25%.
  static List<BoxShadow> get sticker => [
    BoxShadow(
      color: const Color(0x40000000),
      offset: Offset(0, AppScale.scale(6)),
      blurRadius: AppScale.scale(16),
    ),
  ];

  /// Story text overlay: 0 2 12 black @ 35%.
  static List<BoxShadow> get textOverlay => [
    BoxShadow(
      color: const Color(0x59000000),
      offset: Offset(0, AppScale.scale(2)),
      blurRadius: AppScale.scale(12),
    ),
  ];

  /// Soft glow under the primary action of an empty or failed page: 0 8 20 primary @ 28%.
  static List<BoxShadow> get primaryAction => [
    BoxShadow(
      color: const Color(0x472E6B63),
      offset: Offset(0, AppScale.scale(8)),
      blurRadius: AppScale.scale(20),
    ),
  ];
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

/// The page loaders (core/widgets/app_loading_view.dart, the "Page loading" board). Line widths; the
/// line's height follows its 184 x 88 frame.
abstract final class LoadingDimens {
  static double get pageWidth => AppScale.scale(100);
  static double get refreshWidth => AppScale.scale(56);
  static double get loadMoreWidth => AppScale.scale(44);
  static double get refreshBand => AppScale.scale(64);
  static double get loadMoreBand => AppScale.scale(72);
  static double get labelGap => AppScale.scale(16);
}

/// The empty / failed page (core/widgets/app_empty/, the "Empty and failed" board).
abstract final class AppEmptyDimens {
  static double get icon => AppScale.scale(72);
  static double get iconToTitleGap => AppScale.scale(24);
  static double get titleToBodyGap => AppScale.scale(10);
  static double get bodyToActionsGap => AppScale.scale(28);
  static double get bodyMaxWidth => AppScale.scale(300);
  static double get actionMaxWidth => AppScale.scale(280);
  static double get primaryHeight => AppScale.scale(52);
  static const double linkHeight = 44; // tap target: fixed
  static double get side => AppScale.scale(32);
  static double get rise => AppScale.scale(12);
  static double get float => AppScale.scale(3);
  static const Duration enter = Duration(milliseconds: 280);
  static const Duration floatLoop = Duration(
    milliseconds: 1600,
  ); // one way; a full cycle is 3.2 s
}

/// The loading overlay (core/widgets/loading_overlay/): a frosted scrim and a heartbeat line (a Lottie
/// animation that loops on its own, 1600 ms).
abstract final class OverlayDimens {
  static double get lineWidth => AppScale.scale(120);
  static double get labelGap => AppScale.scale(18);
  static double get progressGap => AppScale.scale(14);
  static double get progressTrackWidth => AppScale.scale(140);
  static double get progressTrackHeight => AppScale.scale(3);
  static double get progressTrackRadius => AppScale.scale(2);
  static double get percentGap => AppScale.scale(10);
  static double get percentWidth => AppScale.scale(34);
  static double get rise => AppScale.scale(8);
  static const double blur = 20; // unscaled: blur sigma
  static const Duration enter = Duration(milliseconds: 220);
  static const Duration exit = Duration(milliseconds: 160);
}

/// The splash (docs/specs/auth/screens/s13-splash.md). All `[estimated]` from the screenshots (Q26).
abstract final class SplashDimens {
  static double get logoTile => AppScale.scale(72);
  static double get logoTileRadius => AppScale.scale(22);
  static double get logoToWordmarkGap => AppScale.scale(14);
  static double get lineWidth => AppScale.scale(80);
  static double get wordmarkToLineGap => AppScale.scale(36);
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

  /// The heartbeat line in a loading button; its frame is 88/184 as tall, so it fits the 48 pill too.
  static double get loaderWidth => AppScale.scale(72);
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
  static const double avatarBadgeRing = 2; // unscaled: stroke

  // Follow step (S8): the Follow pill is ~34 high (14 text + 8 v-padding), the tabs ~40, 20 between
  // the blocks; Interests (S7): skeleton chips.
  static double get followPillHeight => AppScale.scale(34);
  static double get followTabHeight => AppScale.scale(40);
  static double get followSectionGap => AppScale.scale(20);
  static double get followSkeletonName => AppScale.scale(120);
  static double get followSkeletonMeta => AppScale.scale(80);
  static double get skeletonLineHeight => AppScale.scale(12);
  static double get interestSkeletonWidth => AppScale.scale(96);
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

  // Sign in after a session ended (S14), all [estimated] from the screenshots
  static double get signedOutBannerGap => AppScale.scale(28);
  static double get signedOutBannerPadding => AppScale.scale(14);
  static double get signedOutBannerIcon => AppScale.scale(18);
  static double get signedOutBannerIconNudge => AppScale.scale(2);
  static double get signedOutBannerTitleGap => AppScale.scale(2);
  static double get accountAvatar => AppScale.scale(40);
  static double get accountCardHeight => AppScale.scale(62);
  static const double linkTapHeight = 44; // tap target: fixed

  // Forgot password (S2): the lock tile ~24 under the back arrow [estimated], 32 above the field, 24
  // above the button. S9 footer: 20 above the links, 8 between them.
  static double get forgotTileTopGap => AppScale.scale(24);
  static double get headerToFormGap => AppScale.scale(32);
  static double get formToButtonGap => AppScale.scale(24);
  static double get linkRowTopGap => AppScale.scale(20);
  static double get linkRowGap => AppScale.scale(8);

  // Sign-up Account (S3) [estimated, ~ in the spec]: 24 under the step bar and above the fields, 10 under
  // the password, 18 above the terms line, 14 above the note, 24 above the divider, 16 above the social row.
  static double get signUpTopGap => AppScale.scale(24);
  static double get signUpMeterGap => AppScale.scale(10);
  static double get signUpTermsGap => AppScale.scale(18);
  static double get signUpNoteGap => AppScale.scale(14);
  static double get signUpDividerGap => AppScale.scale(24);
  static double get signUpSocialGap => AppScale.scale(16);

  // Verify email (S4): the code boxes ~32 under the header, the resend row ~24 under them, the link
  // under the button 12.
  static double get otpTopGap => AppScale.scale(32);
  static double get resendTopGap => AppScale.scale(24);
  static double get ctaLinkGap => AppScale.scale(12);
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

/// The floating glass nav bar of the main shell (docs/specs/control/01-design-tokens.md).
/// Tap targets stay fixed; everything else scales.
abstract final class NavDimens {
  static double get sideInset => AppScale.scale(16);

  /// Gap above the bottom system inset (add `MediaQuery.viewPadding.bottom`).
  static double get bottomInset => AppScale.scale(18);
  static double get height => AppScale.scale(68);
  static double get radius => AppScale.scale(34);
  static double get padding => AppScale.scale(6);
  static const double itemHeight = 56; // tap target: fixed
  static double get itemGap => AppScale.scale(4);
  static double get bubble => AppScale.scale(44);
  static double get icon => AppScale.scale(22);
  static double get plusIcon => AppScale.scale(26);
  static const double blurSigma = 22; // unscaled: blur sigma
  static const double borderWidth = 1;
  static const double highlightHeight = 1;

  /// Bottom padding every tab's scroll view reserves: height 68 + bottom 18 + 18 (add the bottom inset).
  static double get contentClearance => AppScale.scale(104);

  // Count badge on the Chat item.
  static double get badgeMin => AppScale.scale(18);
  static double get badgeRadius => AppScale.scale(9);
  static double get badgeBorder => AppScale.scale(2);
  static double get badgeHorizontalPadding => AppScale.scale(4);
  static double get badgeTop => AppScale.scale(9);

  /// The badge starts this far past the item's centre (mirrored in RTL).
  static double get badgeCenterOffset => AppScale.scale(3);
  static const int badgeMax = 99;

  /// A pressed item fades to this opacity (no ripple).
  static const double pressedOpacity = 0.9;

  // Motion.
  static const bubbleDuration = Duration(milliseconds: 220);
  static const bubbleCurve = Curves.easeOutCubic;
  static const iconFadeDuration = Duration(milliseconds: 150);
  static const hideDuration = Duration(milliseconds: 200);
}

/// The shared bottom-sheet shell and its option rows: the Create sheet, later the post options sheet
/// (docs/specs/control/01-design-tokens.md > Create sheet).
abstract final class BottomSheetDimens {
  static double get topPadding => AppScale.scale(10);
  static double get sidePadding => AppScale.scale(16);

  /// Bottom padding; also the `bottomSpace` of the sheet's `AppSafeArea`.
  static double get bottomPadding => AppScale.scale(34);
  static double get grabberWidth => AppScale.scale(40);
  static double get grabberHeight => AppScale.scale(5);
  static double get grabberRadius => AppScale.scale(3);

  /// Measured from the Create sheet screenshot (+-1 dp): grabber to title row, title row to content.
  static double get grabberToTitleGap => AppScale.scale(12);
  static double get titleToContentGap => AppScale.scale(12);
  static const double closeButton = 44; // tap target: fixed
  static double get closeIcon => AppScale.scale(18);

  // Option rows.
  static double get optionPadding => AppScale.scale(16);
  static double get optionRadius => AppScale.scale(20);
  static double get optionGap => AppScale.scale(10);
  static double get optionContentGap => AppScale.scale(14);
  static const double optionMinHeight = 56; // tap target: fixed
  static double get optionTile => AppScale.scale(48);
  static double get optionTileRadius => AppScale.scale(16);
  static double get optionTileIcon => AppScale.scale(24);
  static double get optionChevron => AppScale.scale(18);
  static double get optionSubtitleGap => AppScale.scale(2);
}

/// Story rail and viewer (docs/specs/story/source-tokens.md §1-§3). Tap targets stay fixed; the rest scales.
abstract final class StoryDimens {
  // Rail.
  static double get railAvatar => AppScale.scale(64);
  static double get railGap => AppScale.scale(14);
  static double get railRing => AppScale.scale(2.5);
  static double get railRingGap => AppScale.scale(3);
  static double get railPhoto => AppScale.scale(52);
  static double get railLabelGap => AppScale.scale(6);
  static double get uploadRing => AppScale.scale(3);
  static const double uploadPhotoOpacity = 0.7;
  static double get plusBadge => AppScale.scale(20);
  static double get plusBadgeBorder => AppScale.scale(2);
  static double get plusIcon => AppScale.scale(24);
  static double get emptyRingDash => AppScale.scale(2);
  static EdgeInsets get railTitlePadding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    AppScale.scale(4),
    AppScale.scale(16),
    AppScale.scale(10),
  );
  static EdgeInsets get railRowPadding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    AppScale.scale(4),
    AppScale.scale(16),
    AppScale.scale(12),
  );

  // Progress bars and header.
  static double get barTop => AppScale.scale(54);

  /// The bars sit this far below the status bar (54 on the 46 dp inset of the design frame).
  static double get barBelowInset => AppScale.scale(8);

  /// The header starts this far below the top of the bars (66 - 54).
  static double get headerBelowBars => AppScale.scale(12);
  static double get barSide => AppScale.scale(10);
  static double get barGap => AppScale.scale(4);
  static double get barHeight => AppScale.scale(3);
  static double get barRadius => AppScale.scale(2);
  static double get headerTop => AppScale.scale(66);
  static double get headerStart => AppScale.scale(12);
  static double get headerEnd => AppScale.scale(6);
  static double get headerHeight => AppScale.scale(48);
  static double get headerGap => AppScale.scale(10);
  static double get headerAvatar => AppScale.scale(36);
  static double get headerAvatarRing => AppScale.scale(2);
  static const double headerButton = 44; // tap target: fixed
  static double get moreIcon => AppScale.scale(22);
  static double get closeIcon => AppScale.scale(24);

  /// The buffering line's width.
  static double get loaderWidth => AppScale.scale(56);
  static double get shadeTop => AppScale.scale(170);
  static double get shadeBottom => AppScale.scale(200);

  // Reply bar.
  static double get replySide => AppScale.scale(12);
  static double get replyBottom => AppScale.scale(30);
  static double get replyGap => AppScale.scale(10);
  static double get replyHeight => AppScale.scale(48);
  static double get replyBorder => AppScale.scale(1.5);
  static double get replyPadding => AppScale.scale(18);
  static const double replyAction = 44; // tap target: fixed
  static double get likeIcon => AppScale.scale(28);
  static double get sendIcon => AppScale.scale(26);
  static double get countIcon => AppScale.scale(18);

  // Location sticker.
  static double get stickerHeight => AppScale.scale(40);
  static double get stickerRadius => AppScale.scale(12);
  static double get stickerPadding => AppScale.scale(14);
  static double get stickerGap => AppScale.scale(6);
  static double get stickerPin => AppScale.scale(18);
  static const double stickerRotationDegrees = -4;

  // Viewers sheet (light).
  static double get viewersHeight => AppScale.scale(430);
  static const double viewersMaxFraction = 0.9;
  static double get viewersHeaderIcon => AppScale.scale(22);
  static double get viewersHeaderGap => AppScale.scale(8);
  static const double viewersAction = 40; // tap target: fixed
  static double get viewersActionIcon => AppScale.scale(20);
  static double get viewerRowHeight => AppScale.scale(60);
  static double get viewerRowGap => AppScale.scale(12);
  static double get viewerAvatar => AppScale.scale(40);
  static double get viewerLikedIcon => AppScale.scale(20);
}

/// Story camera and edit screens (source-tokens.md §4).
abstract final class StoryCameraDimens {
  static double get topBarTop => AppScale.scale(56);

  /// 56 on the design frame, whose status inset is 46: this far below the status bar.
  static double get topBarBelowInset => AppScale.scale(10);
  static double get topBarSide => AppScale.scale(8);
  static double get topBarHeight => AppScale.scale(48);
  static const double roundControl = 48; // tap target: fixed
  static double get closeIcon => AppScale.scale(26);
  static double get controlIcon => AppScale.scale(24);

  static double get shutter => AppScale.scale(80);
  static double get shutterRing => AppScale.scale(5);
  static double get shutterDot => AppScale.scale(64);
  static double get recordRing => AppScale.scale(92);
  static double get recordStop => AppScale.scale(40);
  static double get recordStopRadius => AppScale.scale(12);
  static double get bottomRowBottom => AppScale.scale(40);
  static double get bottomRowSide => AppScale.scale(34);
  static double get galleryThumb => AppScale.scale(44);
  static double get galleryRadius => AppScale.scale(12);
  static double get galleryBorder => AppScale.scale(2);
  static double get hintBottom => AppScale.scale(150);
  static double get timerHeight => AppScale.scale(30);
  static double get timerPadding => AppScale.scale(12);
  static double get timerDot => AppScale.scale(8);

  // Edit tools and bottom actions.
  static double get toolRight => AppScale.scale(12);
  static double get toolTop => AppScale.scale(120);

  /// 120 on the design frame (inset 46): this far below the status bar.
  static double get toolBelowInset => AppScale.scale(74);

  /// Gap between the delete zone and the action pills.
  static double get deleteZoneAbove => AppScale.scale(16);
  static double get toolGap => AppScale.scale(12);
  static const double tool = 44; // tap target: fixed
  static double get toolIcon => AppScale.scale(22);
  static double get actionSide => AppScale.scale(12);
  static double get actionBottom => AppScale.scale(30);
  static double get actionGap => AppScale.scale(10);
  static double get actionHeight => AppScale.scale(52);
  static double get audienceAvatar => AppScale.scale(26);
  static double get audienceAvatarRing => AppScale.scale(2);
  static double get sharePill => AppScale.scale(120);
  static double get shareChevron => AppScale.scale(18);
  static double get deleteZone => AppScale.scale(48);
  static const double deleteZoneHoverScale = 1.2;
  static const double stickerMinScale = 0.5;
  static const double stickerMaxScale = 3;
}

/// Story options sheets, delete dialog and paused chip (source-tokens.md §5-§6).
abstract final class StorySheetDimens {
  /// 128 on the design frame, whose status inset is 46: this far below the status bar.
  static double get pausedChipBelowInset => AppScale.scale(82);
  static double get pausedChipHeight => AppScale.scale(30);
  static double get pausedChipPadding => AppScale.scale(12);
  static double get pausedChipGap => AppScale.scale(6);
  static double get pausedChipIcon => AppScale.scale(14);

  static double get radius => AppScale.scale(28);
  static EdgeInsets get padding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    AppScale.scale(10),
    AppScale.scale(16),
    AppScale.scale(34),
  );

  /// Bottom padding; also the `bottomSpace` of the sheet's `AppSafeArea`.
  static double get bottomPadding => AppScale.scale(34);
  static double get gap => AppScale.scale(12);
  static double get titlePadding => AppScale.scale(4);
  static double get groupRadius => AppScale.scale(18);
  static const double separator = 1; // unscaled: hairline
  static const double rowMinHeight = 56; // tap target: fixed
  static double get rowPaddingV => AppScale.scale(8);
  static double get rowPaddingH => AppScale.scale(16);
  static double get rowGap => AppScale.scale(14);
  static double get rowIcon => AppScale.scale(22);
  static double get chevron => AppScale.scale(18);
  static const double reasonRowHeight = 52; // tap target: fixed

  // Delete dialog.
  static double get dialogRadius => AppScale.scale(28);
  static double get dialogMargin => AppScale.scale(32);
  static EdgeInsets get dialogPadding => EdgeInsets.fromLTRB(
    AppScale.scale(22),
    AppScale.scale(26),
    AppScale.scale(22),
    AppScale.scale(18),
  );
  static double get dialogIcon => AppScale.scale(40);
  static double get dialogTitleTop => AppScale.scale(14);
  static double get dialogBodyTop => AppScale.scale(8);
  static double get dialogDeleteTop => AppScale.scale(22);
  static double get dialogDeleteHeight => AppScale.scale(52);
  static const double dialogCancelHeight = 44; // tap target: fixed
}

/// Camera and microphone permission screens (source-tokens.md §7).
abstract final class StoryPermissionDimens {
  static double get sidePadding => AppScale.scale(36);
  static double get bottomOffset => AppScale.scale(40);
  static double get icon => AppScale.scale(72);
  static double get pairIcon => AppScale.scale(56);
  static double get pairGap => AppScale.scale(18);
  static double get titleTop => AppScale.scale(24);
  static double get bodyTop => AppScale.scale(10);
  static double get bodyMaxWidth => AppScale.scale(300);
  static double get buttonMaxWidth => AppScale.scale(300);
  static double get buttonHeight => AppScale.scale(52);
  static const double linkHeight = 44; // tap target: fixed
  static double get cardMaxWidth => AppScale.scale(318);
  static double get cardRadius => AppScale.scale(20);
  static double get cardRow => AppScale.scale(56);
  static double get tile => AppScale.scale(36);
  static double get tileRadius => AppScale.scale(12);
  static double get okCircle => AppScale.scale(28);
  static double get micPillTop => AppScale.scale(116);

  /// 116 on the design frame (inset 46): this far below the status bar.
  static double get micPillBelowInset => AppScale.scale(70);
  static double get micPillHeight => AppScale.scale(40);
  static double get micPillIcon => AppScale.scale(18);
  static double get fixChipHeight => AppScale.scale(28);
}

/// Alphas applied to `storyOnDark` (white) and `storyBlack` on story screens (source-tokens.md §2-§7).
abstract final class StoryOpacity {
  static const double replyBorder = 0.7;
  static const double replyHint = 0.9;
  static const double time = 0.8;
  static const double link = 0.85;
  static const double dialogBody = 0.72;
  static const double helper = 0.7;
  static const double subtitle = 0.6;
  static const double chevron = 0.5;
  static const double grabber = 0.25;
  static const double separator = 0.08;
  static const double secondaryFill = 0.14;
  static const double cardFill = 0.07;
  static const double tileFill = 0.1;
  static const double fieldBorder = 0.25;
  static const double recordTrack = 0.3;
  static const double hint = 0.85;
  static const double pausedChip = 0.45;

  /// The header while a sheet holds the story ([estimated]: the board only says "faded").
  static const double pausedHeader = 0.4;
  static const double sheetScrim = 0.5;
  static const double dialogScrim = 0.55;
  static const double viewersDim = 0.35;

  /// The delete circle of the viewers sheet: `dangerOnDark` over the dark sheet ([estimated] from the board).
  static const double dangerTint = 0.18;
}

/// Story durations and limits (source-tokens.md §2.1, §8).
abstract final class StoryTiming {
  static const image = Duration(seconds: 5);
  static const maxVideo = Duration(seconds: 60);
  static const minVideo = Duration(seconds: 1);
  static const markSeenAfter = Duration(seconds: 1);
  static const bufferLoaderDelay = Duration(milliseconds: 400);
  static const lifetime = Duration(hours: 24);
}

/// Story gestures (source-tokens.md §2.1).
abstract final class StoryGestures {
  /// The left share of the screen that goes to the previous story; the rest goes to the next one.
  static const double previousZone = 1 / 3;
  static const double closeDistance = 120; // unscaled: drag distance threshold
  static const double closeVelocity = 700;
  static const double closeScale = 0.9;
}

/// Story motion (source-tokens.md §8).
abstract final class StoryMotion {
  static const uiFade = Duration(milliseconds: 150);
  static const heroOpen = Duration(milliseconds: 280);
  static const personSwipe = Duration(milliseconds: 300);
  static const dragSnapBack = Duration(milliseconds: 200);
  static const sheetIn = Duration(milliseconds: 260);
  static const sheetOut = Duration(milliseconds: 200);
  static const likePop = Duration(milliseconds: 200);
  static const likeRestScale = 1.0;
  static const likePopScale = 1.25;
  static const uploadRing = Duration(milliseconds: 240);
  static const reducedMotionFade = Duration(milliseconds: 150);
  static const curve = Curves.easeOutCubic;
}

/// New post (docs/specs/post/01-design-tokens.md "Dimensions").
abstract final class PostComposerDimens {
  static double get titleRowHeight => AppScale.scale(56);
  static double get titleSide => AppScale.scale(20);
  static const double closeTarget = 44; // tap target: fixed
  static double get closeIcon => AppScale.scale(22);
  static double get cardRadius => AppRadius.card;
  static double get cardPadding => AppScale.scale(14);
  static double get avatar => AppScale.scale(44);
  static double get chipHeight => AppScale.scale(28);
  static double get chipPadding => AppScale.scale(10);
  static double get chipIcon => AppScale.scale(16);
  static double get chipChevron => AppScale.scale(14);
  static double get chipGap => AppScale.scale(4);
  static const double chipBorderWidth = 1; // unscaled: hairline
  static const double chipNarrowBorderWidth = 1.5; // unscaled: stroke
  static double get inputMinHeight => AppScale.scale(96);
  static double get thumb => AppScale.scale(104);
  static double get thumbRadius => AppRadius.media;
  static double get thumbGap => AppScale.scale(8);
  static double get removeButton => AppScale.scale(28);
  static double get removeIcon => AppScale.scale(14);
  static double get removeInset => AppScale.scale(6);
  static const double removeTapTarget = 44; // tap target: fixed
  static double get durationInset => AppScale.scale(6);
  static double get durationRadius => AppScale.scale(12);
  static EdgeInsets get durationPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(8),
    vertical: AppScale.scale(4),
  );
  static const double addBorderWidth = 2; // unscaled: dashed stroke
  static const Color addFill = Color(0xFFF8F9F8);
  static double get addPlus => AppScale.scale(24);
  static EdgeInsetsDirectional get sectionLabelMargin =>
      EdgeInsetsDirectional.fromSTEB(
        AppScale.scale(20),
        AppScale.scale(12),
        0,
        AppScale.scale(8),
      );
  static double get optionRowHeight => AppScale.scale(54);
  static EdgeInsets get optionRowPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(12),
    vertical: AppScale.scale(10),
  );
  static double get optionTile => AppScale.scale(34);
  static double get optionTileRadius => AppScale.scale(10);
  static double get optionTileIcon => AppScale.scale(18);
  static double get optionGap => AppScale.scale(14);
  static double get optionChevron => AppScale.scale(18);
  static double get switchWidth => AppScale.scale(52);
  static double get switchHeight => AppScale.scale(32);
  static double get shareSide => AppScale.scale(20);
  static double get shareHeight => AppScale.scale(56);
  static double get shareBottom => AppScale.scale(16);

  /// Share button fill when disabled: `primary` at 40%, as in auth ([estimated]).
  static const double shareDisabledOpacity = AuthButtonDimens.disabledOpacity;
}

/// Post card, shared with Home (docs/specs/post/01-design-tokens.md "Post card and options sheet").
abstract final class PostCardDimens {
  static double get radius => AppRadius.card;
  static EdgeInsets get padding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(6),
  );
  static double get authorGap => AppScale.scale(10);
  static double get avatar => AppScale.scale(40);
  static double get ringGap => AppScale.scale(2);
  static double get ringWidth => AppScale.scale(2);
  static const double moreTapTarget = 44; // tap target: fixed
  static double get moreIcon => AppScale.scale(22);
  static double get visibilityIcon => AppScale.scale(12);
  static EdgeInsets get captionMargin => EdgeInsets.fromLTRB(
    AppScale.scale(2),
    AppScale.scale(10),
    AppScale.scale(2),
    AppScale.scale(10),
  );
  static EdgeInsets get captionOnlyMargin => EdgeInsets.fromLTRB(
    AppScale.scale(2),
    AppScale.scale(10),
    AppScale.scale(2),
    AppScale.scale(4),
  );
  static const int captionCollapsedLines = 3;
  static double get mediaRadius => AppRadius.media;

  /// Media aspect (width / height) clamp: 4:5 .. 1.91:1.
  static const double mediaMinAspect = 4 / 5;
  static const double mediaMaxAspect = 1.91;
  static double get dot => AppScale.scale(6);
  static double get dotGap => AppScale.scale(4);
  static double get counterRadius => AppScale.scale(10);
  static EdgeInsets get chipPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(8),
    vertical: AppScale.scale(4),
  );
  static double get mediaInset => AppScale.scale(8);
  static double get muteButton => AppScale.scale(32);
  static double get heart => AppScale.scale(80);
  static const double heartOpacity = 0.9;
  static const double playVisibleFraction = 0.6;
  static double get muteIcon => AppScale.scale(16);
  static double get retryBadge => AppScale.scale(44);
  static double get retryIcon => AppScale.scale(22);
  static double get dotsTop => AppScale.scale(8);

  // Action bar.
  static double get actionBarHeight => AppScale.scale(44);
  static double get actionBarTop => AppScale.scale(4);
  static double get actionGap => AppScale.scale(4);
  static const double actionTapTarget = 44; // tap target: fixed
  static double get actionRadius => AppScale.scale(22);
  static double get actionIcon => AppScale.scale(24);
  static double get actionIconGap => AppScale.scale(6);
  static double get actionHorizontal => AppScale.scale(8);
  static double get shareIcon => AppScale.scale(23);
  static double get saveIcon => AppScale.scale(22);
}

/// Post motion (02-components.md P4, P5; s2-post-options.md panel 5).
abstract final class PostMotion {
  static const likePop = Duration(milliseconds: 180);
  static const likePopScale = 1.2;
  static const likeRestScale = 1.0;
  static const heartPop = Duration(milliseconds: 200);
  static const imageFadeIn = Duration(milliseconds: 200);
  static const heartFade = Duration(milliseconds: 600);
  static const scrollBack = Duration(milliseconds: 200);
  static const heartStartScale = 0.6;
  static const heartPeakScale = 1.1;
  static const heartRestScale = 1.0;
  static const hiddenCollapse = Duration(milliseconds: 240);
  static const undoWindow = Duration(seconds: 5);
}

/// Post options sheet (docs/specs/post/screens/s2-post-options.md).
abstract final class PostOptionsDimens {
  static double get quickTileHeight => AppScale.scale(76);
  static double get quickTileRadius => AppScale.scale(18);
  static double get quickTileIcon => AppScale.scale(24);
  static double get quickGap => AppScale.scale(12);
  static double get groupRadius => AppScale.scale(18);
  static const double rowMinHeight = 56; // tap target: fixed
  static double get rowIcon => AppScale.scale(22);
  static double get groupGap => AppScale.scale(12);
}

/// Visibility picker (docs/specs/post/01-design-tokens.md "Visibility picker (S4)").
abstract final class VisibilityDimens {
  static const double closeButton = 40; // tap target: fixed
  static double get groupRadius => AppScale.scale(18);
  static const double rowMinHeight = 64; // tap target: fixed
  static EdgeInsets get rowPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(16),
    vertical: AppScale.scale(10),
  );
  static double get rowGap => AppScale.scale(14);
  static double get tile => AppScale.scale(40);
  static double get tileRadius => AppScale.scale(12);
  static double get tileIcon => AppScale.scale(20);
  static double get radio => AppScale.scale(24);
  static const double radioBorderWidth = 2; // unscaled: stroke
  static double get radioCheck => AppScale.scale(14);
  static double get noteRadius => AppScale.scale(16);
  static double get toggleWidth => AppScale.scale(48);
  static double get toggleHeight => AppScale.scale(28);
  static double get actionHeight => AppScale.scale(52);
  static double get editPillHeight => AppScale.scale(32);

  /// Room for the loader or the retry while the counts load [estimated].
  static double get loadingHeight => AppScale.scale(160);
}

/// Add location (docs/specs/post/01-design-tokens.md "Add location (S3)").
abstract final class LocationDimens {
  static double get headerHeight => AppScale.scale(56);
  static double get searchHeight => AppScale.scale(48);
  static double get searchRadius => AppScale.scale(24);
  static double get searchIcon => AppScale.scale(20);
  static double get clearButton => AppScale.scale(28);
  static const double clearTapTarget = 44; // tap target: fixed
  static double get clearIcon => AppScale.scale(14);
  static const double focusRingWidth = 2; // unscaled: stroke
  static double get sectionLabelGap => AppScale.scale(14);
  static double get cardRadius => AppRadius.card;
  static double get rowMinHeight => AppScale.scale(62);
  static double get rowTile => AppScale.scale(40);
  static double get rowTileRadius => AppScale.scale(13);
  static double get rowIcon => AppScale.scale(20);
  static double get selectedCheck => AppScale.scale(20);
  static double get emptyIcon => AppScale.scale(56);
  static double get loaderWidth => AppScale.scale(44);
}
