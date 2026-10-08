import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

/// Material scrolling plus drag from every pointer, so a mouse can drag a `PageView` or list on web and
/// desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
