import 'package:flutter/material.dart';

import '../../dimens/post_card_dimens.dart';

/// Puts a label's pointer tip on [anchor], inside the photo's width.
class TagSpotLayout extends SingleChildLayoutDelegate {
  const TagSpotLayout({
    required this.anchor,
    required this.above,
    required this.isOwn,
  });

  final Offset anchor;
  final bool above;
  final bool isOwn;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final dx = (anchor.dx - childSize.width / 2).clamp(
      0.0,
      (size.width - childSize.width).clamp(0.0, double.infinity),
    );
    final dy = above ? anchor.dy - childSize.height : anchor.dy;
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(TagSpotLayout old) =>
      old.anchor != anchor || old.above != above || old.isOwn != isOwn;
}

/// [child] with a small triangle toward the spot: under it when the label is above, over it otherwise.
class TagPointerWrap extends StatelessWidget {
  const TagPointerWrap({
    super.key,
    required this.above,
    required this.color,
    required this.child,
  });

  final bool above;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pointer = CustomPaint(
      size: Size(PostCardDimens.tagPointer * 2, PostCardDimens.tagPointer),
      painter: _PointerPainter(color: color, pointsDown: above),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: above ? [child, pointer] : [pointer, child],
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter({required this.color, required this.pointsDown});

  final Color color;
  final bool pointsDown;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, pointsDown ? 0 : size.height)
      ..lineTo(size.width, pointsDown ? 0 : size.height)
      ..lineTo(size.width / 2, pointsDown ? size.height : 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter old) =>
      old.color != color || old.pointsDown != pointsDown;
}
