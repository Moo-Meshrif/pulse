import '../../../../core/theme/app_scale.dart';

/// Feeling page (docs/specs/post/01-design-tokens.md "Tags, mood and comments-off").
abstract final class FeelingDimens {
  static double get headerHeight => AppScale.scale(56);
  static double get segmentedHeight => AppScale.scale(44);
  static double get segmentedPadding => AppScale.scale(4);
  static double get tileHeight => AppScale.scale(52);
  static double get tileRadius => AppScale.scale(16);
  static double get tileGap => AppScale.scale(8);
  static double get tileSide => AppScale.scale(14);
  static const double selectedBorder = 1.5; // unscaled: stroke
  static double get check => AppScale.scale(16);
  static double get emptyIcon => AppScale.scale(56);
}
