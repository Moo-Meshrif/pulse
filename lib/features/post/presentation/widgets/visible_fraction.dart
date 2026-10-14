import 'package:flutter/material.dart';

/// Reports how much of [child] shows inside the nearest scrollable, 0 to 1, as the list scrolls and after
/// it is first laid out or updated. A child outside any scrollable counts as fully visible. Reports 0 when
/// it goes away.
class VisibleFraction extends StatefulWidget {
  const VisibleFraction({
    super.key,
    required this.onChanged,
    required this.child,
  });

  final ValueChanged<double> onChanged;
  final Widget child;

  @override
  State<VisibleFraction> createState() => _VisibleFractionState();
}

class _VisibleFractionState extends State<VisibleFraction> {
  static const _minChange = 0.01;

  ScrollPosition? _position;
  double _last = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_measure);
      _position = position?..addListener(_measure);
    }
    _measureAfterLayout();
  }

  @override
  void didUpdateWidget(VisibleFraction oldWidget) {
    super.didUpdateWidget(oldWidget);
    _measureAfterLayout();
  }

  @override
  void dispose() {
    _position?.removeListener(_measure);
    if (_last > 0) widget.onChanged(0);
    super.dispose();
  }

  void _measureAfterLayout() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

  void _measure() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
    var fraction = 1.0;
    if (viewport is RenderBox && viewport.attached && viewport.hasSize) {
      final mine = box.localToGlobal(Offset.zero) & box.size;
      final theirs = viewport.localToGlobal(Offset.zero) & viewport.size;
      final overlap = mine.intersect(theirs);
      fraction = box.size.height <= 0 || overlap.height < 0
          ? 0
          : (overlap.height / box.size.height).clamp(0.0, 1.0);
    }
    if ((fraction - _last).abs() < _minChange) return;
    _last = fraction;
    widget.onChanged(fraction);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
