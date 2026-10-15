import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// Add location (docs/specs/post/01-design-tokens.md "Add location (S3)").
abstract final class LocationDimens {
  static double get headerHeight => AppScale.scale(56);
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
