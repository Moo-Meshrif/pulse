import '../../../../core/utils/equatable.dart';
import '../enums/story_media_type.dart';
import 'story_overlay_model.dart';

/// A story ready to post: the local media file (and a poster frame for a video) with its measurements.
class NewStoryModel extends Equatable {
  /// A photo or a video file on this device.
  final String filePath;
  final StoryMediaType type;

  /// A JPEG poster frame; required by the viewer for a video.
  final String? thumbFilePath;
  final int width;
  final int height;

  /// Videos only.
  final int? durationMs;
  final List<StoryOverlayModel> overlays;

  NewStoryModel({
    required this.filePath,
    required this.type,
    required this.width,
    required this.height,
    this.thumbFilePath,
    this.durationMs,
    this.overlays = const [],
  }) : assert(
         overlays.length <= StoryOverlayModel.maxPerStory,
         'A story holds at most ${StoryOverlayModel.maxPerStory} stickers',
       ),
       assert(
         (type == StoryMediaType.video) == (durationMs != null),
         'A video has a duration, a photo does not',
       );

  @override
  List<Object?> get props => [
    filePath,
    type,
    thumbFilePath,
    width,
    height,
    durationMs,
    overlays,
  ];
}
