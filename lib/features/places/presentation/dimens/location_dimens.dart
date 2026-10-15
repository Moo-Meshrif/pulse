import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// Add location (docs/specs/post/01-design-tokens.md "Add location (S3)").
abstract final class LocationDimens {
  static double get headerHeight => AppScale.scale(56);
  static double get searchHeight => AppScale.scale(48);
  static double get searchRadius => AppScale.scale(24);
  static double get searchIcon => AppScale.scale(20);
  static double get clearButton => AppScale.scale(28);
  static const double clearTapTarget = 44; // tap target: fixed
  static double get clearIcon => AppScale.scale(14);
  static const double focusRingWidth = 2; // unscaled: stroke
  static double get sectionLabelGap => AppScale.scale(14);
  static double get cardRadius => AppRadius.card;
  static double get rowMinHeight => AppScale.scale(62);
  static double get rowTile => AppScale.scale(40);
  static double get rowTileRadius => AppScale.scale(13);
  static double get rowIcon => AppScale.scale(20);
  static double get selectedCheck => AppScale.scale(20);
  static double get emptyIcon => AppScale.scale(56);
  static double get loaderWidth => AppScale.scale(44);
}
