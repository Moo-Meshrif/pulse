import 'package:flutter/material.dart';

import '../app_scale.dart';
import '../colors/app_colors.dart';

export 'bottom_sheet_dimens.dart';
export 'button_dimens.dart';
export 'camera_permission_dimens.dart';
export 'dialog_dimens.dart';
export 'form_dimens.dart';
export 'loading_dimens.dart';
export 'logo_dimens.dart';
export 'notice_dimens.dart';
export 'search_field_dimens.dart';
export 'settings_dimens.dart';

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
      color: AppPalette.ink.withAlpha(0x1F),
      offset: Offset(0, AppScale.scale(12)),
      blurRadius: AppScale.scale(30),
    ),
  ];

  /// Dialog card: 0 12 30 #161A19 @ 12%, the same shadow as the onboarding cards.
  static List<BoxShadow> get dialog => onboardingCards;

  /// Floating nav bar: 0 12 32 #161A19 @ 16% (docs/specs/control/01-design-tokens.md).
  static List<BoxShadow> get navBar => [
    BoxShadow(
      color: AppPalette.ink.withAlpha(0x29),
      offset: Offset(0, AppScale.scale(12)),
      blurRadius: AppScale.scale(32),
    ),
  ];

  /// The circle behind the selected tab of the nav bar. No offset, so it is the same on every side. It has
  /// to fade out within the 12 dp between the circle and the bar's edge ((68 - 44) / 2): a wider one is cut
  /// off at the top and bottom and the circle reads as an oval.
  static List<BoxShadow> get navActiveTab => [
    BoxShadow(
      color: AppPalette.ink.withAlpha(0x1F),
      blurRadius: AppScale.scale(8),
    ),
  ];

  /// Round back to top button over the feed: 0 8 24 #161A19 @ 18%.
  static List<BoxShadow> get backToTop => [
    BoxShadow(
      color: AppPalette.ink.withAlpha(0x2E),
      offset: Offset(0, AppScale.scale(8)),
      blurRadius: AppScale.scale(24),
    ),
  ];

  /// Notice card: 0 14 36 #161A19 @ 28%.
  static List<BoxShadow> get notice => [
    BoxShadow(
      color: AppPalette.ink.withAlpha(0x47),
      offset: Offset(0, AppScale.scale(14)),
      blurRadius: AppScale.scale(36),
    ),
  ];

  /// Bottom sheet: 0 -10 40 #161A19 @ 18%.
  static List<BoxShadow> get bottomSheet => [
    BoxShadow(
      color: AppPalette.ink.withAlpha(0x2E),
      offset: Offset(0, -AppScale.scale(10)),
      blurRadius: AppScale.scale(40),
    ),
  ];

  /// Story sticker (location): 0 6 16 black @ 25%.
  static List<BoxShadow> get sticker => [
    BoxShadow(
      color: AppPalette.black.withAlpha(0x40),
      offset: Offset(0, AppScale.scale(6)),
      blurRadius: AppScale.scale(16),
    ),
  ];

  /// Story text overlay: 0 2 12 black @ 35%.
  static List<BoxShadow> get textOverlay => [
    BoxShadow(
      color: AppPalette.black.withAlpha(0x59),
      offset: Offset(0, AppScale.scale(2)),
      blurRadius: AppScale.scale(12),
    ),
  ];

  /// Soft glow under the primary action of an empty or failed page: 0 8 20 primary @ 28%.
  static List<BoxShadow> get primaryAction => [
    BoxShadow(
      color: AppPalette.brand.withAlpha(0x47),
      offset: Offset(0, AppScale.scale(8)),
      blurRadius: AppScale.scale(20),
    ),
  ];
}

/// Sizes any widget can use. [tapTarget] is the minimum touch target and is never scaled; the other sizes
/// scale with the window.
abstract final class AppSizes {
  static const double tapTarget = 44;

  /// Icon in a top bar or back button.
  static double get topBarIcon => AppScale.scale(24);
}
