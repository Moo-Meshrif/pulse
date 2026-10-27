import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

/// The post page (docs/specs/post/screens/s15-post-page.md, "Tokens"). Values the board does not give are
/// estimated.
abstract final class PostPageDimens {
  static double get topBarHeight => AppScale.scale(52);
  static double get topBarSide => AppScale.scale(8); // estimated
  static double get miniAvatar => AppScale.scale(28);
  static double get miniAvatarGap => AppScale.scale(8); // estimated
  static const double barDivider = 1; // unscaled: hairline

  /// The scroll distance after which the author row is gone and the bar shows the mini author.
  static double get miniAuthorOffset => AppScale.scale(72); // estimated

  static EdgeInsets get listPadding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(4),
    AppScale.scale(12),
    AppScale.scale(16),
  );
  static double get sectionGap => AppScale.scale(12);
  static EdgeInsets get sectionPadding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(14),
    AppScale.scale(12),
    AppScale.scale(8),
  ); // estimated

  static double get followHeight => AppScale.scale(32);
  static double get followSide => AppScale.scale(14); // estimated
  static double get followGap => AppScale.scale(4); // estimated
  static const double followTapTarget = 48; // tap target: fixed

  static EdgeInsets get datePadding =>
      EdgeInsets.only(top: AppScale.scale(4), bottom: AppScale.scale(2));

  static double get chipHeight => AppScale.scale(32); // estimated
  static double get chipSide => AppScale.scale(12); // estimated
  static double get chipRadius => AppScale.scale(16); // estimated
  static double get chipIcon => AppScale.scale(14); // estimated
  static double get chipGap => AppScale.scale(6); // estimated

  static double get unavailableIcon => AppScale.scale(72);
  static double get unavailableGap => AppScale.scale(16); // estimated
  static double get unavailableBodyGap => AppScale.scale(6); // estimated
  static double get unavailableButtonGap => AppScale.scale(24); // estimated
  static double get unavailableButtonWidth => AppScale.scale(200); // estimated

  /// The pinned comment field has the sheet's side space; the sheet gets it from the bottom sheet.
  static EdgeInsets get composerPadding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    0,
    AppScale.scale(16),
    AppScale.scale(8),
  ); // estimated

  static const scrollToComments = Duration(milliseconds: 300);

  /// How long the notification's comment stays lit and its chip stays.
  static const focusDuration = Duration(seconds: 2);
}
