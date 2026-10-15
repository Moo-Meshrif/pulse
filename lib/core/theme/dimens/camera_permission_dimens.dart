import '../app_scale.dart';

/// Camera and microphone permission screens (source-tokens.md §7).
abstract final class CameraPermissionDimens {
  static double get sidePadding => AppScale.scale(36);
  static double get bottomOffset => AppScale.scale(40);
  static double get icon => AppScale.scale(72);
  static double get pairIcon => AppScale.scale(56);
  static double get pairGap => AppScale.scale(18);
  static double get titleTop => AppScale.scale(24);
  static double get bodyTop => AppScale.scale(10);
  static double get bodyMaxWidth => AppScale.scale(300);
  static double get buttonMaxWidth => AppScale.scale(300);
  static double get buttonHeight => AppScale.scale(52);
  static const double linkHeight = 44; // tap target: fixed
  static double get cardMaxWidth => AppScale.scale(318);
  static double get cardRadius => AppScale.scale(20);
  static double get cardRow => AppScale.scale(56);
  static double get tile => AppScale.scale(36);
  static double get tileRadius => AppScale.scale(12);
  static double get okCircle => AppScale.scale(28);
  static double get micPillTop => AppScale.scale(116);

  /// 116 on the design frame (inset 46): this far below the status bar.
  static double get micPillBelowInset => AppScale.scale(70);
  static double get micPillHeight => AppScale.scale(40);
  static double get micPillIcon => AppScale.scale(18);
  static double get fixChipHeight => AppScale.scale(28);
  static double get closeIcon => AppScale.scale(26);
  static const double roundControl = 48; // tap target: fixed
  static double get topBarSide => AppScale.scale(8);
}
