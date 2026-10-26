import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../extensions/context_extensions.dart';

/// How long one shimmer sweep takes.
const _skeletonSweep = Duration(milliseconds: 1400);

/// The shimmer of every skeleton: one sweep across the whole zone from start to end (mirrored in RTL),
/// standing still when the system asks to reduce motion.
PaintingEffect skeletonEffect(BuildContext context) {
  final colors = context.appColors;
  return MediaQuery.disableAnimationsOf(context)
      ? SolidColorEffect(color: colors.skeletonBase)
      : ShimmerEffect(
          baseColor: colors.skeletonBase,
          highlightColor: colors.skeletonHighlight,
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          duration: _skeletonSweep,
        );
}
