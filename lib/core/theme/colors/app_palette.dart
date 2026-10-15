import 'package:flutter/painting.dart';

/// Raw colors that more than one color file or shadow uses, written once. Widgets never read these:
/// they use `AppColors` (themed) or `StoryColors` (fixed on dark surfaces).
abstract final class AppPalette {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  /// The near-black of text and of every scrim and shadow.
  static const ink = Color(0xFF161A19);

  /// Brand teal: `AppColors.primary`, the third avatar background, the primary action glow.
  static const brand = Color(0xFF2E6B63);

  /// White @ 35%: the nav bar's inner bottom highlight and the story progress track.
  static const white35 = Color(0x59FFFFFF);
}
