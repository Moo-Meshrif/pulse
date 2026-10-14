import '../../../../core/utils/equatable.dart';

/// One photo or video of a post, as the card draws it: links already signed, sizes known.
class PostCardMedia extends Equatable {
  final bool isVideo;

  /// The picture, or the video file.
  final String url;

  /// A video's poster image.
  final String? posterUrl;

  /// What keeps the picture cached when its signed link changes (its storage path).
  final String? cacheKey;
  final int width;
  final int height;
  final int? durationMs;
  final String? blurhash;

  const PostCardMedia({
    required this.isVideo,
    required this.url,
    this.posterUrl,
    this.cacheKey,
    required this.width,
    required this.height,
    this.durationMs,
    this.blurhash,
  });

  Duration? get duration {
    final ms = durationMs;
    return ms == null ? null : Duration(milliseconds: ms);
  }

  @override
  List<Object?> get props => [
    isVideo,
    url,
    posterUrl,
    cacheKey,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
