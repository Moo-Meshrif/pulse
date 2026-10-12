import 'package:flutter/material.dart';

import '../theme/app_breakpoints.dart';
import 'app_safe_area.dart';
import 'content_width.dart';

/// A screen's frame: a [Scaffold] whose [child] stays clear of the system bars ([AppSafeArea]) and
/// is capped and centered on wide windows ([ContentWidth]). The common [Scaffold], [AppSafeArea] and
/// [ContentWidth] options are passed through; [bottomSpace] is the bottom padding the content already has.
class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.child,
    this.appBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
    this.bottomSpace = 0,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget child;

  // Scaffold
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;

  // AppSafeArea
  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;
  final double bottomSpace;

  // ContentWidth
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    backgroundColor: backgroundColor,
    floatingActionButton: floatingActionButton,
    bottomNavigationBar: bottomNavigationBar,
    resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    extendBodyBehindAppBar: extendBodyBehindAppBar,
    body: AppSafeArea(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      minimum: minimum,
      maintainBottomViewPadding: maintainBottomViewPadding,
      bottomSpace: bottomSpace,
      child: ContentWidth(maxWidth: maxWidth, child: child),
    ),
  );
}
