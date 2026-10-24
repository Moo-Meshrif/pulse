import '../../../../core/utils/equatable.dart';

/// One photo or video of a post, as the card draws it: links already signed, sizes known.
class PostCardMedia extends Equatable {
  final bool isVideo;

  /// The picture, or the video file. Null for a post shown from the saved copy on the phone, which has no
  /// signed link yet: a picture is read from the device cache by [cacheKey] (else its blurhash shows) and
  /// a video shows its cover and does not play.
  final String? url;

  /// A video's poster image.
  final String? posterUrl;

  /// What keeps the poster cached (its storage path).
  final String? posterCacheKey;

  /// What keeps the picture cached when its signed link changes (its storage path).
  final String? cacheKey;
  final int width;
  final int height;
  final int? durationMs;
  final String? blurhash;

  const PostCardMedia({
    required this.isVideo,
    this.url,
    this.posterUrl,
    this.posterCacheKey,
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
    posterCacheKey,
    cacheKey,
    width,
    height,
    durationMs,
    blurhash,
  ];
}
