import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// Tag people and Tag in photo (docs/specs/post/01-design-tokens.md "Tags, mood and comments-off").
abstract final class TagPeopleDimens {
  static double get headerHeight => AppScale.scale(56);
  static double get doneHeight => AppScale.scale(36);
  static double get doneSide => AppScale.scale(18);
  static double get chipHeight => AppScale.scale(36);
  static double get chipAvatar => AppScale.scale(28);
  static double get chipRemove => AppScale.scale(22);
  static double get chipRemoveIcon => AppScale.scale(12);
  static double get chipGap => AppScale.scale(8);
  static double get rowMinHeight => AppScale.scale(64);
  static double get rowAvatar => AppScale.scale(44);
  static double get rowGap => AppScale.scale(12);
  static double get cardRadius => AppRadius.card;
  static double get check => AppScale.scale(24);
  static const double checkBorder = 2; // unscaled: stroke
  static double get checkIcon => AppScale.scale(14);
  static const double disabledOpacity = 0.5;
  static double get blockIcon => AppScale.scale(12);
  static double get buttonHeight => AppScale.scale(48);
  static double get buttonIcon => AppScale.scale(18);
  static const double buttonBorder = 1; // unscaled: hairline
  static double get buttonSide => AppScale.scale(20);
  static double get loaderWidth => AppScale.scale(44);
  static double get emptyIcon => AppScale.scale(56);

  // Tag in photo.
  /// The photo takes this share of the page, and scrolls the rest when the text is large.
  static const double photoShare = 0.55; // unscaled: share of the page
  static double get photoMinHeight => AppScale.scale(240);
  static double get hintSide => AppScale.scale(24);
  static double get thumb => AppScale.scale(56);
  static const int thumbCachePixels = 200; // unscaled: image cache size
  static double get thumbRadius => AppScale.scale(12);
  static const double thumbRing = 2; // unscaled: stroke
  static double get thumbRingGap => AppScale.scale(2);
  static double get thumbBadge => AppScale.scale(20);
  static double get infoRadius => AppScale.scale(18);
  static EdgeInsets get infoPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(16),
    vertical: AppScale.scale(10),
  );
  static double get infoIcon => AppScale.scale(18);
  static double get marker => AppScale.scale(28);
  static const double markerStroke = 2; // unscaled: stroke
  static double get labelClose => AppScale.scale(18);
  static double get labelCloseIcon => AppScale.scale(10);
  static double get pickerRowAvatar => AppScale.scale(40);
  static double get pickerMaxHeight => AppScale.scale(420);
}
