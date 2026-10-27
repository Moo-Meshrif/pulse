import '../app_scale.dart';

/// Settings-style rows and cards shared by Settings, Privacy, Help and the people lists
/// (docs/specs/profile/01-design-tokens.md). Values tagged `[estimated]` were measured on screenshots.
abstract final class SettingsDimens {
  // Group card and section label.
  static double get groupPadding => AppScale.scale(8);
  static double get labelTop => AppScale.scale(22);
  static double get labelSide => AppScale.scale(24);
  static double get labelBottom => AppScale.scale(8);

  // Row: min 56, icon tile 36 with an 18 icon, chevron 18.
  static double get rowMinHeight => AppScale.scale(56);
  static double get rowSide => AppScale.scale(12);
  static double get rowGap => AppScale.scale(12);
  static double get tile => AppScale.scale(36);
  static double get tileIcon => AppScale.scale(18);
  static double get chevron => AppScale.scale(18);
  static double get valueGap => AppScale.scale(6);

  // Switch 52 x 32, thumb 24 with a primary ring. [estimated]
  static double get switchWidth => AppScale.scale(52);
  static double get switchHeight => AppScale.scale(32);
  static double get switchThumb => AppScale.scale(24);
  static double get switchInset => AppScale.scale(4);
  static const double switchThumbRing = 2; // unscaled: stroke
  static const Duration switchDuration = Duration(milliseconds: 160);

  // Radio 22, ring 2, dot 12. [estimated]
  static double get radio => AppScale.scale(22);
  static const double radioRing = 2; // unscaled: stroke
  static double get radioDot => AppScale.scale(12);

  // Outline pill button: height 36, label 14/700. [estimated]
  static double get pillHeight => AppScale.scale(36);
  static double get pillSide => AppScale.scale(16);
  static const double pillBorder = 1; // unscaled: hairline

  // Danger button card: height 56.
  static double get dangerHeight => AppScale.scale(56);
  static double get dangerIcon => AppScale.scale(20);
  static double get dangerGap => AppScale.scale(8);

  // Person row: avatar 44, name 15/700.
  static double get personAvatar => AppScale.scale(44);
  static double get personGap => AppScale.scale(12);
  static double get personVerified => AppScale.scale(16);

  // FAQ accordion: row 56, chevron 18. [estimated]
  static double get faqRowMinHeight => AppScale.scale(56);
  static double get faqAnswerBottom => AppScale.scale(14);
  static const Duration faqDuration = Duration(milliseconds: 200);
}
