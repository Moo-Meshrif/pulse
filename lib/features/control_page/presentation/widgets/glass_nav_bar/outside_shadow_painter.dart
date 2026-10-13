import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Paints [shadows] around a rounded shape and nothing inside it. Under a translucent fill a normal
/// `BoxShadow` shows through and greys the fill; here the inside stays clear. Use it as the `painter` of a
/// `CustomPaint` whose child is the shape; the shadow is drawn past the widget's bounds, so an ancestor
/// that clips must leave room for it.
class OutsideShadowPainter extends CustomPainter {
  const OutsideShadowPainter({
    required this.borderRadius,
    required this.shadows,
  });

  final BorderRadius borderRadius;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = borderRadius.toRRect(Offset.zero & size);
    canvas
      ..save()
      ..clipPath(_everythingBut(shape, size))
      ..drawShadows(shape, shadows)
      ..restore();
  }

  /// The whole canvas minus the shape: a rectangle far bigger than any shadow, with the shape cut out.
  Path _everythingBut(RRect shape, Size size) => Path.combine(
    PathOperation.difference,
    Path()..addRect((Offset.zero & size).inflate(_reach)),
    Path()..addRRect(shape),
  );

  /// How far the shadows reach past the shape.
  double get _reach => shadows.fold(
    0,
    (reach, s) => reach + s.blurRadius + s.spreadRadius + s.offset.distance,
  );

  @override
  bool shouldRepaint(OutsideShadowPainter old) =>
      old.borderRadius != borderRadius || !listEquals(old.shadows, shadows);
}

extension on Canvas {
  void drawShadows(RRect shape, List<BoxShadow> shadows) {
    for (final shadow in shadows) {
      drawRRect(
        shape.shift(shadow.offset).inflate(shadow.spreadRadius),
        shadow.toPaint(),
      );
    }
  }
}
