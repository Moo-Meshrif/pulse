import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps [child] clear of system UI elements, including the status bar,
/// navigation bar, gesture indicator, and display cutouts.
///
/// Supports all [SafeArea] properties and adds [bottomSpace] to control
/// the minimum bottom spacing without introducing unnecessary padding.
///
/// The effective bottom padding is `max(systemInset, bottomSpace)`,
/// ensuring sufficient clearance without stacking both values.
/// Devices with smaller or no system insets retain the specified
/// [bottomSpace], while larger system bars receive the required space.
///
/// When the keyboard appears, the bottom inset adjusts automatically
/// unless [maintainBottomViewPadding] is enabled.
class AppSafeArea extends StatelessWidget {
  const AppSafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    this.bottomSpace = 0,
  });

  final Widget child;
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;

  /// Least padding on each edge, whatever the system reports.
  final EdgeInsets minimum;

  /// Keeps the bottom inset when the keyboard opens, as [SafeArea.maintainBottomViewPadding].
  final bool maintainBottomViewPadding;

  /// Bottom padding the content already has.
  final double bottomSpace;

  @override
  Widget build(BuildContext context) {
    // The bottom padding is the larger of the system inset and the desired minimum spacing.
    final bottomInset = _bottomInset(context);
    final bottomPadding = bottom
        ? math.max(bottomInset, math.max(minimum.bottom, bottomSpace))
        : minimum.bottom;

    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: false, // handled below, so it does not stack on the desired bottom spacing
      minimum: minimum.copyWith(bottom: 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: child,
      ),
    );
  }

  double _bottomInset(BuildContext context) {
    if (!bottom) return 0;

    if (Theme.of(context).platform != TargetPlatform.android) {
      return 0;
    }

    final media = MediaQuery.of(context);

    return maintainBottomViewPadding
        ? media.viewPadding.bottom
        : media.padding.bottom;
  }
}
