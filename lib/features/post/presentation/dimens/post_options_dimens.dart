import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

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
