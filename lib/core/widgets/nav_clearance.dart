import 'package:flutter/widgets.dart';

/// How much room the main shell's floating nav bar takes at the bottom of a tab (92 + the system inset).
/// A tab's scroll view adds it to its bottom padding so the last item scrolls clear of the bar; outside
/// the shell it is 0. The shell provides it; features only read it, so they never import the shell.
class NavClearance extends InheritedWidget {
  const NavClearance({super.key, required this.bottom, required super.child});

  final double bottom;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavClearance>()?.bottom ?? 0;

  @override
  bool updateShouldNotify(NavClearance old) => bottom != old.bottom;
}
