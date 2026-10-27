import 'package:flutter/material.dart';

import '../app_scale.dart';

/// Text field and password eye (docs/specs/auth/01-design-tokens.md, 02-components.md).
abstract final class InputDimens {
  // Input: padding 15 v / 16 h, no fixed height; 1 px border, 1.5 on focus and error.
  static EdgeInsets get padding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(16),
    vertical: AppScale.scale(15),
  );
  static const double borderWidth = 1; // unscaled: hairline
  static const double activeBorderWidth = 1.5; // unscaled: focus / error
  // Password eye: 22 icon in a 44 tap target.
  static double get eyeIcon => AppScale.scale(22);
  static const double eyeTapTarget = 44; // tap target: fixed
}

/// Selectable chips (interests, gender, segmented).
abstract final class ChipDimens {
  // Chips: interest h44, gender h40, h-padding 18, label 15/700 (`name`); selected shows a 16 check + gap 6.
  static double get interestHeight => AppScale.scale(44);
  static double get genderHeight => AppScale.scale(40);
  static double get segmentedHeight => AppScale.scale(40); // [estimated]
  static double get horizontalPadding => AppScale.scale(18);
  static double get wrapSpacing => AppScale.scale(10);
  static double get interestRunSpacing => AppScale.scale(12);
  static double get checkSize => AppScale.scale(16);
  static double get checkGap => AppScale.scale(6);
  static const double minTapHeight = 44; // tap target: fixed
  static const double borderWidth = 1; // unscaled: hairline
}

/// Avatars: the upload circle with its badge, and the list circle.
abstract final class AvatarDimens {
  // Avatars: upload circle 88 (dashed 1.5, camera 28, badge 28 + plus 14), list circle 48.
  static double get upload => AppScale.scale(88);
  static const double dashedWidth = 1.5; // unscaled: stroke
  static double get cameraIcon => AppScale.scale(28);
  static double get badge => AppScale.scale(28);
  static double get badgePlus => AppScale.scale(14);
  static const double badgeRing = 2; // unscaled: stroke
  static double get list => AppScale.scale(48);

  /// Space between the list circle's edge and its initials.
  static double get initialsPadding => AppScale.scale(2);
}
