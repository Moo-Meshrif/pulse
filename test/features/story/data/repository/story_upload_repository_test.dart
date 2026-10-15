import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/datasource/story_media_uploader.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/domain/entity/story_upload_status.dart';

class _MockStories extends Mock implements StoriesDatasource {}

class _MockUploader extends Mock implements StoryMediaUploader {}

void main() {
  late Directory dir;
  late File media;
  late File thumb;
  late _MockStories stories;
  late _MockUploader uploader;
  late StoryUploadRepositoryImpl repository;
  late EventBus bus;
  late List<StoryUploadStatus> seen;

  NewStoryModel video() => NewStoryModel(
    filePath: media.path,
    thumbFilePath: thumb.path,
    type: StoryMediaType.video,
    width: 1080,
    height: 1920,
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
    repository = StoryUploadRepositoryImpl(stories, uploader, bus);
    seen = [];
    bus.on<StoryUploadStatus>().listen(seen.add);
    await pumpEventQueue();
  });

  tearDown(() => dir.delete(recursive: true));

  test('says nothing before a story is queued', () {
    expect(seen, isEmpty);
    expect(bus.latest<StoryUploadStatus>(), isNull);
  });

  test('a late listener reads the newest status', () async {
    repository.enqueue(video());
    await pumpEventQueue();
    expect(bus.latest<StoryUploadStatus>(), const StoryUploadIdle());
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

      final progress = seen.whereType<StoryUploading>().map((s) => s.progress);
      expect(progress.first, 0);
      // 400 bytes in all: media 150, 300, then poster 300 + 50, 300 + 100.
      expect(
        progress,
        containsAllInOrder([0, 150 / 400, 300 / 400, 350 / 400, 1.0]),
      );
      expect(seen.sublist(seen.length - 2), [
        const StoryUploadDone(),
        const StoryUploadIdle(),
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

        expect(seen.last, const StoryUploadFailed(NetworkFailure()));
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
      repository.retry();
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
      expect(seen.whereType<StoryUploadDone>(), hasLength(1));
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
        const StoryUploadFailed(ServerFailure(statusCode: 500)),
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
      expect(seen.last, isA<StoryUploadFailed>());
    });

    test('retry does nothing when nothing failed', () async {
      repository.retry();
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
