import 'package:flutter/widgets.dart';

import '../services/device_tier.dart';

/// Hands the [DeviceTier] to the widget tree. Without one (tests) every device counts as normal.
class DeviceTierScope extends InheritedWidget {
  const DeviceTierScope({super.key, required this.tier, required super.child});

  final DeviceTier tier;

  @override
  bool updateShouldNotify(DeviceTierScope old) => tier.isLow != old.tier.isLow;
}

extension DeviceTierContext on BuildContext {
  /// True on a device that should skip live blur and draw a flat fill instead.
  bool get isLowTier =>
      dependOnInheritedWidgetOfExactType<DeviceTierScope>()?.tier.isLow ??
      false;
}
