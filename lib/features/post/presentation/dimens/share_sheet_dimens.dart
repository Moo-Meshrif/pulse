import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

/// The Share sheet (docs/specs/post/screens/s12-share-sheet.md, "Tokens"). Header and gaps the spec does not
/// give are estimated.
abstract final class ShareSheetDimens {
  static double get headerIcon => AppScale.scale(22);
  static double get headerGap => AppScale.scale(8);
  static const double closeButton = 40; // tap target: fixed
  static double get closeIcon => AppScale.scale(18);
  static double get sectionGap => AppScale.scale(14);
  static const double composerFocusBorder = 1.5; // unscaled: stroke
  static double get composerRadius => AppScale.scale(18);
  static double get composerPadding => AppScale.scale(12);
  static double get avatar => AppScale.scale(40);
  static double get avatarGap => AppScale.scale(10);
  static double get chipHeight => AppScale.scale(26);
  static double get fieldMinHeight => AppScale.scale(40);
  static const int fieldMaxLines = 4;
  static const double toolButton = 36; // tap target: fixed
  static double get toolIcon => AppScale.scale(19);
  static double get toolGap => AppScale.scale(8);
  static double get shareNowHeight => AppScale.scale(38);
  static double get shareNowPadding => AppScale.scale(16);
  static double get tile => AppScale.scale(52);
  static double get tileIcon => AppScale.scale(22);
  static double get tileGap => AppScale.scale(12);
  static double get tileLabelGap => AppScale.scale(6);
  static double get tileWidth => AppScale.scale(68);
  static const int tileLabelLines = 2;

  /// The counter is announced politely from here on.
  static const int counterAnnounceFrom = 1900;
  static const double divider = 1; // unscaled: hairline
  static EdgeInsets get dividerMargin =>
      EdgeInsets.symmetric(vertical: AppScale.scale(14));
}
