import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The design frame (the screenshots' size) every screen is scaled from.
abstract final class AppDesignSize {
  static const double width = 390;
  static const double height = 844;
}

/// One responsive factor for every dimension and font size, from the window's shortest side (so a phone in
/// landscape does not grow), clamped to [min]..[max]. Getters, rebuilt on resize by `AppScaleScope`.
abstract final class AppScale {
  static const double min = 0.85;
  static const double max = 1.25;

  static double get factor {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final logical = view.physicalSize / view.devicePixelRatio;
    final shortest = math.min(logical.width, logical.height);
    return (shortest / AppDesignSize.width).clamp(min, max);
  }

  /// Largest combined text size relative to the design: [factor] x the user's system text scale.
  /// 2.0 keeps the 200% accessibility target without 2.5x type on tablets.
  static const double maxCombinedTextScale = 2.0;

  /// The system text scale at which the combined scale reaches [maxCombinedTextScale]
  /// (never below 1, so a small phone is not capped under the user's own setting).
  static double get maxSystemTextScale =>
      math.max(1.0, maxCombinedTextScale / factor);

  /// Scales a design value: paddings, gaps, widths, heights, icons, radii and font sizes alike (the
  /// user's system text scale is applied on top of fonts by Flutter). Tap targets are not scaled.
  static double scale(double v) => v * factor;
}
