import '../../data/enums/content_kind.dart';

/// What a video of one content kind may be before it goes out (docs/plans/media-upload-plan.md, D6).
class VideoLimits {
  const VideoLimits({
    required this.maxDuration,
    required this.maxLongSide,
    required this.maxBitrate,
  });

  final Duration maxDuration;

  /// The longest side in pixels after shrinking.
  final int maxLongSide;

  /// Video bits per second after shrinking.
  final int maxBitrate;
}

/// Why a file cannot go out.
enum MediaRejection { tooLong, tooBig }

/// What a file needs before it is uploaded.
sealed class MediaDecision {
  const MediaDecision();
}

/// The file fits: upload it as it is.
final class MediaAsIs extends MediaDecision {
  const MediaAsIs();
}

/// The video is larger, sharper or heavier than the kind allows: re-encode it to at most [longSide]
/// pixels and [videoBitrate] (plus [audioBitrate]) bits per second.
final class MediaShrink extends MediaDecision {
  const MediaShrink({
    required this.longSide,
    required this.videoBitrate,
    required this.audioBitrate,
  });

  final int longSide;
  final int videoBitrate;
  final int audioBitrate;
}

final class MediaRejected extends MediaDecision {
  const MediaRejected(this.reason);

  final MediaRejection reason;
}

/// The one place that decides what a photo or video needs before it goes out, for every content kind.
/// Missing details (no size or length known) count as fitting; the bucket limit still applies on the
/// server.
abstract final class MediaPolicy {
  /// The bucket's file size limit (the Supabase Free cap); raise it with the bucket.
  static const maxBytes = 50 * 1024 * 1024;

  /// A shrunk video aims below this share of [maxBytes], leaving room for the container.
  static const _budgetShare = 0.95;
  static const audioBitrate = 128000;

  /// Below this a shrunk video looks too poor; such a video is too long to fit.
  static const minVideoBitrate = 1200000;

  static VideoLimits videoLimits(ContentKind kind) => switch (kind) {
    ContentKind.post => const VideoLimits(
      maxDuration: Duration(minutes: 10),
      maxLongSide: 1920,
      maxBitrate: 6000000,
    ),
    ContentKind.short => const VideoLimits(
      maxDuration: Duration(seconds: 90),
      maxLongSide: 1920,
      maxBitrate: 6000000,
    ),
    // 720p, like the story camera, so its videos go out untouched.
    ContentKind.story => const VideoLimits(
      maxDuration: Duration(seconds: 60),
      maxLongSide: 1280,
      maxBitrate: 4000000,
    ),
  };

  static MediaDecision decide(
    ContentKind kind, {
    required bool isVideo,
    int? durationMs,
    int? width,
    int? height,
    int? sizeBytes,
    bool mustEncode = false,
  }) {
    final bytes = sizeBytes ?? 0;
    if (!isVideo) {
      return bytes > maxBytes
          ? const MediaRejected(MediaRejection.tooBig)
          : const MediaAsIs();
    }

    final limits = videoLimits(kind);
    final duration = Duration(milliseconds: durationMs ?? 0);
    if (duration > limits.maxDuration) {
      return const MediaRejected(MediaRejection.tooLong);
    }
    final seconds = duration.inMilliseconds / 1000;
    final longSide = (width ?? 0) > (height ?? 0) ? width ?? 0 : height ?? 0;
    final bitrate = seconds == 0 ? 0 : bytes * 8 / seconds;
    final fits = bytes <= maxBytes;
    if (!mustEncode &&
        fits &&
        longSide <= limits.maxLongSide &&
        bitrate <= limits.maxBitrate + audioBitrate) {
      return const MediaAsIs();
    }

    final budget = seconds == 0
        ? limits.maxBitrate
        : (maxBytes * _budgetShare * 8 / seconds - audioBitrate).floor();
    final target = budget < limits.maxBitrate ? budget : limits.maxBitrate;
    if (target < minVideoBitrate) {
      // Too long to shrink well; it still goes as it is when it fits, unless it has an edit to apply.
      if (!fits) return const MediaRejected(MediaRejection.tooLong);
      if (!mustEncode) return const MediaAsIs();
    }
    return MediaShrink(
      longSide: longSide == 0 || longSide > limits.maxLongSide
          ? limits.maxLongSide
          : longSide,
      videoBitrate: target < minVideoBitrate ? minVideoBitrate : target,
      audioBitrate: audioBitrate,
    );
  }
}
