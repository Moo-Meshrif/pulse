import 'dart:math' as math;

import 'package:flutter/material.dart';

class DashedRoundedRectPainter extends CustomPainter {
  DashedRoundedRectPainter({
    required this.color,
    required this.radius,
    required this.width,
  });

  static const _dash = 6.0; // unscaled: dash pattern
  static const _gap = 4.0; // unscaled: dash pattern

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final inset = width / 2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - 2 * inset,
            size.height - 2 * inset,
          ),
          Radius.circular(radius),
        ),
      );
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(at, math.min(at + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DashedRoundedRectPainter old) =>
      old.color != color || old.radius != radius || old.width != width;
}
