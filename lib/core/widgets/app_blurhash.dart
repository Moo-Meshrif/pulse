import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// What shows while a picture loads (pass it as `AppImage.placeholder`) or after it failed: its blurhash, or a
/// plain [color] without one (the app background by default).
class AppBlurhash extends StatelessWidget {
  const AppBlurhash({super.key, this.hash, this.color});

  final String? hash;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? context.appColors.background;
    final value = hash;
    if (value == null || value.isEmpty) return ColoredBox(color: color);
    return BlurhashFfi(hash: value, color: color, imageFit: BoxFit.cover);
  }
}
