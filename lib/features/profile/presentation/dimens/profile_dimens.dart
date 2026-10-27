import '../../../../core/theme/app_scale.dart';

/// Profile page values (docs/specs/profile/01-design-tokens.md). Tap targets stay fixed; the rest scales.
/// Values tagged `[estimated]` were measured on screenshots.
abstract final class ProfileDimens {
  // Header.
  static double get coverHeight => AppScale.scale(170);
  static double get avatar => AppScale.scale(96);

  /// The avatar sits this far over the cover.
  static double get avatarOverlap => AppScale.scale(48);
  static const double avatarWhiteRing = 4; // unscaled: stroke [estimated]
  static const double avatarRing = 2; // unscaled: stroke [estimated]
  static const double coverButton = 44; // tap target: fixed
  static double get coverButtonSide => AppScale.scale(12);
  static double get coverButtonTop => AppScale.scale(8);
  static double get coverButtonIcon => AppScale.scale(22);
  static double get verifiedIcon => AppScale.scale(18);
  static double get headerGap => AppScale.scale(4);
  static double get locationIcon => AppScale.scale(14);

  // Follows-you chip and followed-by row.
  static double get chipRadius => AppScale.scale(11);
  static double get chipHeight => AppScale.scale(22);
  static double get followedByAvatar => AppScale.scale(22);
  static double get followedByOverlap => AppScale.scale(6);

  // Follow buttons.
  static double get followHeight => AppScale.scale(44);
  static double get followGap => AppScale.scale(8);

  // Stats card.
  static double get statsHeight => AppScale.scale(68); // [estimated]
  static double get statsDividerHeight => AppScale.scale(34); // [estimated]
  static const double statsDividerWidth = 1; // unscaled: hairline

  // Tabs.
  static double get tabHeight => AppScale.scale(45); // [estimated]
  static double get tabIcon => AppScale.scale(18);
  static double get tabGap => AppScale.scale(6);
  static const double tabUnderline = 2; // unscaled: stroke

  // Post grid: 3 columns, gap 4, square.
  static const int gridColumns = 3;
  static double get gridGap => AppScale.scale(4);
  static double get gridRadius => AppScale.scale(10);

  // Locked and blocked card.
  static double get lockedIcon => AppScale.scale(56);
  static double get lockedPadding => AppScale.scale(28);
  static double get lockedGap => AppScale.scale(12);
}
