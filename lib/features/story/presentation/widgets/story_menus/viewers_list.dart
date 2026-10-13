import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../cubit/story_viewers_cubit.dart';
import '../../cubit/story_viewers_state.dart';
import '../../utils/enums/story_viewers_status.dart';
import 'viewer_row.dart';

class ViewersList extends StatelessWidget {
  const ViewersList({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoryViewersCubit>();
    return BlocBuilder<StoryViewersCubit, StoryViewersState>(
      builder: (context, state) {
        switch (state.status) {
          case StoryViewersStatus.loading:
            return Center(
              child: PulseLineLoader(
                color: context.appColors.storyOnDark,
                width: LoadingDimens.loadMoreWidth,
              ),
            );
          case StoryViewersStatus.failed:
            return _Retry(onRetry: cubit.retry);
          case StoryViewersStatus.ready:
            if (state.viewers.isEmpty) {
              return Center(
                child: AppText(
                  context.l10n.storyViewersEmpty,
                  style: context.text.bodySm,
                  color: context.appColors.storyOnDark.withValues(
                    alpha: StoryOpacity.subtitle,
                  ),
                ),
              );
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < StoryDimens.viewerRowHeight * 3) {
                  cubit.loadMore();
                }
                return false;
              },
              child: ListView.builder(
                controller: controller,
                padding: EdgeInsets.symmetric(
                  horizontal: BottomSheetDimens.sidePadding,
                ),
                itemCount: state.viewers.length + 1,
                itemBuilder: (context, i) => i < state.viewers.length
                    ? ViewerRow(viewer: state.viewers[i])
                    : _Footer(state: state, onRetry: cubit.loadMore),
              ),
            );
        }
      },
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onRetry});

  final StoryViewersState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.loadMoreFailed) return _Retry(onRetry: onRetry);
    if (state.isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
        child: Center(
          child: PulseLineLoader(
            color: context.appColors.storyOnDark,
            width: LoadingDimens.loadMoreWidth,
          ),
        ),
      );
    }
    return SizedBox(height: AppSpacing.s16);
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          context.l10n.storyViewersLoadFailed,
          style: context.text.bodySm,
          color: context.appColors.storyOnDark.withValues(
            alpha: StoryOpacity.subtitle,
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: AppText(
            context.l10n.retry,
            style: context.text.name,
            color: context.appColors.storyOnDark,
          ),
        ),
      ],
    ),
  );
}
