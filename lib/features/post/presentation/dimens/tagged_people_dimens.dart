import '../../../../core/theme/app_scale.dart';

/// Tagged people sheet (docs/specs/post/screens/s10-tagged-people.md).
abstract final class TaggedPeopleDimens {
  static const double rowMinHeight = 62; // tap target: fixed
  static double get avatar => AppScale.scale(44);
  static double get avatarGap => AppScale.scale(12);
  static double get rowGap => AppScale.scale(8);
  static double get pillHeight => AppScale.scale(36);
  static double get pillSide => AppScale.scale(16);
  static double get loadingHeight => AppScale.scale(160);
}
