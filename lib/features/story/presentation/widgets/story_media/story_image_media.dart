import 'package:flutter/material.dart';

import '../../../../../core/error/error_reporter.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../data/model/story_model.dart';
import '../../dimens/story_constants.dart';
import '../../utils/story_picture.dart';
import '../story_buffering_loader.dart';

class StoryImageMedia extends StatefulWidget {
  const StoryImageMedia({
    super.key,
    required this.story,
    required this.isRunning,
    required this.progress,
    required this.restarts,
    required this.onCompleted,
    this.onFailedChanged,
  });

  final StoryModel story;
  final bool isRunning;
  final ValueNotifier<double> progress;
  final int restarts;
  final VoidCallback onCompleted;

  /// Called with true when the picture fails to load and with false when a retry starts.
  final ValueChanged<bool>? onFailedChanged;

  @override
  State<StoryImageMedia> createState() => _StoryImageMediaState();
}

class _StoryImageMediaState extends State<StoryImageMedia>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bar =
      AnimationController(vsync: this, duration: StoryTiming.image)
        ..addListener(() => widget.progress.value = _bar.value)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onCompleted();
        });

  bool _isReady = false;
  bool _hasFailed = false;
  int _attempt = 0;

  /// Runs [action] once this frame is built: the bar must not change while widgets are still building.
  void _afterFrame(VoidCallback action) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) action();
      });

  @override
  void didUpdateWidget(StoryImageMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restarts != widget.restarts) {
      _afterFrame(() => _bar.value = 0);
    }
    _afterFrame(_sync);
  }

  @override
  void dispose() {
    _bar.dispose();
    super.dispose();
  }

  /// Runs the bar while the picture is on screen and nothing pauses it.
  void _sync() {
    if (_isReady && !_hasFailed && widget.isRunning) {
      if (!_bar.isAnimating && !_bar.isCompleted) _bar.forward();
    } else {
      _bar.stop();
    }
  }

  void _markReady() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || _isReady) return;
    setState(() => _isReady = true);
    _sync();
  });

  void _markFailed() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || _hasFailed) return;
    setState(() => _hasFailed = true);
    widget.onFailedChanged?.call(true);
    _sync();
  });

  Future<void> _retry() async {
    await forgetStoryPicture(widget.story);
    if (!mounted) return;
    setState(() {
      _attempt++;
      _hasFailed = false;
      _isReady = false;
    });
    widget.onFailedChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final picture = storyPicture(widget.story);
    if (picture == null) {
      return AppEmpty.failed(tone: AppEmptyTone.onDark, onRetry: () {});
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AppImage.network(
          picture.url,
          cacheKey: picture.cacheKey,
          key: ValueKey(_attempt),
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) {
            if (frame != null) _markReady();
            return frame == null && !sync
                ? AppBlurhash(
                    hash: widget.story.blurhash,
                    color: context.appColors.black,
                  )
                : child;
          },
          onError: (error, stack) {
            if (_hasFailed) return;
            ErrorReporter.report(error, stack ?? StackTrace.current);
          },
          errorBuilder: (context) {
            _markFailed();
            return const SizedBox.shrink();
          },
        ),
        if (_hasFailed)
          AppEmpty.failed(tone: AppEmptyTone.onDark, onRetry: _retry)
        else
          StoryBufferingLoader(isWaiting: !_isReady),
      ],
    );
  }
}
