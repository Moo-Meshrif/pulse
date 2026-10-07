import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';

/// The illustration panel: 420 high, radius 32, 20 side margins, clipped. It shows the
/// illustration PNG (text baked in, one per language, square corners: the radius comes
/// from the `ClipRRect` below, not from the image) over its fill color. While the PNG
/// is missing it shows the bare fill. Decorative: excluded from semantics.
class OnboardingPanel extends StatelessWidget {
  const OnboardingPanel({
    super.key,
    required this.fill,
    required this.imageAsset,
  });

  final Color fill;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    // Height follows the window (at most half of it, so the text and the footer stay in view) and
    // the width keeps the art's aspect, so a wide window shows a centered card, not a cropped banner.
    final height = math.min(
      OnboardingDimens.panelHeight,
      MediaQuery.sizeOf(context).height * 0.5,
    );
    return Padding(
      padding: OnboardingDimens.panelMargin,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: height * OnboardingDimens.panelAspect,
          ),
          child: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(OnboardingDimens.panelRadius),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: ColoredBox(
                  color: fill,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
