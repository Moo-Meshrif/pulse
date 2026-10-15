import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

/// Story rail and viewer (docs/specs/story/source-tokens.md §1-§3). Tap targets stay fixed; the rest scales.
abstract final class StoryDimens {
  // Progress bars and header.
  static double get barTop => AppScale.scale(54);

  /// The bars sit this far below the status bar (54 on the 46 dp inset of the design frame).
  static double get barBelowInset => AppScale.scale(8);

  /// The header starts this far below the top of the bars (66 - 54).
  static double get headerBelowBars => AppScale.scale(12);
  static double get barSide => AppScale.scale(10);
  static double get barGap => AppScale.scale(4);
  static double get barHeight => AppScale.scale(3);
  static double get barRadius => AppScale.scale(2);
  static double get headerTop => AppScale.scale(66);
  static double get headerStart => AppScale.scale(12);
  static double get headerEnd => AppScale.scale(6);
  static double get headerHeight => AppScale.scale(48);
  static double get headerGap => AppScale.scale(10);
  static double get headerAvatar => AppScale.scale(36);
  static double get headerAvatarRing => AppScale.scale(2);
  static const double headerButton = 44; // tap target: fixed
  static double get moreIcon => AppScale.scale(22);
  static double get closeIcon => AppScale.scale(24);

  /// The buffering line's width.
  static double get loaderWidth => AppScale.scale(56);
  static double get shadeTop => AppScale.scale(170);
  static double get shadeBottom => AppScale.scale(200);
  // Reply bar.
  static double get replySide => AppScale.scale(12);
  static double get replyBottom => AppScale.scale(30);
  static double get replyGap => AppScale.scale(10);
  static double get replyHeight => AppScale.scale(48);
  static double get replyBorder => AppScale.scale(1.5);
  static double get replyPadding => AppScale.scale(18);
  static const double replyAction = 44; // tap target: fixed
  static double get likeIcon => AppScale.scale(28);
  static double get sendIcon => AppScale.scale(26);
  static double get countIcon => AppScale.scale(18);
  // Location sticker.
  static double get stickerHeight => AppScale.scale(40);
  static double get stickerRadius => AppScale.scale(12);
  static double get stickerPadding => AppScale.scale(14);
  static double get stickerGap => AppScale.scale(6);
  static double get stickerPin => AppScale.scale(18);
  static const double stickerRotationDegrees = -4;
  // Viewers sheet (light).
  static double get viewersHeight => AppScale.scale(430);
  static const double viewersMaxFraction = 0.9;
  static double get viewersHeaderIcon => AppScale.scale(22);
  static double get viewersHeaderGap => AppScale.scale(8);
  static const double viewersAction = 40; // tap target: fixed
  static double get viewersActionIcon => AppScale.scale(20);
  static double get viewerRowHeight => AppScale.scale(60);
  static double get viewerRowGap => AppScale.scale(12);
  static double get viewerAvatar => AppScale.scale(40);
  static double get viewerLikedIcon => AppScale.scale(20);
}

/// Story camera and edit screens (source-tokens.md §4).
abstract final class StoryCameraDimens {
  static double get topBarTop => AppScale.scale(56);

  /// 56 on the design frame, whose status inset is 46: this far below the status bar.
  static double get topBarBelowInset => AppScale.scale(10);
  static double get topBarHeight => AppScale.scale(48);
  static double get controlIcon => AppScale.scale(24);
  static double get shutter => AppScale.scale(80);
  static double get shutterRing => AppScale.scale(5);
  static double get shutterDot => AppScale.scale(64);
  static double get recordRing => AppScale.scale(92);
  static double get recordStop => AppScale.scale(40);
  static double get recordStopRadius => AppScale.scale(12);
  static double get bottomRowBottom => AppScale.scale(40);
  static double get bottomRowSide => AppScale.scale(34);
  static double get galleryThumb => AppScale.scale(44);
  static double get galleryRadius => AppScale.scale(12);
  static double get galleryBorder => AppScale.scale(2);
  static double get hintBottom => AppScale.scale(150);
  static double get timerHeight => AppScale.scale(30);
  static double get timerPadding => AppScale.scale(12);
  static double get timerDot => AppScale.scale(8);
  // Edit tools and bottom actions.
  static double get toolRight => AppScale.scale(12);
  static double get toolTop => AppScale.scale(120);

  /// 120 on the design frame (inset 46): this far below the status bar.
  static double get toolBelowInset => AppScale.scale(74);

  /// Gap between the delete zone and the action pills.
  static double get deleteZoneAbove => AppScale.scale(16);
  static double get toolGap => AppScale.scale(12);
  static const double tool = 44; // tap target: fixed
  static double get toolIcon => AppScale.scale(22);
  static double get actionSide => AppScale.scale(12);
  static double get actionBottom => AppScale.scale(30);
  static double get actionGap => AppScale.scale(10);
  static double get actionHeight => AppScale.scale(52);
  static double get audienceAvatar => AppScale.scale(26);
  static double get audienceAvatarRing => AppScale.scale(2);
  static double get sharePill => AppScale.scale(120);
  static double get shareChevron => AppScale.scale(18);
  static double get deleteZone => AppScale.scale(48);
  static const double deleteZoneHoverScale = 1.2;
  static const double stickerMinScale = 0.5;
  static const double stickerMaxScale = 3;
}

/// Story options sheets, delete dialog and paused chip (source-tokens.md §5-§6).
abstract final class StorySheetDimens {
  /// 128 on the design frame, whose status inset is 46: this far below the status bar.
  static double get pausedChipBelowInset => AppScale.scale(82);
  static double get pausedChipHeight => AppScale.scale(30);
  static double get pausedChipPadding => AppScale.scale(12);
  static double get pausedChipGap => AppScale.scale(6);
  static double get pausedChipIcon => AppScale.scale(14);
  // Delete dialog.
  static double get dialogRadius => AppScale.scale(28);
  static double get dialogMargin => AppScale.scale(32);
  static EdgeInsets get dialogPadding => EdgeInsets.fromLTRB(
    AppScale.scale(22),
    AppScale.scale(26),
    AppScale.scale(22),
    AppScale.scale(18),
  );
  static double get dialogIcon => AppScale.scale(40);
  static double get dialogTitleTop => AppScale.scale(14);
  static double get dialogBodyTop => AppScale.scale(8);
  static double get dialogDeleteTop => AppScale.scale(22);
  static double get dialogDeleteHeight => AppScale.scale(52);
  static const double dialogCancelHeight = 44; // tap target: fixed
}
