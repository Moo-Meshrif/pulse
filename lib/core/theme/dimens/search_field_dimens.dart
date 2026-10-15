import '../app_scale.dart';

/// The search pill (docs/specs/post/01-design-tokens.md "Add location (S3)").
abstract final class SearchFieldDimens {
  static double get height => AppScale.scale(48);
  static double get radius => AppScale.scale(24);
  static double get icon => AppScale.scale(20);
  static double get clearButton => AppScale.scale(28);
  static const double clearTapTarget = 44; // tap target: fixed
  static double get clearIcon => AppScale.scale(14);
  static const double focusRingWidth = 2; // unscaled: stroke
}
