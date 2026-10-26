import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';

/// Home feed (docs/specs/home/01-design-tokens.md > Dimensions). The story rail uses [StoryRailDimens], the
/// loaders `LoadingDimens` and the cards `PostCardDimens`. Tap targets stay fixed; the rest scales.
abstract final class HomeDimens {
  static EdgeInsets get headerPadding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    AppScale.scale(8),
    AppScale.scale(16),
    AppScale.scale(8),
  );

  /// The floating header: its padding around the 44 buttons.
  static double get headerHeight => headerPadding.vertical + actionTapTarget;
  static double get logoGap => AppScale.scale(8);
  static const double actionTapTarget = 44; // tap target: fixed
  static double get actionIcon => AppScale.scale(24);
  static double get actionGap => AppScale.scale(4);
  // Bell dot, inside the 44 button.
  static double get bellDot => AppScale.scale(9);
  static double get bellDotBorder => AppScale.scale(2);
  static double get bellDotTop => AppScale.scale(9);
  static double get bellDotEnd => AppScale.scale(10);
  // Feed list.
  static EdgeInsets get listPadding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(4),
    AppScale.scale(12),
    0,
  );
  static double get cardGap => AppScale.scale(12);
  // Publish banner.
  static EdgeInsets get publishPadding => EdgeInsets.all(AppScale.scale(12));
  static double get publishThumb => AppScale.scale(48);
  static double get publishProgress => AppScale.scale(4);
  static double get publishRowThumb => AppScale.scale(40);
  static double get publishRowGap => AppScale.scale(12);
  static double get publishStackOffset => AppScale.scale(8);
  static double get publishChevron => AppScale.scale(32);
  static double get publishOutline => AppScale.scale(1.5);
  static const int publishStackLayers = 3;
  static const publishDoneStay = Duration(milliseconds: 1500);
  static const publishExpand = Duration(milliseconds: 200);
  // New posts pill and back to top button (docs/specs/home/screens/s2-new-posts-pill.md).
  static double get pillHeight => AppScale.scale(44);
  static double get pillRadius => AppScale.scale(22);
  static double get pillGapBelowHeader => AppScale.scale(12);
  static EdgeInsetsDirectional get pillPadding => EdgeInsetsDirectional.only(
    start: AppScale.scale(9),
    end: AppScale.scale(16),
  );
  static double get pillGap => AppScale.scale(8);
  static double get pillAvatar => AppScale.scale(26);
  static double get pillAvatarRing => AppScale.scale(2);
  static double get pillAvatarOverlap => AppScale.scale(8);
  static double get pillArrow => AppScale.scale(16);
  static const int pillAvatars = 3;
  static const int pillMaxCount = 9;
  static const pillSlide = Duration(milliseconds: 220);
  static double get pillSlideFrom => AppScale.scale(12);
  static const pillAutoHide = Duration(seconds: 10);
  static const pillShadowAlpha = 0x59; // 35% of primary
  static double get pillShadowBlur => AppScale.scale(24);
  static double get pillShadowDy => AppScale.scale(8);
  static const scrollToTopDuration = Duration(milliseconds: 450);
  static const double atTopOffset = 8;
  static const int backToTopViewports = 3;
  static const int jumpFirstViewports = 6;
  static double get backToTopSize => AppScale.scale(48);
  static double get backToTopIcon => AppScale.scale(22);
  static double get backToTopEnd => AppScale.scale(18);
  static double get backToTopAboveNav => AppScale.scale(16);
  static const backToTopFillAlpha = 0xEB; // white @ 92%
  // A post that just arrived: a soft ring that fades out.
  static double get freshRing => AppScale.scale(2);
  static const freshRingStay = Duration(seconds: 2);
  static const freshRingFade = Duration(milliseconds: 600);
  // First-load skeleton.
  static const int skeletonCards = 3;
  static const int skeletonStories = 4;
  static double get skeletonNameWidth => AppScale.scale(120);
  static double get skeletonMetaWidth => AppScale.scale(80);
  static double get skeletonLabelWidth => AppScale.scale(48);
  static const skeletonFade = Duration(milliseconds: 200);
}

/// The Stories rail of the Home feed (docs/specs/story/source-tokens.md §1).
abstract final class StoryRailDimens {
  // Rail.
  static double get railAvatar => AppScale.scale(64);
  static double get railGap => AppScale.scale(14);
  static double get railRing => AppScale.scale(2.5);
  static double get railRingGap => AppScale.scale(3);
  static double get railBadge => AppScale.scale(20);
  static double get railBadgeBorder => AppScale.scale(2);
  static double get railPhoto => AppScale.scale(52);
  static double get railLabelGap => AppScale.scale(6);
  static double get uploadRing => AppScale.scale(3);
  static const double uploadPhotoOpacity = 0.7;
  static double get plusBadge => AppScale.scale(20);
  static double get plusBadgeBorder => AppScale.scale(2);
  static double get plusIcon => AppScale.scale(24);
  static double get emptyRingDash => AppScale.scale(2);
  static EdgeInsets get railRowPadding => EdgeInsets.fromLTRB(
    AppScale.scale(16),
    AppScale.scale(4),
    AppScale.scale(16),
    AppScale.scale(12),
  );
}
