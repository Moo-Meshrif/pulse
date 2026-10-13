import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/widgets/widgets.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../domain/entity/captured_story_media.dart';

/// The captured photo or video, full bleed and cover-fit. A video loops; [isMuted] silences it.
class StoryEditMedia extends StatelessWidget {
  const StoryEditMedia({super.key, required this.media, required this.isMuted});

  final CapturedStoryMedia media;
  final bool isMuted;

  @override
  Widget build(BuildContext context) => media.type == StoryMediaType.video
      ? _Video(path: media.path, isMuted: isMuted)
      : AppImage.file(media.path);
}

class _Video extends StatefulWidget {
  const _Video({required this.path, required this.isMuted});

  final String path;
  final bool isMuted;

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
            ..play();
          setState(() {});
        });

  @override
  void didUpdateWidget(_Video old) {
    super.didUpdateWidget(old);
    if (old.isMuted != widget.isMuted && _controller.value.isInitialized) {
      _controller.setVolume(widget.isMuted ? 0 : 1);
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
