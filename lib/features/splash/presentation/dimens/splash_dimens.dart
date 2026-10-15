import '../../../../core/theme/app_scale.dart';

/// The splash (docs/specs/auth/screens/s13-splash.md). All `[estimated]` from the screenshots (Q26).
abstract final class SplashDimens {
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
