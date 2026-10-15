import '../app_scale.dart';

/// Logo sizes used by the shared logo widgets: the auth tile, the splash tile, the home header tile and the
/// onboarding wordmark mark.
abstract final class LogoDimens {
  // Logo tile 48 (radius 14) and icon tile 72 (radius 22, icon 32).
  static double get authTile => AppScale.scale(48);
  static double get splashTile => AppScale.scale(72);
  static double get splashTileRadius => AppScale.scale(22);
  static double get homeTile => AppScale.scale(28);
  static double get homeRadius => AppScale.scale(9);
  static double get markSize => AppScale.scale(26);
  static double get markRadius => AppScale.scale(8);
  static double get markToWordmarkGap => AppScale.scale(8);
}
