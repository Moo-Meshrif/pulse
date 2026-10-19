import 'package:flutter/material.dart';

import '../../../../../core/utils/app_video_controller.dart';
import '../../../data/enums/story_media_type.dart';
import '../../../data/model/story_model.dart';
import 'story_image_media.dart';
import 'story_video_media.dart';

/// One story's picture or video, full bleed. It drives [progress] (0..1) while it [running] and calls
/// [onCompleted] when the story has played to its end: a photo after 5 seconds, a video at its last frame.
class StoryMedia extends StatelessWidget {
  const StoryMedia({
    super.key,
    required this.story,
    required this.isRunning,
    required this.progress,
    required this.restarts,
    required this.onCompleted,
    this.video,
    this.hasVideoFailed = false,
    this.onRetryVideo,
    this.onImageFailedChanged,
  });

  final StoryModel story;
  final bool isRunning;
  final ValueNotifier<double> progress;

  /// Changes when the story must start over.
  final int restarts;
  final VoidCallback onCompleted;

  final AppVideoController? video;
  final bool hasVideoFailed;
  final VoidCallback? onRetryVideo;
  final ValueChanged<bool>? onImageFailedChanged;

  @override
  Widget build(BuildContext context) => story.type == StoryMediaType.video
      ? StoryVideoMedia(
          story: story,
          controller: video,
          hasFailed: hasVideoFailed,
          isRunning: isRunning,
          progress: progress,
          restarts: restarts,
          onCompleted: onCompleted,
          onRetry: onRetryVideo,
        )
      : StoryImageMedia(
          story: story,
          isRunning: isRunning,
          progress: progress,
          restarts: restarts,
          onCompleted: onCompleted,
          onFailedChanged: onImageFailedChanged,
        );
}
