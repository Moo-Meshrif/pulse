import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../domain/entity/captured_story_media.dart';

/// The part of a video that is shared, in milliseconds.
typedef StoryTrim = ({int start, int end});

/// The captured photo or video, full bleed and cover-fit. A video loops (only its [trim] part when it is
/// trimmed); [isMuted] silences it.
class StoryEditMedia extends StatelessWidget {
  const StoryEditMedia({
    super.key,
    required this.media,
    required this.isMuted,
    this.trim,
  });

  final CapturedStoryMedia media;
  final bool isMuted;
  final StoryTrim? trim;

  @override
  Widget build(BuildContext context) => media.type == StoryMediaType.video
      ? _Video(path: media.path, isMuted: isMuted, trim: trim)
      : AppImage.file(media.path);
}

class _Video extends StatefulWidget {
  const _Video({required this.path, required this.isMuted, this.trim});

  final String path;
  final bool isMuted;
  final StoryTrim? trim;

  @override
  State<_Video> createState() => _VideoState();
}

class _VideoState extends State<_Video> {
  late final VideoPlayerController _controller =
      VideoPlayerController.file(File(widget.path))
        ..setLooping(true)
        ..initialize().then((_) {
          if (!mounted) return;
          _controller
            ..setVolume(widget.isMuted ? 0 : 1)
            ..addListener(_loopTrim)
            ..seekTo(Duration(milliseconds: widget.trim?.start ?? 0))
            ..play();
          setState(() {});
        });

  /// Goes back to the start of the shared part when it has played through.
  void _loopTrim() {
    final trim = widget.trim;
    if (trim == null) return;
    if (_controller.value.position.inMilliseconds >= trim.end) {
      _controller.seekTo(Duration(milliseconds: trim.start));
    }
  }

  @override
  void didUpdateWidget(_Video old) {
    super.didUpdateWidget(old);
    if (old.isMuted != widget.isMuted && _controller.value.isInitialized) {
      _controller.setVolume(widget.isMuted ? 0 : 1);
    }
    final trim = widget.trim;
    if (trim != null && trim != old.trim && _controller.value.isInitialized) {
      _controller.seekTo(Duration(milliseconds: trim.start));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const SizedBox.expand();
    final size = _controller.value.size;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
