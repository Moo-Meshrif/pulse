import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

/// Material scrolling plus drag from every pointer. By default a mouse cannot drag a `PageView` or a
/// list on web and desktop; trackpads and pens do not either on some platforms. The platform
/// scrollbar (desktop and web) and overscroll feel stay Material's.
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
