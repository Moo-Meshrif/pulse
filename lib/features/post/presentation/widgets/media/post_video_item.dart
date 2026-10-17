import 'package:flutter/material.dart';
import 'package:video_flux/video_flux.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/utils/app_video_controller.dart';
import '../../../../../core/utils/format_countdown.dart';
import '../../dimens/post_card_dimens.dart';
import '../../utils/post_card_media.dart';
import '../post_video_scope.dart';
import '../visible_fraction.dart';
import 'post_blurhash.dart';
import 'post_image_item.dart';
import 'post_media_chip.dart';
import 'post_mute_button.dart';
import 'post_retry_badge.dart';

/// One video of a post: its poster (or blurhash) with the duration. The list's [PostVideoScope] owns the
/// player: it plays this video while it is the picked one and frees it when it leaves the window. Outside a
/// scope the video stays still, with its poster.
class PostVideoItem extends StatefulWidget {
  const PostVideoItem({
    super.key,
    required this.id,
    required this.media,
    required this.isCurrent,
  });

  /// Stable id of this video in the list (`postVideoId`).
  final String id;
  final PostCardMedia media;

  /// False while another page of the same post is showing.
  final bool isCurrent;

  @override
  State<PostVideoItem> createState() => _PostVideoItemState();
}

class _PostVideoItemState extends State<PostVideoItem> {
  double _fraction = 0;
  PostVideos? _videos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _videos = PostVideoScope.of(context);
  }

  @override
  void didUpdateWidget(PostVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCurrent != oldWidget.isCurrent) _report();
  }

  @override
  void dispose() {
    _videos?.coordinator.report(widget.id, 0);
    super.dispose();
  }

  /// A page of the post that is not showing is not visible, whatever the list's scroll says.
  void _report() =>
      _videos?.coordinator.report(widget.id, widget.isCurrent ? _fraction : 0);

  void _onVisible(double fraction) {
    _fraction = fraction;
    _report();
  }

  @override
  Widget build(BuildContext context) {
    final videos = _videos;
    final duration = widget.media.duration;
    return VisibleFraction(
      onChanged: _onVisible,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.media.posterUrl != null)
            PostImageItem(
              media: widget.media,
              url: widget.media.posterUrl,
              fit: BoxFit.cover,
              cacheKey: widget.media.posterCacheKey,
            )
          else
            PostBlurhash(hash: widget.media.blurhash),
          if (videos != null)
            ValueListenableBuilder(
              valueListenable: videos.flux.controllerStates,
              builder: (context, states, _) =>
                  _Player(id: widget.id, flux: videos.flux, states: states),
            ),
          if (duration != null)
            PositionedDirectional(
              start: PostCardDimens.mediaInset,
              bottom: PostCardDimens.mediaInset,
              child: PostMediaChip(text: formatCountdown(duration)),
            ),
          PositionedDirectional(
            end: PostCardDimens.mediaInset,
            bottom: PostCardDimens.mediaInset,
            child: videos == null
                ? PostMuteButton(isMuted: true, onTap: () {})
                : ListenableBuilder(
                    listenable: videos.coordinator,
                    builder: (context, _) => PostMuteButton(
                      isMuted: videos.coordinator.isMuted,
                      onTap: videos.coordinator.toggleMute,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The live picture of a video the window holds, or its retry badge when it could not open.
class _Player extends StatelessWidget {
  const _Player({required this.id, required this.flux, required this.states});

  final String id;
  final VideoFlux<AppVideoItem> flux;
  final List<VideoFluxState<AppVideoItem>> states;

  @override
  Widget build(BuildContext context) {
    final state = states.where((s) => s.item.id == id).firstOrNull;
    if (state?.status == VideoFluxStatus.failed) {
      return PostRetryBadge(
        icon: AppAssets.play,
        onRetry: () => flux.retry(state!.index),
      );
    }
    final controller = state?.controller;
    if (state?.status != VideoFluxStatus.ready ||
        controller is! AppVideoController ||
        !controller.isInitialized) {
      return const SizedBox.shrink();
    }
    final player = controller.player;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: player.value.size.width,
        height: player.value.size.height,
        child: VideoPlayer(player),
      ),
    );
  }
}
