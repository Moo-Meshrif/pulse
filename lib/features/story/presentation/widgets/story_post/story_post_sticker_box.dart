import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/utils/story_post_args.dart';
import '../../../data/enums/story_post_sticker_style.dart';
import '../../../data/model/story_overlay_model.dart';
import '../../dimens/story_dimens.dart';
import '../story_overlays_layer.dart';
import 'story_post_sticker.dart';

/// The post sticker on the edit screen: drag with one finger, pinch to size, twist to turn, tap for the
/// next style. A dashed outline shows it is the selected one. Positions are fractions of this canvas, so
/// they match the viewer.
class StoryPostStickerBox extends StatefulWidget {
  const StoryPostStickerBox({
    super.key,
    required this.post,
    required this.style,
    required this.x,
    required this.y,
    required this.scale,
    required this.rotation,
    required this.onTap,
    required this.onTransform,
  });

  final StoryPostArgs post;
  final StoryPostStickerStyle style;
  final double x;
  final double y;
  final double scale;

  /// Degrees.
  final double rotation;
  final VoidCallback onTap;
  final void Function({double? x, double? y, double? scale, double? rotation})
  onTransform;

  @override
  State<StoryPostStickerBox> createState() => _StoryPostStickerBoxState();
}

class _StoryPostStickerBoxState extends State<StoryPostStickerBox> {
  double _baseScale = 1;
  double _baseRotation = 0;

  void _start(ScaleStartDetails _) {
    _baseScale = widget.scale;
    _baseRotation = widget.rotation;
  }

  void _update(ScaleUpdateDetails details) {
    final size = (context.findRenderObject() as RenderBox).size;
    widget.onTransform(
      x: widget.x + details.focalPointDelta.dx / size.width,
      y: widget.y + details.focalPointDelta.dy / size.height,
      scale: _baseScale * details.scale,
      rotation: _baseRotation + details.rotation * 180 / math.pi,
    );
  }

  @override
  Widget build(BuildContext context) => StoryOverlayPlacement(
    overlay: StoryOverlayModel(
      x: widget.x,
      y: widget.y,
      scale: widget.scale,
      rotation: widget.rotation,
    ),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onScaleStart: _start,
      onScaleUpdate: _update,
      child: CustomPaint(
        // The outline is dashed, which no decoration draws.
        foregroundPainter: _DashedOutline(
          color: context.appColors.onDark,
          width: StoryPostDimens.outlineWidth,
          offset: StoryPostDimens.outlineOffset,
          dash: StoryPostDimens.dashLength,
          gap: StoryPostDimens.dashGap,
          radius: StoryPostDimens.cardRadius + StoryPostDimens.outlineOffset,
        ),
        child: StoryPostSticker(post: widget.post, style: widget.style),
      ),
    ),
  );
}

/// A dashed rounded rectangle [offset] outside the child's box.
class _DashedOutline extends CustomPainter {
  const _DashedOutline({
    required this.color,
    required this.width,
    required this.offset,
    required this.dash,
    required this.gap,
    required this.radius,
  });

  final Color color;
  final double width;
  final double offset;
  final double dash;
  final double gap;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).inflate(offset),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += dash + gap) {
        canvas.drawPath(metric.extractPath(at, at + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutline old) =>
      old.color != color ||
      old.width != width ||
      old.offset != offset ||
      old.dash != dash ||
      old.gap != gap ||
      old.radius != radius;
}
