import 'package:flutter/painting.dart';

import 'app_palette.dart';

/// Colors of the story screens and the dark sheets, dialogs and permission pages built like them
/// (docs/specs/story/source-tokens.md). Fixed: they do not change with the theme, so they are constants,
/// not part of `AppColors`.
abstract final class StoryColors {
  /// Progress bar track (#FFFFFF @ 35%).
  static const track = AppPalette.white35;

  /// Top shade start, paused chip (#000000 @ 45%).
  static const shadeTop = Color(0x73000000);

  /// Bottom shade end, delete scrim (#000000 @ 55%).
  static const shadeBottom = Color(0x8C000000);

  /// Round camera controls, grid lines, Your story pill (#FFFFFF @ 18%).
  static const control = Color(0x2EFFFFFF);

  /// Edit tool circles, viewers dim (#000000 @ 35%).
  static const tool = Color(0x59000000);

  /// Camera background gradient start (#1F2A2C).
  static const cameraStart = Color(0xFF1F2A2C);

  /// Camera background gradient end (#3D4C4F).
  static const cameraEnd = Color(0xFF3D4C4F);
}
