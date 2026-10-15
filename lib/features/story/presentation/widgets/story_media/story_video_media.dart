import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/utils/app_video_controller.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/model/story_model.dart';
import '../../utils/story_picture.dart';
import '../story_buffering_loader.dart';

class StoryVideoMedia extends StatefulWidget {
  const StoryVideoMedia({
    super.key,
    required this.story,
    required this.controller,
    required this.hasFailed,
    required this.isRunning,
    required this.progress,
    required this.restarts,
    required this.onCompleted,
    required this.onRetry,
  });

  final StoryModel story;
  final AppVideoController? controller;
  final bool hasFailed;
  final bool isRunning;
  final ValueNotifier<double> progress;
  final int restarts;
  final VoidCallback onCompleted;
  final VoidCallback? onRetry;

  @override
  State<StoryVideoMedia> createState() => _StoryVideoMediaState();
}

class _StoryVideoMediaState extends State<StoryVideoMedia> {
  /// Within this of the end counts as played through (the last frame is rarely reported).
  static const _endSlack = Duration(milliseconds: 150);

  bool _isCompleted = false;

  /// Runs [action] once this frame is built: playing, seeking and the bar must not change while widgets
  /// are still building (the player tells its listener at once, and the bar listens to it).
  void _afterFrame(VoidCallback action) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) action();
      });

  /// The bar starts empty for a new story.
  void _resetProgress() => _afterFrame(() => widget.progress.value = 0);

  VideoPlayerController? get _player => widget.controller?.player;

  @override
  void initState() {
    super.initState();
    _resetProgress();
    _player?.addListener(_onValue);
    _afterFrame(_sync);
  }

  @override
  void didUpdateWidget(StoryVideoMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller?.player != _player) {
      oldWidget.controller?.player.removeListener(_onValue);
      _player?.addListener(_onValue);
    }
    if (oldWidget.restarts != widget.restarts) _afterFrame(_restart);
    _afterFrame(_sync);
  }

  @override
  void dispose() {
    _player?.removeListener(_onValue);
    super.dispose();
  }

  void _restart() {
    _isCompleted = false;
    widget.progress.value = 0;
    _player?.seekTo(Duration.zero);
  }

  /// Plays while nothing pauses the story; a preloaded video that arrives paused waits here.
  void _sync() {
    final player = _player;
    if (player == null || !player.value.isInitialized) return;
    if (widget.isRunning && !_isCompleted) {
      if (!player.value.isPlaying) player.play();
    } else if (player.value.isPlaying) {
      player.pause();
    }
  }

  void _onValue() {
    final value = _player!.value;
    if (!value.isInitialized) return;
    final total = value.duration.inMilliseconds;
    if (total > 0) {
      widget.progress.value = (value.position.inMilliseconds / total).clamp(
        0.0,
        1.0,
      );
    }
    if (!_isCompleted &&
        total > 0 &&
        value.position >= value.duration - _endSlack) {
      _isCompleted = true;
      widget.onCompleted();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    final ready = player != null && player.value.isInitialized;
    if (widget.hasFailed) {
      return AppEmpty.failed(
        tone: AppEmptyTone.onDark,
        onRetry: widget.onRetry ?? () {},
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (storyPicture(widget.story) case final poster?)
          AppImage.network(
            poster.url,
            cacheKey: poster.cacheKey,
            fit: BoxFit.cover,
          ),
        if (ready)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: player.value.size.width,
                height: player.value.size.height,
                child: VideoPlayer(player),
              ),
            ),
          ),
        StoryBufferingLoader(isWaiting: !ready || player.value.isBuffering),
      ],
    );
  }
}
