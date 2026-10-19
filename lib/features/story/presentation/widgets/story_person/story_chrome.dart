import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/extensions/l10n.dart';
import '../../../../../core/notice/notices.dart';
import '../../../../../core/router/app_navigator.dart';
import '../../../data/model/story_model.dart';
import '../../../domain/entity/story_rail_item_entity.dart';
import '../../cubit/story_viewer/story_viewer_cubit.dart';
import '../../dimens/story_constants.dart';
import '../../dimens/story_dimens.dart';
import '../../utils/enums/story_pause_reason.dart';
import '../story_count_chip.dart';
import '../story_header.dart';
import '../story_menus/story_menus.dart';
import '../story_paused_chip.dart';
import '../story_progress_bars.dart';
import '../story_reply_bar/story_reply_bar.dart';

class StoryChrome extends StatelessWidget {
  const StoryChrome({
    super.key,
    required this.isVisible,
    required this.person,
    required this.story,
    required this.count,
    required this.index,
    required this.progress,
    required this.isActive,
    this.isOverlayOpen = false,
  });

  final bool isVisible;
  final StoryRailItemEntity person;
  final StoryModel story;
  final int count;
  final int index;
  final ValueNotifier<double> progress;
  final bool isActive;

  /// A sheet or dialog holds the story: the "Paused" chip shows and the header fades.
  final bool isOverlayOpen;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final barsTop = media.viewPadding.top + StoryDimens.barBelowInset;
    final keyboard = media.viewInsets.bottom;
    final bottom =
        (keyboard > 0 ? keyboard : media.viewPadding.bottom) +
        StoryDimens.replyBottom;
    final cubit = context.read<StoryViewerCubit>();
    final fade = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : StoryMotion.uiFade;

    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: fade,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: Stack(
          children: [
            Positioned(
              top: barsTop,
              left: StoryDimens.barSide,
              right: StoryDimens.barSide,
              child: StoryProgressBars(
                count: count,
                index: index,
                progress: progress,
              ),
            ),
            Positioned(
              top: barsTop + StoryDimens.headerBelowBars,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: isOverlayOpen ? StoryOpacity.pausedHeader : 1,
                duration: fade,
                child: StoryHeader(
                  person: person,
                  postedAt: story.createdAt,
                  onMore: () => StoryMenus.showOptions(context),
                  onClose: () => AppNavigator.back(context),
                ),
              ),
            ),
            if (isOverlayOpen)
              Positioned(
                top:
                    media.viewPadding.top +
                    StorySheetDimens.pausedChipBelowInset,
                left: 0,
                right: 0,
                child: const Center(child: StoryPausedChip()),
              ),
            Positioned(
              bottom: bottom,
              left: StoryDimens.replySide,
              right: StoryDimens.replySide,
              child: person.isMe
                  ? Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: StoryCountChip(
                        count: story.viewCount ?? 0,
                        onTap: () => StoryMenus.showViewers(context),
                      ),
                    )
                  : StoryReplyBar(
                      isLiked: story.likedByMe ?? false,
                      onLike: cubit.toggleLike,
                      // TODO(story-plan B3): replies go to Chat when it exists.
                      onSend: () => Notices.info(context.l10n.storyReplySoon),
                      onFocusChanged: (focused) => focused
                          ? cubit.pause(StoryPauseReason.keyboard)
                          : cubit.resume(StoryPauseReason.keyboard),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
