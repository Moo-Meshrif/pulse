import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A recolored SVG icon. Only icons that indicate direction (back, forward, chevrons,
/// share) pass `directional: true`; they flip in RTL. Symmetric icons never flip
/// (docs/specs/_theme/rtl.md).
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon(
    this.asset, {
    super.key,
    required this.size,
    required this.color,
    this.directional = false,
  });

  final String asset;
  final double size;
  final Color color;
  final bool directional;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
    if (!directional) return icon;
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: icon,
    );
  }
}
