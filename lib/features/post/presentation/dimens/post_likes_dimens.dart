import 'package:flutter/material.dart';

import '../../../../core/theme/app_scale.dart';
import '../../../../core/theme/dimens/app_dimens.dart';

/// The likes list and the "Liked by" row (docs/specs/post/screens/s15-post-page.md, "S16" and "Tokens").
/// Values the board does not give are estimated.
abstract final class PostLikesDimens {
  static double get rowAvatar => AppScale.scale(44);
  static double get rowGap => AppScale.scale(12); // estimated
  static double get rowMinHeight => AppScale.scale(64); // estimated
  static EdgeInsets get rowPadding =>
      EdgeInsets.symmetric(horizontal: AppScale.scale(16));
  static EdgeInsetsDirectional get dividerIndent =>
      EdgeInsetsDirectional.only(start: AppScale.scale(16 + 44 + 12));
  static const double divider = 1; // unscaled: hairline

  static EdgeInsets get listPadding => EdgeInsets.fromLTRB(
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(16),
  ); // estimated
  static EdgeInsets get searchPadding =>
      EdgeInsets.symmetric(horizontal: AppScale.scale(12)); // estimated
  static double get cardRadius => AppRadius.card;

  static double get skeletonNameWidth => AppScale.scale(120);
  static double get skeletonButtonWidth => AppScale.scale(84);
  static double get emptyIcon => AppScale.scale(56);

  // "Liked by" row.
  static double get likedAvatar => AppScale.scale(22);
  static double get likedOverlap => AppScale.scale(6);
  static double get likedGap => AppScale.scale(8); // estimated
  static EdgeInsets get likedPadding =>
      EdgeInsets.only(top: AppScale.scale(8), bottom: AppScale.scale(2));
  static const double likedRing = 1.5; // unscaled: stroke
  static double get likedMinHeight => AppScale.scale(32);
}
