import '../../../../core/utils/equatable.dart';
import '../../data/enums/story_media_type.dart';

/// A photo or video on its way from the camera (or the library) to the edit screen and the upload: a
/// local file, not yet a story.
class CapturedStoryMedia extends Equatable {
  const CapturedStoryMedia({
    required this.path,
    required this.type,
    this.width,
    this.height,
    this.durationMs,
  });

  final String path;
  final StoryMediaType type;
  final int? width;
  final int? height;

  /// Set for a video.
  final int? durationMs;

  @override
  List<Object?> get props => [path, type, width, height, durationMs];
}
