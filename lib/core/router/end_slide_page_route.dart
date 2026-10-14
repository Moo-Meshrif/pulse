import 'package:flutter/material.dart';

/// A page that slides in from the end of the screen (the right in LTR, the left in RTL) on every platform,
/// and back out the same way. With reduced motion it only fades.
class EndSlidePageRoute<T> extends PageRouteBuilder<T> {
  EndSlidePageRoute({super.settings, required WidgetBuilder builder})
    : super(
        transitionDuration: _duration,
        reverseTransitionDuration: _duration,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: _transition,
      );

  static const _duration = Duration(milliseconds: 300);

  static Widget _transition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(opacity: curved, child: child);
    }
    final fromEnd = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;
    return SlideTransition(
      position: Tween(
        begin: Offset(fromEnd, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }
}
