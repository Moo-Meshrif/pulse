import 'package:flutter/material.dart';

import '../app_scale.dart';

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

/// Dark option sheets and their row groups (the story menus, the report sheet).
abstract final class OptionSheetDimens {
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
}

/// Alphas applied to `AppColors.onDark` (white) and `AppColors.black` on dark sheets, dialogs and pages.
abstract final class DarkOpacity {
  static const double cardFill = 0.07;
  static const double secondaryFill = 0.14;
  static const double separator = 0.08;
  static const double fieldBorder = 0.25;
  static const double grabber = 0.25;
  static const double subtitle = 0.6;
  static const double dialogScrim = 0.55;
  static const double sheetScrim = 0.5;
  static const double tileFill = 0.1;
  static const double chevron = 0.5;
  static const double dialogBody = 0.72;
  static const double link = 0.85;
  static const double helper = 0.7;
}

/// Motion of the dark option sheets.
abstract final class SheetMotion {
  static const enter = Duration(milliseconds: 260);
  static const exit = Duration(milliseconds: 200);
  static const curve = Curves.easeOutCubic;
}
