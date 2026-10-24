import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../dimens/home_dimens.dart';

/// The shimmer of every Home skeleton: sweeps from start to end (mirrored in RTL) and stands still when
/// the system asks to reduce motion.
PaintingEffect homeSkeletonEffect(BuildContext context) {
  final colors = context.appColors;
  return MediaQuery.disableAnimationsOf(context)
      ? SolidColorEffect(color: colors.skeletonBase)
      : ShimmerEffect(
          baseColor: colors.skeletonBase,
          highlightColor: colors.skeletonHighlight,
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          duration: HomeDimens.skeletonSweep,
        );
}
