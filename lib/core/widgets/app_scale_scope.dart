import 'package:flutter/widgets.dart';

import '../theme/app_scale.dart';

/// Re-reads `AppScale` when the window changes (browser resize, rotation, split screen). Put it
/// above `MaterialApp`.
///
/// `AppScale` getters are plain statics, so a widget that is not recreated (a route page, a `const`
/// subtree) would keep its old sizes. When the factor actually changes, every element below is
/// marked dirty (state is kept; only `build` runs again). The factor is clamped, so while a window is
/// dragged beyond the clamp range no rebuild happens at all.
class AppScaleScope extends StatefulWidget {
  const AppScaleScope({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  State<AppScaleScope> createState() => _AppScaleScopeState();
}

class _AppScaleScopeState extends State<AppScaleScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  double _factor = AppScale.factor;

  @override
  void didChangeMetrics() {
    final factor = AppScale.factor;
    if (factor == _factor) return;
    _factor = factor;
    setState(() {});
    (context as Element).visitChildren(_markDirty);
  }

  void _markDirty(Element element) {
    element.markNeedsBuild();
    element.visitChildren(_markDirty);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
