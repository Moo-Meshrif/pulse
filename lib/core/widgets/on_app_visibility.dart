import 'package:flutter/widgets.dart';

/// Calls [onHide] when the app goes to the background (another app, the home screen, the phone locked),
/// the last moment it surely runs before the system may kill it, and [onShow] when it comes back (not
/// when it starts). Either may be left out. Draws only [child].
class OnAppVisibility extends StatefulWidget {
  const OnAppVisibility({
    super.key,
    this.onShow,
    this.onHide,
    required this.child,
  });

  final VoidCallback? onShow;
  final VoidCallback? onHide;
  final Widget child;

  @override
  State<OnAppVisibility> createState() => _OnAppVisibilityState();
}

class _OnAppVisibilityState extends State<OnAppVisibility> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Reads the widget on each call, so a rebuilt callback is used.
    _lifecycle = AppLifecycleListener(
      onShow: () => widget.onShow?.call(),
      onHide: () => widget.onHide?.call(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
