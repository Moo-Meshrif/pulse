import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state/load_more_status.dart';
import '../app_loading_view.dart';
import '../load_more_listener.dart';
import 'caught_up_row.dart';
import 'retry_row.dart';

/// What the list needs to know about its paging; a record, so equal values do not rebuild.
typedef PagingInfo = ({
  bool isRefreshing,
  LoadMoreStatus loadMore,
  bool hasMore,
});

/// A scrolling page with every refresh and load-more step in one place: pull to refresh, the refresh
/// band under the header, the next page starting near the end, the loader while it comes, "Couldn't
/// load more · Retry" when it failed and "all caught up" after the last page.
///
/// [slivers] sit between the refresh band and the footer; [headerSlivers] sit above the band. Only the
/// band and the footer follow [paging], so the rows do not rebuild while a page loads.
class PagedScrollView<C extends StateStreamable<S>, S> extends StatelessWidget {
  const PagedScrollView({
    super.key,
    required this.paging,
    required this.onRefresh,
    required this.onLoadMore,
    required this.retryLabel,
    required this.caughtUpLabel,
    required this.slivers,
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
  final List<Widget> slivers;
  final List<Widget> headerSlivers;

  /// Space under the last row, e.g. the nav bar.
  final double bottomSpace;

  // A failed page waits for the Retry tap instead of retrying on every scroll.
  void _loadMoreIfIdle(BuildContext context) {
    final state = context.read<C>().state;
    if (paging(state).loadMore == LoadMoreStatus.idle) onLoadMore();
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator.noSpinner(
    onRefresh: onRefresh,
    child: LoadMoreListener(
      onLoadMore: () => _loadMoreIfIdle(context),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          ...headerSlivers,
          SliverToBoxAdapter(
            child: BlocSelector<C, S, bool>(
              selector: (state) => paging(state).isRefreshing,
              builder: (context, isRefreshing) => isRefreshing
                  ? const AppInlineLoading.refresh()
                  : const SizedBox.shrink(),
            ),
          ),
          ...slivers,
          SliverToBoxAdapter(
            child: BlocSelector<C, S, (LoadMoreStatus, bool)>(
              selector: (state) {
                final info = paging(state);
                return (info.loadMore, info.hasMore);
              },
              builder: (context, step) => switch (step) {
                (LoadMoreStatus.loading, _) =>
                  const AppInlineLoading.loadMore(),
                (LoadMoreStatus.failed, _) => RetryRow(
                  label: retryLabel,
                  onTap: onLoadMore,
                ),
                (LoadMoreStatus.idle, false) => CaughtUpRow(
                  label: caughtUpLabel,
                ),
                (LoadMoreStatus.idle, true) => const SizedBox.shrink(),
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottomSpace)),
        ],
      ),
    ),
  );
}
