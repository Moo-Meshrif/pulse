import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Keeps [child] clear of the system bars (status bar, Android navigation buttons, gesture bar, notch).
/// Takes every [SafeArea] field, plus [bottomSpace] for the bottom edge.
///
/// The bottom edge never stacks on the screen's own padding: pass that padding as [bottomSpace] and the
/// area adds only what the system bar needs beyond it, i.e. the total is `max(inset, bottomSpace)`. So a
/// device without navigation buttons (small or no inset) gets no extra space, and one with a tall button
/// bar gets just the missing part. The keyboard still takes over the bottom edge when it opens (unless
/// [maintainBottomViewPadding] is set).
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
    // The system bar needs `inset`; the content already covers `bottomSpace` of it. Add only the rest.
    final missing = math.max(0.0, _bottomInset(context) - bottomSpace);
    return SafeArea(
      left: left,
      top: top,
      right: right,
      bottom: false, // handled below, so it does not stack on the content's own padding
      minimum: minimum.copyWith(bottom: 0),
      child: Padding(
        padding: EdgeInsets.only(bottom: math.max(minimum.bottom, missing)),
        child: child,
      ),
    );
  }

  double _bottomInset(BuildContext context) {
    if (!bottom) return 0;
    final media = MediaQuery.of(context);
    return maintainBottomViewPadding
        ? media.viewPadding.bottom
        : media.padding.bottom;
  }
}
