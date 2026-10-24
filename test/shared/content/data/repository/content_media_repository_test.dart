import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/video_compress_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/core/utils/cancel_signal.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';

class _MockFiles extends Mock implements MediaFilesDatasource {}

class _MockThumbnails extends Mock implements VideoThumbnailService {}

class _MockCompressor extends Mock implements VideoCompressService {}

void main() {
  late Directory dir;
  late File video;
  late File frame;
  late _MockFiles files;
  late _MockThumbnails thumbnails;
  late _MockCompressor compressor;
  late ContentMediaRepository media;

  setUpAll(() => registerFallbackValue(File('x')));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('content_media_test');
    video = File('${dir.path}/clip.MOV')..writeAsBytesSync(List.filled(300, 1));
    frame = File('${dir.path}/frame.jpg')
      ..writeAsBytesSync(List.filled(100, 1));
    files = _MockFiles();
    thumbnails = _MockThumbnails();
    when(() => thumbnails.thumbnail(any())).thenAnswer((_) async => frame.path);
    when(
      () => files.upload(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
      ),
    ).thenAnswer((invocation) async {
      final onBytes =
          invocation.namedArguments[#onBytes] as void Function(int)?;
      final file = invocation.namedArguments[#file] as File;
      onBytes?.call(file.lengthSync() ~/ 2);
      onBytes?.call(file.lengthSync());
    });
    compressor = _MockCompressor();
    when(compressor.deleteAll).thenAnswer((_) async {});
    when(() => compressor.delete(any())).thenAnswer((_) async {});
    media = ContentMediaRepository(files, thumbnails, compressor);
  });

  tearDown(() => dir.delete(recursive: true));

  List<Object?> uploads() => verify(
    () => files.upload(
      path: captureAny(named: 'path'),
      file: any(named: 'file'),
      contentType: captureAny(named: 'contentType'),
      onBytes: any(named: 'onBytes'),
    ),
  ).captured;

  MediaToSend clip({String? thumb}) => MediaToSend(
    filePath: video.path,
    isVideo: true,
    thumbFilePath: thumb,
    durationMs: 5000,
  );

  test('a video goes with a frame made for it, under the stem', () async {
    final sent = await media.send(
      ContentKind.post,
      clip(),
      folder: 'u1/p1',
      stem: '0',
    );

    expect(
      sent,
      const SentMedia(path: 'u1/p1/0.mov', thumbPath: 'u1/p1/0_thumb.jpg'),
    );
    expect(uploads(), [
      'u1/p1/0.mov',
      'video/quicktime',
      'u1/p1/0_thumb.jpg',
      'image/jpeg',
    ]);
  });

  test('a frame the caller made is used as it is', () async {
    await media.send(
      ContentKind.story,
      clip(thumb: frame.path),
      folder: 'u1/stories',
      stem: 's',
    );
    verifyNever(() => thumbnails.thumbnail(any()));
  });

  test('a photo has no frame; an odd name goes as JPEG', () async {
    File('${dir.path}/photo.heic').writeAsBytesSync([1, 2, 3]);
    final sent = await media.send(
      ContentKind.post,
      MediaToSend(filePath: '${dir.path}/photo.heic', isVideo: false),
      folder: 'u1/p1',
      stem: '1',
    );
    expect(sent, const SentMedia(path: 'u1/p1/1.jpg'));
    expect(uploads(), ['u1/p1/1.jpg', 'image/jpeg']);
  });

  test('files already in the folder are not sent again', () async {
    await media.send(
      ContentKind.post,
      clip(),
      folder: 'u1/p1',
      stem: '0',
      existing: {'0.mov'},
    );
    expect(uploads(), ['u1/p1/0_thumb.jpg', 'image/jpeg']);
  });

  test('progress follows the bytes of both files and ends at 1', () async {
    final progress = <double>[];
    await media.send(
      ContentKind.post,
      clip(),
      folder: 'u1/p1',
      stem: '0',
      onProgress: progress.add,
    );
    // 400 bytes in all: video 150, 300, then frame 300 + 50, 300 + 100; the bytes fill 95 %.
    expect(progress, [
      closeTo(0.95 * 150 / 400, 1e-9),
      closeTo(0.95 * 300 / 400, 1e-9),
      closeTo(0.95 * 350 / 400, 1e-9),
      0.95,
      1.0,
    ]);
  });

  test('a video the policy refuses fails before anything is sent', () async {
    await expectLater(
      media.send(
        ContentKind.story,
        const MediaToSend(filePath: '/v.mp4', isVideo: true, durationMs: 61000),
        folder: 'u1/stories',
        stem: 's',
      ),
      throwsA(const ServerFailure(statusCode: 413)),
    );
    verifyNever(
      () => files.upload(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
      ),
    );
  });

  test('existing lists the folder, removeQuietly removes', () async {
    when(() => files.listFiles('u1/p1')).thenAnswer((_) async => ['0.jpg']);
    when(() => files.remove(any())).thenAnswer((_) async {});

    expect(await media.existing('u1/p1'), {'0.jpg'});
    await media.removeQuietly(['u1/p1/0.jpg']);
    verify(() => files.remove(['u1/p1/0.jpg'])).called(1);
  });

  group('target', () {
    test(
      'a file is named, typed and sized as send uploads it, its frame too',
      () async {
        final target = await media.target(
          ContentKind.post,
          clip(thumb: frame.path),
          folder: 'u1/p1',
          stem: 'm1',
        );
        expect(
          target,
          const MediaTarget(
            path: 'u1/p1/m1.mov',
            mimeType: 'video/quicktime',
            sizeBytes: 300,
            thumbPath: 'u1/p1/m1_thumb.jpg',
            thumbSizeBytes: 100,
          ),
        );
        verifyZeroInteractions(files);
      },
    );

    test('a video to shrink goes as MP4 of a size not known yet', () async {
      final target = await media.target(
        ContentKind.post,
        MediaToSend(
          filePath: video.path,
          isVideo: true,
          width: 2160,
          height: 3840,
          durationMs: 60000,
          sizeBytes: 300 * 1024 * 1024,
        ),
        folder: 'u1/p1',
        stem: 'm1',
      );
      expect(target.path, 'u1/p1/m1.mp4');
      expect(target.mimeType, 'video/mp4');
      expect(target.sizeBytes, isNull);
      expect(target.thumbSizeBytes, isNull); // its frame is made at upload
    });
  });

  group('shrinking', () {
    late File copy;

    /// A 60 s 4K clip of 300 MB, as the gallery hands it over.
    MediaToSend big() => MediaToSend(
      filePath: video.path,
      isVideo: true,
      width: 2160,
      height: 3840,
      durationMs: 60000,
      sizeBytes: 300 * 1024 * 1024,
    );

    void encodes({
      int durationMs = 60000,
      int sizeBytes = 200,
      bool isOriginal = false,
    }) =>
        when(
          () => compressor.compress(
            any(),
            maxLongSide: any(named: 'maxLongSide'),
            videoBitrate: any(named: 'videoBitrate'),
            audioBitrate: any(named: 'audioBitrate'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((invocation) async {
          final onProgress =
              invocation.namedArguments[#onProgress] as void Function(double)?;
          onProgress?.call(0.5);
          onProgress?.call(1);
          return CompressedVideo(
            path: isOriginal ? video.path : copy.path,
            sizeBytes: sizeBytes,
            durationMs: durationMs,
            isOriginal: isOriginal,
          );
        });

    int encodeCount() => verify(
      () => compressor.compress(
        any(),
        maxLongSide: any(named: 'maxLongSide'),
        videoBitrate: any(named: 'videoBitrate'),
        audioBitrate: any(named: 'audioBitrate'),
        onProgress: any(named: 'onProgress'),
      ),
    ).callCount;

    setUp(() {
      copy = File('${dir.path}/copy.mp4')
        ..writeAsBytesSync(List.filled(200, 2));
    });

    test('a video within the policy is not encoded', () async {
      await media.send(ContentKind.post, clip(), folder: 'u1/p1', stem: '0');
      verifyNever(
        () => compressor.compress(
          any(),
          maxLongSide: any(named: 'maxLongSide'),
          videoBitrate: any(named: 'videoBitrate'),
          audioBitrate: any(named: 'audioBitrate'),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });

    test(
      'a big video is shrunk to the policy, sent as MP4, then deleted',
      () async {
        encodes();
        final sent = await media.send(
          ContentKind.short,
          big(),
          folder: 'u1/s1',
          stem: '0',
        );

        verify(
          () => compressor.compress(
            video.path,
            maxLongSide: 1920,
            videoBitrate: 6000000,
            audioBitrate: 128000,
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
        final file =
            verify(
                  () => files.upload(
                    path: 'u1/s1/0.mp4',
                    file: captureAny(named: 'file'),
                    contentType: 'video/mp4',
                    onBytes: any(named: 'onBytes'),
                  ),
                ).captured.single
                as File;
        expect(file.path, copy.path);
        expect(sent.path, 'u1/s1/0.mp4');
        verify(() => compressor.delete(copy.path)).called(1);
      },
    );

    test(
      'copies left by an earlier run are deleted once, before the first encode',
      () async {
        encodes();
        await media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '0');
        await media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '1');
        verify(compressor.deleteAll).called(1);
      },
    );

    test('progress gives the encode 30 % and the upload the rest', () async {
      encodes();
      final progress = <double>[];
      await media.send(
        ContentKind.post,
        big(),
        folder: 'u1/p1',
        stem: '0',
        onProgress: progress.add,
      );
      // Encode 0.5, 1; then 300 bytes (copy 200 + frame 100): 100, 200, 250, 300.
      // The bytes fill 95 % of the upload part.
      expect(progress, [
        0.15,
        0.3,
        closeTo(0.3 + 0.7 * 0.95 * 100 / 300, 1e-9),
        closeTo(0.3 + 0.7 * 0.95 * 200 / 300, 1e-9),
        closeTo(0.3 + 0.7 * 0.95 * 250 / 300, 1e-9),
        closeTo(0.3 + 0.7 * 0.95, 1e-9),
        1.0,
      ]);
    });

    test('a retry uploads the kept copy without encoding again', () async {
      encodes();
      var tries = 0;
      when(
        () => files.upload(
          path: 'u1/p1/0.mp4',
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      ).thenAnswer((_) async {
        if (++tries == 1) throw const NetworkFailure();
      });

      await expectLater(
        media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '0'),
        throwsA(isA<NetworkFailure>()),
      );
      verifyNever(() => compressor.delete(any()));

      await media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '0');
      expect(encodeCount(), 1);
      verify(() => compressor.delete(copy.path)).called(1);
    });

    test(
      'files sent are added to the caller\'s set and skipped on a retry',
      () async {
        var thumbTries = 0;
        when(
          () => files.upload(
            path: 'u1/stories/s_thumb.jpg',
            file: any(named: 'file'),
            contentType: any(named: 'contentType'),
            onBytes: any(named: 'onBytes'),
          ),
        ).thenAnswer((_) async {
          if (++thumbTries == 1) throw const NetworkFailure();
        });
        final sent = <String>{};

        await expectLater(
          media.send(
            ContentKind.story,
            clip(thumb: frame.path),
            folder: 'u1/stories',
            stem: 's',
            existing: sent,
          ),
          throwsA(isA<NetworkFailure>()),
        );
        expect(sent, {'s.mov'});
        await media.send(
          ContentKind.story,
          clip(thumb: frame.path),
          folder: 'u1/stories',
          stem: 's',
          existing: sent,
        );
        expect(sent, {'s.mov', 's_thumb.jpg'});
        verify(
          () => files.upload(
            path: 'u1/stories/s.mov',
            file: any(named: 'file'),
            contentType: any(named: 'contentType'),
            onBytes: any(named: 'onBytes'),
          ),
        ).called(1);
      },
    );

    test('an encode cut short fails and its copy is deleted', () async {
      encodes(durationMs: 30000);
      await expectLater(
        media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '0'),
        throwsA(isA<UnexpectedFailure>()),
      );
      verify(() => compressor.delete(copy.path)).called(1);
    });

    test('a copy still over the limit is refused and deleted', () async {
      encodes(sizeBytes: 60 * 1024 * 1024);
      await expectLater(
        media.send(ContentKind.post, big(), folder: 'u1/p1', stem: '0'),
        throwsA(const ServerFailure(statusCode: 413)),
      );
      verify(() => compressor.delete(copy.path)).called(1);
    });

    test('when shrinking would not help the source goes and is kept', () async {
      encodes(isOriginal: true);
      await media.send(
        ContentKind.post,
        MediaToSend(
          filePath: video.path,
          isVideo: true,
          width: 2160,
          height: 3840,
          durationMs: 60000,
          sizeBytes: 40 * 1024 * 1024,
        ),
        folder: 'u1/p1',
        stem: '0',
      );
      final file =
          verify(
                () => files.upload(
                  path: 'u1/p1/0.mp4',
                  file: captureAny(named: 'file'),
                  contentType: any(named: 'contentType'),
                  onBytes: any(named: 'onBytes'),
                ),
              ).captured.single
              as File;
      expect(file.path, video.path);
      verifyNever(() => compressor.delete(any()));
    });
  });

  group('cancel', () {
    test('a cancelled send uploads nothing and fails', () async {
      final cancel = CancelSignal()..cancel();
      await expectLater(
        media.send(
          ContentKind.post,
          clip(thumb: frame.path),
          folder: 'u1/p1',
          stem: '0',
          cancel: cancel,
        ),
        throwsA(isA<Failure>()),
      );
      verifyNever(
        () => files.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
          cancel: any(named: 'cancel'),
        ),
      );
    });

    test('cancelled after the video went out, its frame is not sent', () async {
      final cancel = CancelSignal();
      when(
        () => files.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((_) async => cancel.cancel());
      await expectLater(
        media.send(
          ContentKind.post,
          clip(thumb: frame.path),
          folder: 'u1/p1',
          stem: '0',
          cancel: cancel,
        ),
        throwsA(isA<Failure>()),
      );
      final paths = verify(
        () => files.upload(
          path: captureAny(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
          cancel: any(named: 'cancel', that: same(cancel)),
        ),
      ).captured;
      expect(paths, ['u1/p1/0.mov']);
    });
  });
}
