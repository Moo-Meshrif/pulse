import '../../../../core/services/video_compress_service.dart';
import '../../../../core/utils/equatable.dart';
import '../enums/story_media_type.dart';
import 'story_overlay_model.dart';
import 'story_post_sticker_model.dart';

/// A story ready to post: the local media file (and a poster frame for a video) with its measurements.
class NewStoryModel extends Equatable {
  /// A photo or a video file on this device.
  final String filePath;
  final StoryMediaType type;

  /// A JPEG poster frame; required by the viewer for a video.
  final String? thumbFilePath;
  final int width;
  final int height;

  /// Videos only; the length of the part that goes out when the video is trimmed.
  final int? durationMs;

  /// Videos only: sound removed or a part kept. Such a video is re-encoded before it is sent.
  final VideoEdit? edit;

  /// Of the photo, or of a video's poster frame; the viewer shows it while the picture loads.
  final String? blurhash;
  final List<StoryOverlayModel> overlays;

  /// A story that shows a post: the post and where its sticker sits. Both or neither.
  final String? sharedPostId;
  final StoryPostStickerModel? sticker;

  NewStoryModel({
    required this.filePath,
    required this.type,
    required this.width,
    required this.height,
    this.thumbFilePath,
    this.durationMs,
    this.edit,
    this.blurhash,
    this.overlays = const [],
    this.sharedPostId,
    this.sticker,
  }) : assert(
         overlays.length <= StoryOverlayModel.maxPerStory,
         'A story holds at most ${StoryOverlayModel.maxPerStory} stickers',
       ),
       assert(
         (sharedPostId == null) == (sticker == null),
         'A post sticker needs its post, and a post its sticker',
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
    edit,
    blurhash,
    overlays,
    sharedPostId,
    sticker,
  ];
}
