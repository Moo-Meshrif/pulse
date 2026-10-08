import 'package:flutter/widgets.dart';

import '../theme/app_scale.dart';

/// Re-reads `AppScale` when the window changes. Put it above `MaterialApp`.
///
/// The getters are plain statics, so on a real factor change every element below is marked dirty (state is
/// kept); inside the clamp range nothing rebuilds.
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
