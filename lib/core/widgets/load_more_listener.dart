import 'package:flutter/widgets.dart';

/// Calls [onLoadMore] while the scrollable below it is within [triggerDistance] of its end, on every
/// scroll and layout change (a first page shorter than the screen never scrolls). [onLoadMore] is
/// called repeatedly, so it must ignore a call while a page is already loading.
class LoadMoreListener extends StatelessWidget {
  const LoadMoreListener({
    super.key,
    required this.onLoadMore,
    required this.child,
    this.triggerDistance,
  });

  static const _defaultViewports = 1.5;

  final VoidCallback onLoadMore;
  final Widget child;

  /// Pixels left to scroll that start the next page. Defaults to 1.5 screen heights.
  final double? triggerDistance;

  // Only the list's own scroll counts: a carousel or rail inside it scrolls sideways at a deeper level.
  bool _loadMoreNearEnd(Notification notification) {
    final (metrics, depth) = switch (notification) {
      ScrollNotification(:final metrics, :final depth) => (metrics, depth),
      ScrollMetricsNotification(:final metrics, :final depth) => (
        metrics,
        depth,
      ),
      _ => (null, 0),
    };
    if (metrics == null || depth != 0) return false;
    final distance =
        triggerDistance ?? metrics.viewportDimension * _defaultViewports;
    if (metrics.extentAfter < distance) onLoadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) => NotificationListener<Notification>(
    onNotification: _loadMoreNearEnd,
    child: child,
  );
}
