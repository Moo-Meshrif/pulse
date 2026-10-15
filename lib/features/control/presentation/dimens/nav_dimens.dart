import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

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
