import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// Post card, shared with Home (docs/specs/post/01-design-tokens.md "Post card and options sheet").
abstract final class PostCardDimens {
  static double get radius => AppRadius.card;
  static EdgeInsets get padding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(6),
  );
  static double get authorGap => AppScale.scale(10);
  static double get avatar => AppScale.scale(40);
  static double get ringGap => AppScale.scale(2);
  static double get ringWidth => AppScale.scale(2);
  static const double moreTapTarget = 44; // tap target: fixed
  static double get moreIcon => AppScale.scale(22);
  static double get visibilityIcon => AppScale.scale(12);
  static EdgeInsets get captionMargin => EdgeInsets.fromLTRB(
    AppScale.scale(2),
    AppScale.scale(10),
    AppScale.scale(2),
    AppScale.scale(10),
  );
  static EdgeInsets get captionOnlyMargin => EdgeInsets.fromLTRB(
    AppScale.scale(2),
    AppScale.scale(10),
    AppScale.scale(2),
    AppScale.scale(4),
  );

  /// Collapsed caption lines: a caption-only post has room for more than one under a photo.
  static const int captionOnlyCollapsedLines = 6;
  static const int captionWithMediaCollapsedLines = 2;
  static double get mediaRadius => AppRadius.media;

  /// Media aspect (width / height) clamp: 4:5 .. 1.91:1.
  static const double mediaMinAspect = 4 / 5;
  static const double mediaMaxAspect = 1.91;
  static double get dot => AppScale.scale(6);
  static double get dotGap => AppScale.scale(4);
  static double get counterRadius => AppScale.scale(10);
  static EdgeInsets get chipPadding => EdgeInsets.symmetric(
    horizontal: AppScale.scale(8),
    vertical: AppScale.scale(4),
  );
  static double get mediaInset => AppScale.scale(8);
  static double get muteButton => AppScale.scale(32);
  static double get heart => AppScale.scale(80);
  static const double heartOpacity = 0.9;
  static const double playVisibleFraction = 0.6;
  static double get muteIcon => AppScale.scale(16);
  static double get retryBadge => AppScale.scale(44);
  static double get retryIcon => AppScale.scale(22);
  static double get dotsTop => AppScale.scale(8);
  // Action bar.
  static double get actionBarHeight => AppScale.scale(44);
  static double get actionBarTop => AppScale.scale(4);
  static double get actionGap => AppScale.scale(4);
  static const double actionTapTarget = 44; // tap target: fixed
  static double get actionRadius => AppScale.scale(22);
  static double get actionIcon => AppScale.scale(24);
  static double get actionIconGap => AppScale.scale(6);
  static double get actionHorizontal => AppScale.scale(8);
  static double get shareIcon => AppScale.scale(23);
  static double get saveIcon => AppScale.scale(22);
}

/// Post motion (02-components.md P4, P5; s2-post-options.md panel 5).
abstract final class PostMotion {
  static const likePop = Duration(milliseconds: 180);
  static const likePopScale = 1.2;
  static const likeRestScale = 1.0;
  static const heartPop = Duration(milliseconds: 200);
  static const imageFadeIn = Duration(milliseconds: 200);
  static const heartFade = Duration(milliseconds: 600);
  static const scrollBack = Duration(milliseconds: 200);
  static const heartStartScale = 0.6;
  static const heartPeakScale = 1.1;
  static const heartRestScale = 1.0;
  static const hiddenCollapse = Duration(milliseconds: 240);
  static const undoWindow = Duration(seconds: 5);
}
