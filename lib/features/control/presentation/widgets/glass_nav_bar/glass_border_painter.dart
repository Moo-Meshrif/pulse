import 'package:flutter/material.dart';

import '../../dimens/nav_dimens.dart';

/// A 1 px outline with a vertical gradient: the glass edge and its inner highlights, which a plain
/// `Border` cannot draw (one colour per side, none for a circle).
class GlassBorderPainter extends CustomPainter {
  const GlassBorderPainter({
    required this.radius,
    required this.colors,
    required this.stops,
  });

  final double radius;
  final List<Color> colors;
  final List<double> stops;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = NavDimens.borderWidth
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(NavDimens.borderWidth / 2),
        Radius.circular(radius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(GlassBorderPainter old) =>
      old.radius != radius || old.colors != colors || old.stops != stops;
}
