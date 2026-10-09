import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// A flat `segmentTrack` placeholder with fully rounded ends (no shimmer), shown while a list loads.
class SkeletonPill extends StatelessWidget {
  const SkeletonPill({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.segmentTrack,
        borderRadius: BorderRadius.circular(AppRadius.pill(height)),
      ),
    ),
  );
}
