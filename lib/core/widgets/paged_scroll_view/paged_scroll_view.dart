import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state/load_more_status.dart';
import '../../theme/dimens/app_dimens.dart';
import '../app_loading_view.dart';
import '../load_more_listener.dart';
import 'caught_up_row.dart';
import 'refresh_icon.dart';
import 'retry_row.dart';

/// What the list needs to know about its paging; a record, so equal values do not rebuild.
typedef PagingInfo = ({
  bool isRefreshing,
  LoadMoreStatus loadMore,
  bool hasMore,
});

/// A scrolling page with every refresh and load-more step in one place: pull to refresh (the screen's nav icon
/// fills in while pulling and pulses until [onRefresh] completes), the same icon for a refresh that
/// was not pulled, the next page starting near the end, the skeleton or loader while it comes, "Couldn't load more · Retry"
/// when it failed and "all caught up" after the last page.
///
/// [slivers] sit between the refresh band and the footer; [headerSlivers] sit above the band. Only the
/// band and the footer follow [paging], so the rows do not rebuild while a page loads.
class PagedScrollView<C extends StateStreamable<S>, S> extends StatefulWidget {
  const PagedScrollView({
    super.key,
    required this.paging,
    required this.onRefresh,
    required this.onLoadMore,
    required this.retryLabel,
    required this.caughtUpLabel,
    required this.refreshIcon,
    required this.refreshIconFilled,
    required this.slivers,
    this.loadMoreSkeleton,
    this.headerSlivers = const [],
    this.bottomSpace = 0,
  });

  /// Picks the paging facts from the Cubit's state.
  final PagingInfo Function(S state) paging;
  final Future<void> Function() onRefresh;

  /// Called when the list nears its end and no page is loading or failed; also the Retry tap.
  final VoidCallback onLoadMore;
  final String retryLabel;
  final String caughtUpLabel;

  /// The screen's nav icon (outline and filled) that shows while refreshing.
  final String refreshIcon;
  final String refreshIconFilled;
  final List<Widget> slivers;
  final List<Widget> headerSlivers;

  /// Shown while the next page loads when the rows shimmer; null for the pulse line loader.
  final Widget? loadMoreSkeleton;

  /// Space under the last row, e.g. the nav bar.
  final double bottomSpace;

  @override
  State<PagedScrollView<C, S>> createState() => _PagedScrollViewState<C, S>();
}

class _PagedScrollViewState<C extends StateStreamable<S>, S>
    extends State<PagedScrollView<C, S>> {
  static const _bandDuration = Duration(milliseconds: 250);

  // True while a pulled refresh runs: its own line is on screen, so the band stays hidden.
  final _isPulling = ValueNotifier(false);

  @override
  void dispose() {
    _isPulling.dispose();
    super.dispose();
  }

  // The control arms on any overscroll, also the bounce after a fast fling and a quick swipe up that runs
  // past the top. Only a finger that pulls past the trigger distance, slowly, counts as a refresh.
  static const _triggerPull = 100.0;
  static const _maxPullSpeed = 1200.0; // pixels per second
  bool _fingerPulled = false;
  int _lastMicros = 0;
  double _lastPixels = 0;

  bool _trackFinger(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final pixels = notification.metrics.pixels;
    final now = clock.now().microsecondsSinceEpoch;
    if (notification is ScrollStartNotification) {
      _fingerPulled = false;
    } else if (notification is ScrollUpdateNotification) {
      final seconds = (now - _lastMicros) / Duration.microsecondsPerSecond;
      final speed = seconds <= 0 ? 0 : (pixels - _lastPixels).abs() / seconds;
      _fingerPulled =
          notification.dragDetails != null &&
          pixels <= -_triggerPull &&
          speed <= _maxPullSpeed;
    }
    _lastMicros = now;
    _lastPixels = pixels;
    return false;
  }

  Future<void> _pullRefresh() async {
    if (!_fingerPulled) return;
    _fingerPulled = false;
    _isPulling.value = true;
    try {
      await widget.onRefresh();
    } finally {
      _isPulling.value = false;
    }
  }

  // A failed page waits for the Retry tap instead of retrying on every scroll.
  void _loadMoreIfIdle(BuildContext context) {
    final state = context.read<C>().state;
    if (widget.paging(state).loadMore == LoadMoreStatus.idle) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) => LoadMoreListener(
    onLoadMore: () => _loadMoreIfIdle(context),
    child: NotificationListener<ScrollNotification>(
      onNotification: _trackFinger,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          ...widget.headerSlivers,
          CupertinoSliverRefreshControl(
            onRefresh: _pullRefresh,
            refreshIndicatorExtent: LoadingDimens.refreshBand,
            builder: _buildRefreshIndicator,
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isPulling,
              builder: (context, isPulling, _) => BlocSelector<C, S, bool>(
                selector: (state) => widget.paging(state).isRefreshing,
                builder: (context, isRefreshing) =>
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: isRefreshing && !isPulling ? 1 : 0),
                      duration: _bandDuration,
                      curve: Curves.easeOut,
                      builder: (context, t, child) => t == 0
                          ? const SizedBox(width: double.infinity)
                          : ClipRect(
                              child: Align(
                                alignment: Alignment.topCenter,
                                heightFactor: t,
                                child: Opacity(opacity: t, child: child),
                              ),
                            ),
                      child: SizedBox(
                        height: LoadingDimens.refreshBand,
                        child: Center(
                          child: _icon(progress: 1, isRefreshing: true),
                        ),
                      ),
                    ),
              ),
            ),
          ),
          ...widget.slivers,
          SliverToBoxAdapter(
            child: BlocSelector<C, S, (LoadMoreStatus, bool)>(
              selector: (state) {
                final info = widget.paging(state);
                return (info.loadMore, info.hasMore);
              },
              builder: (context, step) => switch (step) {
                (LoadMoreStatus.loading, _) =>
                  widget.loadMoreSkeleton ?? const AppInlineLoading.loadMore(),
                (LoadMoreStatus.failed, _) => RetryRow(
                  label: widget.retryLabel,
                  onTap: widget.onLoadMore,
                ),
                (LoadMoreStatus.idle, false) => CaughtUpRow(
                  label: widget.caughtUpLabel,
                ),
                (LoadMoreStatus.idle, true) => const SizedBox.shrink(),
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: widget.bottomSpace)),
        ],
      ),
    ),
  );

  Widget _icon({required double progress, required bool isRefreshing}) =>
      RefreshIcon(
        icon: widget.refreshIcon,
        filledIcon: widget.refreshIconFilled,
        progress: progress,
        isRefreshing: isRefreshing,
      );

  // Pulling fills the icon in; once the refresh runs it pulses, also while the list scrolls it away.
  Widget _buildRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode mode,
    double pulledExtent,
    double triggerDistance,
    double indicatorExtent,
  ) => Center(
    child: _icon(
      progress: pulledExtent / triggerDistance,
      isRefreshing: mode == RefreshIndicatorMode.refresh,
    ),
  );
}
