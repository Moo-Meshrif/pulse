import '../../../../core/theme/app_scale.dart';

/// Profile page values (docs/specs/profile/01-design-tokens.md). Tap targets stay fixed; the rest scales.
/// Values tagged `[estimated]` were measured on screenshots.
abstract final class ProfileDimens {
  // Personal info.
  static double get editAvatar => AppScale.scale(96);
  static const double editAvatarRing = 3; // unscaled: stroke [estimated]
  static const double editBadgeRing = 2; // unscaled: stroke
  static double get editBadge => AppScale.scale(32);
  static double get editBadgeIcon => AppScale.scale(16);
  static double get editLocationIcon => AppScale.scale(20);
  static double get editLinkGap => AppScale.scale(12);

  // Header.
  static double get coverHeight => AppScale.scale(170);
  static double get avatar => AppScale.scale(80);

  /// Initials size in the avatar.
  static double get avatarInitials => AppScale.scale(28);

  /// The avatar sits this far over the cover.
  static double get avatarOverlap => AppScale.scale(40);
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
  static double get statsRadius => AppScale.scale(20);
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

  // Empty or failed grid, shown under the tabs.
  static double get emptyHeight => AppScale.scale(380);

  /// An empty tab fills the space above the nav; on a short screen it keeps at least this and scrolls.
  static double get emptyMinHeight => AppScale.scale(260);
}
