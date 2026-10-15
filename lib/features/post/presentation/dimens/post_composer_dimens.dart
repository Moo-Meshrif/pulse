import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

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
  static const double shareDisabledOpacity = ButtonDimens.disabledOpacity;
}
