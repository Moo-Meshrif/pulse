import 'package:flutter/material.dart';

import '../app_scale.dart';

/// The notice card (Notices spec, Anatomy and Behavior).
abstract final class NoticeDimens {
  /// Gap under the safe area at the top, and the card's side margin.
  static double get topGap => AppScale.scale(8);
  static double get side => AppScale.scale(12);
  static double get maxWidth => AppScale.scale(560);

  /// 12 top, 14 start, 14 bottom, 12 end.
  static EdgeInsetsDirectional get padding => EdgeInsetsDirectional.fromSTEB(
    AppScale.scale(14),
    AppScale.scale(12),
    AppScale.scale(12),
    AppScale.scale(14),
  );
  static double get minHeight => AppScale.scale(60);
  static double get gap => AppScale.scale(12);
  static double get iconCircle => AppScale.scale(32);
  static double get icon => AppScale.scale(20);
  static double get actionHeight => AppScale.scale(36);
  static double get actionSide => AppScale.scale(14);
  static double get timerHeight => AppScale.scale(2);

  /// The time bar sits this far above the card's bottom edge.
  static double get timerBottom => AppScale.scale(6);

  /// Backdrop blur sigma and border width: not layout sizes, not scaled.
  static const double blurSigma = 20;
  static const double borderWidth = 1;

  static double get enterOffset => AppScale.scale(24);
  static const double enterScale = 0.96;
  static const Duration enter = Duration(milliseconds: 320);
  static const Duration exit = Duration(milliseconds: 200);

  /// A drag up of this many dp dismisses the card.
  static const double swipeDismiss = 24;
}
