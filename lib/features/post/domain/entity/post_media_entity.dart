import '../../../../core/utils/equatable.dart';

/// One photo or video of a post. Public: Home draws the card from it.
class PostMediaEntity extends Equatable {
  final bool isVideo;

  /// Object path in the private media bucket; `SignPostMediaUrlsUseCase` turns it into a link.
  final String path;

  /// Poster frame of a video.
  final String? thumbPath;
  final int width;
  final int height;
  final int? durationMs;
  final String? blurhash;

  const PostMediaEntity({
    required this.isVideo,
    required this.path,
    this.thumbPath,
    required this.width,
    required this.height,
    this.durationMs,
    this.blurhash,
  });

  @override
  List<Object?> get props => [
    isVideo,
    path,
    thumbPath,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
