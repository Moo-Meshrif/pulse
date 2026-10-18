import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One page of the people pager turned like a face of a cube: the page on screen and its neighbour hinge
/// on the edge they share while the pager moves.
class StoryCubePage extends StatelessWidget {
  const StoryCubePage({
    super.key,
    required this.pages,
    required this.index,
    required this.child,
  });

  static const _quarterTurn = math.pi / 2;
  static const _perspective = 0.001;

  final PageController pages;
  final int index;
  final Widget child;

  /// Where this page is against the one on screen: 0 on screen, -1 one page before, 1 one page after.
  double _offset() {
    if (!pages.hasClients || !pages.position.haveDimensions) return 0;
    return ((pages.page ?? index.toDouble()) - index).clamp(-1.0, 1.0) * -1;
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return AnimatedBuilder(
      animation: pages,
      child: child,
      builder: (context, child) {
        final offset = _offset();
        if (offset == 0) return child!;
        // The hinge is the edge facing the page on screen; RTL flips the pager, so the turn flips too.
        final turn = offset * _quarterTurn * (isRtl ? 1 : -1);
        final hingeOnStart = (offset < 0) == !isRtl;
        return Transform(
          alignment: hingeOnStart
              ? Alignment.centerRight
              : Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, _perspective)
            ..rotateY(turn),
          child: child,
        );
      },
    );
  }
}
