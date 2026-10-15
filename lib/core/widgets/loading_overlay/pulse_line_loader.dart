import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_assets.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_svg_icon.dart';

/// The app's heartbeat line (taken from the logo) with a soft glowing segment tracing across it, played
/// from a Lottie file. With "reduce motion" on it is the still line instead. Decorative: the overlay
/// around it carries the announcement.
class PulseLineLoader extends StatelessWidget {
  const PulseLineLoader({super.key, required this.color, this.width});

  /// The line's colour; every stroke of the animation is recoloured to it, opacities as designed.
  final Color color;

  /// Defaults to `OverlayDimens.lineWidth`; the height follows the animation's 184 x 88 frame.
  final double? width;

  /// Height over width of the animation's frame (184 x 88).
  static const aspect = 88 / 184;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final width = this.width ?? OverlayDimens.lineWidth;
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: width * aspect,
        child: reduceMotion
            ? AppSvgIcon(AppAssets.pulseLine, size: width, color: color)
            : Lottie.asset(
                // A white line sits on the dark scrim: its file has the glow tuned for that.
                color.computeLuminance() > 0.9
                    ? AppAssets.loaderDark
                    : AppAssets.loaderLight,
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.strokeColor(const ['**'], value: color),
                  ],
                ),
              ),
      ),
    );
  }
}
