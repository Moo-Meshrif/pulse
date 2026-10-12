import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/l10n.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import 'app_text.dart';
import 'loading_overlay/pulse_line_loader.dart';

/// A page that waits for its data: the heartbeat line centered in the available space, announced as
/// "Loading" (the "Page loading" board, cases 1 and 2). For pages without a skeleton or shimmer. Put it inside the page body, under the chrome (header, nav) that is already there.
///
/// `AppLoadingView()` is 100 wide; the [label] under the line is optional.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.label});

  /// Shown under the line; null for none.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = this.label;
    return Center(
      child: Semantics(
        liveRegion: true,
        label: label ?? context.l10n.loading,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseLineLoader(
                color: colors.primary,
                width: LoadingDimens.pageWidth,
              ),
              if (label != null) ...[
                SizedBox(height: LoadingDimens.labelGap),
                AppText(
                  label,
                  style: context.text.bodySm,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The line inside a list: a band that keeps its place while content refreshes or grows (the board's
/// cases 3 and 4). `.refresh()` is the 64 band under the header during pull to refresh; `.loadMore()` is
/// the 72 band at the end of a list, above the nav.
class AppInlineLoading extends StatelessWidget {
  const AppInlineLoading.refresh({super.key}) : _loadMore = false;

  const AppInlineLoading.loadMore({super.key}) : _loadMore = true;

  final bool _loadMore;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _loadMore ? LoadingDimens.loadMoreBand : LoadingDimens.refreshBand,
    child: Center(
      child: Semantics(
        liveRegion: true,
        label: context.l10n.loading,
        child: PulseLineLoader(
          color: context.appColors.primary,
          width: _loadMore
              ? LoadingDimens.loadMoreWidth
              : LoadingDimens.refreshWidth,
        ),
      ),
    ),
  );
}
