import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/loading_overlay/pulse_line_loader.dart';

/// The heartbeat line, centered, once [waiting] has lasted [StoryTiming.bufferLoaderDelay]: a short wait
/// shows nothing.
class StoryBufferingLoader extends StatefulWidget {
  const StoryBufferingLoader({super.key, required this.isWaiting});

  final bool isWaiting;

  @override
  State<StoryBufferingLoader> createState() => _StoryBufferingLoaderState();
}

class _StoryBufferingLoaderState extends State<StoryBufferingLoader> {
  Timer? _timer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(StoryBufferingLoader old) {
    super.didUpdateWidget(old);
    if (old.isWaiting != widget.isWaiting) _sync();
  }

  void _sync() {
    _timer?.cancel();
    if (!widget.isWaiting) {
      _isVisible = false;
      return;
    }
    _timer = Timer(StoryTiming.bufferLoaderDelay, () {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isVisible
      ? Center(
          child: PulseLineLoader(
            color: context.appColors.storyOnDark,
            width: StoryDimens.loaderWidth,
          ),
        )
      : const SizedBox.shrink();
}
