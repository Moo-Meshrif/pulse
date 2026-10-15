import 'package:flutter/painting.dart';

import 'app_palette.dart';

/// Colors of the notice card (docs: Notices spec). Fixed: the card is dark on every screen, light pages,
/// photos and video alike.
abstract final class NoticeColors {
  /// Card surface (#1B201F @ 94%).
  static const surface = Color(0xF01B201F);

  /// Card border (white @ 8%).
  static const border = Color(0x14FFFFFF);

  /// Title.
  static const title = AppPalette.white;

  /// Message (white @ 72%).
  static const message = Color(0xB8FFFFFF);

  /// Action pill background (white @ 12%) and text.
  static const actionFill = Color(0x1FFFFFFF);
  static const actionText = Color(0xFF9ED3C9);

  /// Time-left bar (white @ 22%).
  static const timer = Color(0x38FFFFFF);

  static const error = Color(0xFFFF6B72);
  static const success = Color(0xFF5FD39A);
  static const info = Color(0xFF9ED3C9);
}
