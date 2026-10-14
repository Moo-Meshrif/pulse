import 'package:blurhash_ffi/blurhash_ffi.dart';
import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';

/// What shows while a picture loads or after it failed: its blurhash, or a plain background without one.
class PostBlurhash extends StatelessWidget {
  const PostBlurhash({super.key, this.hash});

  final String? hash;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.background;
    final value = hash;
    if (value == null || value.isEmpty) return ColoredBox(color: color);
    return BlurhashFfi(hash: value, color: color, imageFit: BoxFit.cover);
  }
}
