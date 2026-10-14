import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The dashed circle of the "Your story" tile.
class DashedRingPainter extends CustomPainter {
  const DashedRingPainter({required this.color, required this.width});

  final Color color;
  final double width;

  static const _dash = 6.0; // unscaled: dash pattern
  static const _gap = 5.0; // unscaled: dash pattern

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final ring = Path()
      ..addOval(
        Rect.fromLTWH(0, 0, size.width, size.height).deflate(width / 2),
      );
    for (final metric in ring.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash + _gap) {
        canvas.drawPath(
          metric.extractPath(at, math.min(at + _dash, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DashedRingPainter old) =>
      old.color != color || old.width != width;
}

/// A ring: [color] over a [track] circle, for the first [progress] (0..1) of the way round from 12
/// o'clock. Progress 1 with no track is the full ring of a failed upload.
class ProgressRingPainter extends CustomPainter {
  const ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.track,
    required this.width,
  });

  final double progress;
  final Color color;
  final Color? track;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    if (track != null) {
      canvas.drawOval(rect, paint..color = track!);
    }
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      paint..color = color,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.track != track ||
      old.width != width;
}
