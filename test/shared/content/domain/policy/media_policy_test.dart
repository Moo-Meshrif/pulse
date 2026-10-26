import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/policy/media_policy.dart';

const _mb = 1024 * 1024;

MediaDecision video(
  ContentKind kind, {
  required int seconds,
  required int megabytes,
  int width = 1080,
  int height = 1920,
}) => MediaPolicy.decide(
  kind,
  isVideo: true,
  durationMs: seconds * 1000,
  width: width,
  height: height,
  sizeBytes: megabytes * _mb,
);

void main() {
  group('photos', () {
    test('a photo within the bucket limit goes as it is', () {
      expect(
        MediaPolicy.decide(
          ContentKind.post,
          isVideo: false,
          sizeBytes: 5 * _mb,
        ),
        isA<MediaAsIs>(),
      );
    });

    test('a photo over the bucket limit is too big', () {
      final decision = MediaPolicy.decide(
        ContentKind.story,
        isVideo: false,
        sizeBytes: MediaPolicy.maxBytes + 1,
      );
      expect(
        decision,
        isA<MediaRejected>().having(
          (d) => d.reason,
          'reason',
          MediaRejection.tooBig,
        ),
      );
    });
  });

  group('videos', () {
    test('a 1080p clip under the bitrate cap goes as it is', () {
      // 30 s, 15 MB = 4 Mbps.
      expect(
        video(ContentKind.post, seconds: 30, megabytes: 15),
        isA<MediaAsIs>(),
      );
    });

    test('a 720p camera story goes as it is', () {
      // 60 s, 25 MB = 3.5 Mbps at 1280x720.
      expect(
        video(
          ContentKind.story,
          seconds: 60,
          megabytes: 25,
          width: 720,
          height: 1280,
        ),
        isA<MediaAsIs>(),
      );
    });

    test('a 4K clip shrinks to the kind\'s side and bitrate cap', () {
      final decision = video(
        ContentKind.short,
        seconds: 60,
        megabytes: 300,
        width: 2160,
        height: 3840,
      );
      expect(
        decision,
        isA<MediaShrink>()
            .having((d) => d.longSide, 'longSide', 1920)
            .having((d) => d.videoBitrate, 'videoBitrate', 6000000)
            .having((d) => d.audioBitrate, 'audioBitrate', 128000),
      );
    });

    test('a story shrinks to 720p and 4 Mbps', () {
      final decision = video(
        ContentKind.story,
        seconds: 30,
        megabytes: 60,
        width: 1080,
        height: 1920,
      );
      expect(
        decision,
        isA<MediaShrink>()
            .having((d) => d.longSide, 'longSide', 1280)
            .having((d) => d.videoBitrate, 'videoBitrate', 4000000),
      );
    });

    test('a smaller side is kept when only the bitrate is too high', () {
      // 720p at 20 Mbps.
      final decision = video(
        ContentKind.post,
        seconds: 10,
        megabytes: 25,
        width: 720,
        height: 1280,
      );
      expect(
        decision,
        isA<MediaShrink>().having((d) => d.longSide, 'longSide', 1280),
      );
    });

    test('a long video aims under the byte budget', () {
      // 3 min: 50 MB * 0.95 * 8 / 180 s - 128 kbps ≈ 2.09 Mbps.
      final decision =
          video(ContentKind.post, seconds: 180, megabytes: 400) as MediaShrink;
      final bytes = (decision.videoBitrate + decision.audioBitrate) * 180 / 8;
      expect(bytes, lessThanOrEqualTo(MediaPolicy.maxBytes * 0.95));
      expect(decision.videoBitrate, greaterThan(MediaPolicy.minVideoBitrate));
    });

    test('too long to shrink well and too big is too long', () {
      // 6 min leaves under 1.2 Mbps.
      expect(
        video(ContentKind.post, seconds: 360, megabytes: 200),
        isA<MediaRejected>().having(
          (d) => d.reason,
          'reason',
          MediaRejection.tooLong,
        ),
      );
    });

    test('too long to shrink well but already fitting goes as it is', () {
      expect(
        video(
          ContentKind.post,
          seconds: 600,
          megabytes: 50,
          width: 3840,
          height: 2160,
        ),
        isA<MediaAsIs>(),
      );
    });

    test('each kind has its own longest length', () {
      MediaDecision justOver(ContentKind kind) {
        final max = MediaPolicy.videoLimits(kind).maxDuration;
        return MediaPolicy.decide(
          kind,
          isVideo: true,
          durationMs: max.inMilliseconds + 1,
          sizeBytes: _mb,
        );
      }

      // A comment has no video, so it has no longest length.
      final withMedia = ContentKind.values.where(
        (kind) => kind != ContentKind.comment,
      );
      for (final kind in withMedia) {
        expect(justOver(kind), isA<MediaRejected>(), reason: kind.name);
      }
      expect(
        MediaPolicy.videoLimits(ContentKind.post).maxDuration,
        const Duration(minutes: 10),
      );
      expect(
        MediaPolicy.videoLimits(ContentKind.short).maxDuration,
        const Duration(seconds: 90),
      );
      expect(
        MediaPolicy.videoLimits(ContentKind.story).maxDuration,
        const Duration(seconds: 60),
      );
    });

    test('unknown details count as fitting', () {
      expect(
        MediaPolicy.decide(ContentKind.post, isVideo: true),
        isA<MediaAsIs>(),
      );
    });
  });
}
