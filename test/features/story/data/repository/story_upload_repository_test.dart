import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/video_compress_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';

import '../../../../helpers/content_mocks.dart';

class _MockStories extends Mock implements StoriesDatasource {}

class _MockUploader extends Mock implements MediaFilesDatasource {}

class _MockThumbnails extends Mock implements VideoThumbnailService {}

class _MockCompressor extends Mock implements VideoCompressService {}

void main() {
  late Directory dir;
  late File media;
  late File thumb;
  late _MockStories stories;
  late _MockUploader uploader;
  late StoryUploadRepositoryImpl repository;
  late EventBus bus;
  late ContentPublishRepositoryImpl publish;
  late List<ContentPublishStatus> seen;

  NewStoryModel video() => NewStoryModel(
    filePath: media.path,
    thumbFilePath: thumb.path,
    type: StoryMediaType.video,
    // 720p, as the story camera records: it goes out without encoding.
    width: 720,
    height: 1280,
    durationMs: 9000,
  );

  setUpAll(() {
    registerFallbackValue(File('x'));
    registerFallbackValue(video0());
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('story_repo_test');
    media = File('${dir.path}/m.mp4')..writeAsBytesSync(List.filled(300, 1));
    thumb = File('${dir.path}/t.jpg')..writeAsBytesSync(List.filled(100, 1));
    stories = _MockStories();
    uploader = _MockUploader();
    when(() => stories.currentUserId).thenReturn('u1');
    when(
      () => stories.insertStory(
        any(),
        mediaPath: any(named: 'mediaPath'),
        thumbPath: any(named: 'thumbPath'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => uploader.upload(
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
    bus = EventBus();
    publish = ContentPublishRepositoryImpl(
      bus,
      FakeContentDiscards(),
      FakeConnectivity(),
    );
    repository = StoryUploadRepositoryImpl(
      stories,
      ContentMediaRepository(uploader, _MockThumbnails(), _MockCompressor()),
      publish,
    );
    seen = [];
    bus.on<ContentPublishStatus>().listen(seen.add);
    await pumpEventQueue();
  });

  tearDown(() => dir.delete(recursive: true));

  test('says nothing before a story is queued', () {
    expect(seen, isEmpty);
    expect(
      publish.current(ContentKind.story),
      const ContentPublishIdle(ContentKind.story),
    );
  });

  test('a late listener reads the newest status', () async {
    repository.enqueue(video());
    await pumpEventQueue();
    expect(
      publish.current(ContentKind.story),
      const ContentPublishIdle(ContentKind.story),
    );
  });

  test('uploads the media, then the poster, then inserts the row', () async {
    expect(repository.enqueue(video()), isTrue);
    await pumpEventQueue();

    final calls = verify(
      () => uploader.upload(
        path: captureAny(named: 'path'),
        file: any(named: 'file'),
        contentType: captureAny(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
      ),
    ).captured;
    final mediaPath = calls[0] as String;
    final thumbPath = calls[2] as String;
    expect(mediaPath, matches(RegExp(r'^u1/stories/[0-9a-f-]{36}\.mp4$')));
    expect(thumbPath, '${mediaPath.replaceFirst('.mp4', '')}_thumb.jpg');
    expect(calls[1], 'video/mp4');
    expect(calls[3], 'image/jpeg');
    verify(
      () => stories.insertStory(
        any(),
        mediaPath: mediaPath,
        thumbPath: thumbPath,
      ),
    ).called(1);
  });

  test(
    'progress follows the bytes of both files and ends in done, idle',
    () async {
      repository.enqueue(video());
      await pumpEventQueue();

      final progress = seen.whereType<ContentPublishing>().map(
        (s) => s.progress,
      );
      expect(progress.first, 0);
      // 400 bytes in all: media 150, 300, then poster 300 + 50, 300 + 100.
      expect(
        progress,
        containsAllInOrder([0, 150 / 400, 300 / 400, 350 / 400, 1.0]),
      );
      expect(seen.sublist(seen.length - 2), [
        const ContentPublishDone(ContentKind.story),
        const ContentPublishIdle(ContentKind.story),
      ]);
    },
  );

  test('a photo has no poster upload', () async {
    repository.enqueue(
      NewStoryModel(
        filePath: media.path,
        type: StoryMediaType.image,
        width: 1080,
        height: 1920,
      ),
    );
    await pumpEventQueue();
    verify(
      () => uploader.upload(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: 'image/jpeg',
        onBytes: any(named: 'onBytes'),
      ),
    ).called(1);
    verify(
      () => stories.insertStory(
        any(),
        mediaPath: any(named: 'mediaPath'),
        thumbPath: null,
      ),
    ).called(1);
  });

  test('a second story is refused while one is uploading', () async {
    final gate = Completer<void>();
    when(
      () => uploader.upload(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
      ),
    ).thenAnswer((_) => gate.future);

    expect(repository.enqueue(video()), isTrue);
    expect(repository.enqueue(video()), isFalse);
    gate.complete();
    await pumpEventQueue();
    expect(repository.enqueue(video()), isTrue);
  });

  group('failure and retry', () {
    void failFirstUpload() {
      var failed = false;
      when(
        () => uploader.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      ).thenAnswer((invocation) async {
        if (!failed) {
          failed = true;
          throw const NetworkFailure();
        }
      });
    }

    test(
      'a Failure becomes the failed status and nothing is inserted',
      () async {
        failFirstUpload();
        repository.enqueue(video());
        await pumpEventQueue();

        expect(
          seen.last,
          const ContentPublishFailed(
            ContentKind.story,
            failure: NetworkFailure(),
          ),
        );
        verifyNever(
          () => stories.insertStory(
            any(),
            mediaPath: any(named: 'mediaPath'),
            thumbPath: any(named: 'thumbPath'),
          ),
        );
      },
    );

    test('retry posts again under the same object names', () async {
      failFirstUpload();
      repository.enqueue(video());
      await pumpEventQueue();
      publish.retry(ContentKind.story);
      await pumpEventQueue();

      final paths = verify(
        () => uploader.upload(
          path: captureAny(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      ).captured.cast<String>();
      // First try (media, failed), then media and poster again.
      expect(paths, hasLength(3));
      expect(paths[1], paths[0]);
      expect(seen.whereType<ContentPublishDone>(), hasLength(1));
    });

    test('a failing insert is a failed status too', () async {
      when(
        () => stories.insertStory(
          any(),
          mediaPath: any(named: 'mediaPath'),
          thumbPath: any(named: 'thumbPath'),
        ),
      ).thenThrow(const ServerFailure(statusCode: 500));
      repository.enqueue(video());
      await pumpEventQueue();
      expect(
        seen.last,
        const ContentPublishFailed(
          ContentKind.story,
          failure: ServerFailure(statusCode: 500),
        ),
      );
    });

    test('an unknown error is mapped to a Failure', () async {
      when(
        () => uploader.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      ).thenThrow(const FormatException('bad'));
      repository.enqueue(video());
      await pumpEventQueue();
      expect(seen.last, isA<ContentPublishFailed>());
    });

    test('a new story replaces one that failed', () async {
      failFirstUpload();
      repository.enqueue(video());
      await pumpEventQueue();
      expect(seen.last, isA<ContentPublishFailed>());

      expect(repository.enqueue(video()), isTrue);
      await pumpEventQueue();
      expect(seen.last, const ContentPublishIdle(ContentKind.story));
      verify(
        () => stories.insertStory(
          any(),
          mediaPath: any(named: 'mediaPath'),
          thumbPath: any(named: 'thumbPath'),
        ),
      ).called(1);
    });

    test('retry does nothing when nothing failed', () async {
      publish.retry(ContentKind.story);
      await pumpEventQueue();
      expect(seen, isEmpty);
      verifyNever(
        () => uploader.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      );
    });
  });
}

NewStoryModel video0() => NewStoryModel(
  filePath: 'x',
  type: StoryMediaType.image,
  width: 1,
  height: 1,
);
