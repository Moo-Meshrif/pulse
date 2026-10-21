import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/cancel_signal.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/media_upload_status.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';
import 'package:pulse/shared/content/data/repository/media_upload_queue.dart';

class _Media extends Mock implements ContentMediaRepository {}

const _folder = 'u1/p1';

MediaToSend _photo(String name) =>
    MediaToSend(filePath: '/drafts/$name.jpg', isVideo: false);

void main() {
  late _Media media;
  late MediaUploadQueue queue;

  /// The sends in progress, by stem; complete one to finish it.
  late Map<String, Completer<SentMedia>> sends;

  /// The cancel signal each send was given, by stem.
  late Map<String, CancelSignal?> cancels;

  /// What a fresh listing of the folder returns.
  late Set<String> onServer;

  late List<(String, MediaUploadStatus)> changes;

  setUpAll(() {
    registerFallbackValue(ContentKind.post);
    registerFallbackValue(_photo('x'));
  });

  setUp(() {
    media = _Media();
    sends = {};
    cancels = {};
    onServer = {};
    changes = [];
    when(() => media.folderOf(any())).thenReturn(_folder);
    when(() => media.existing(any())).thenAnswer((_) async => {...onServer});
    when(() => media.removeQuietly(any())).thenAnswer((_) async {});
    when(
      () => media.send(
        any(),
        any(),
        folder: any(named: 'folder'),
        stem: any(named: 'stem'),
        existing: any(named: 'existing'),
        onProgress: any(named: 'onProgress'),
        cancel: any(named: 'cancel'),
      ),
    ).thenAnswer((invocation) {
      final stem = invocation.namedArguments[#stem] as String;
      cancels[stem] = invocation.namedArguments[#cancel] as CancelSignal?;
      return (sends[stem] = Completer<SentMedia>()).future;
    });
    queue = MediaUploadQueue(media);
    queue.changes.listen(changes.add);
  });

  void add(String stem) => queue.add(
    stem,
    _photo(stem),
    kind: ContentKind.post,
    contentId: 'p1',
    stem: stem,
  );

  void finish(String stem) =>
      sends[stem]!.complete(SentMedia(path: '$_folder/$stem.jpg'));

  int sentCount(String stem) => verify(
    () => media.send(
      any(),
      any(),
      folder: any(named: 'folder'),
      stem: stem,
      existing: any(named: 'existing'),
      onProgress: any(named: 'onProgress'),
      cancel: any(named: 'cancel'),
    ),
  ).callCount;

  test('at most two upload at a time, in the order they were added', () async {
    add('a');
    add('b');
    add('c');
    await pumpEventQueue();
    expect(sends.keys, ['a', 'b']);

    finish('a');
    await pumpEventQueue();
    expect(sends.keys, ['a', 'b', 'c']);
    expect(changes, contains(('a', MediaUploadStatus.uploaded)));
  });

  test(
    'a file goes to the content folder under its stem, with what is there',
    () async {
      onServer = {'old.jpg'};
      add('a');
      await pumpEventQueue();
      final captured = verify(
        () => media.send(
          ContentKind.post,
          _photo('a'),
          folder: _folder,
          stem: 'a',
          existing: captureAny(named: 'existing'),
          onProgress: any(named: 'onProgress'),
          cancel: any(named: 'cancel'),
        ),
      ).captured;
      expect(captured.single, {'old.jpg'});
    },
  );

  test(
    'removing a waiting file: it is never sent and nothing is deleted',
    () async {
      add('a');
      add('b');
      add('c');
      await queue.remove('c');
      finish('a');
      finish('b');
      await pumpEventQueue();
      expect(sends.keys, isNot(contains('c')));
      verifyNever(() => media.removeQuietly(any()));
    },
  );

  test(
    'removing a running file stops it and deletes what reached the server',
    () async {
      add('a');
      await pumpEventQueue();
      final removed = queue.remove('a');
      expect(cancels['a']!.isCancelled, isTrue);

      // The upload of the file had finished, then its frame was stopped.
      onServer = {'a.jpg', 'a_thumb.jpg', 'other.jpg'};
      sends['a']!.completeError(const UnexpectedFailure());
      await removed;
      verify(
        () => media.removeQuietly(['$_folder/a.jpg', '$_folder/a_thumb.jpg']),
      ).called(1);
    },
  );

  test(
    'a late answer for a removed file is ignored and its file deleted',
    () async {
      add('a');
      add('b');
      add('c');
      await pumpEventQueue();
      final removed = queue.remove('a');
      onServer = {'a.jpg'};
      finish('a');
      await removed;

      expect(changes, isNot(contains(('a', MediaUploadStatus.uploaded))));
      verify(() => media.removeQuietly(['$_folder/a.jpg'])).called(1);
      expect(sends.keys, contains('c'), reason: 'its slot went to the next');
    },
  );

  test('a failed upload is reported; retry sends it again', () async {
    add('a');
    await pumpEventQueue();
    sends['a']!.completeError(const NetworkFailure());
    await pumpEventQueue();
    expect(changes.last, ('a', MediaUploadStatus.failed));

    queue.retry('a');
    await pumpEventQueue();
    expect(changes.last, ('a', MediaUploadStatus.uploading));
    finish('a');
    await pumpEventQueue();
    expect(changes.last, ('a', MediaUploadStatus.uploaded));
    expect(sentCount('a'), 2);
  });

  test('adding the same file twice uploads it once', () async {
    add('a');
    add('a');
    await pumpEventQueue();
    expect(sentCount('a'), 1);
  });

  test(
    'settled waits for the waiting and running files, not the failed',
    () async {
      add('a');
      add('b');
      add('c');
      await pumpEventQueue();
      var isSettled = false;
      unawaited(queue.settled().then((_) => isSettled = true));

      sends['a']!.completeError(const NetworkFailure());
      finish('b');
      await pumpEventQueue();
      expect(isSettled, isFalse, reason: 'c is still going');
      finish('c');
      await pumpEventQueue();
      expect(isSettled, isTrue);
    },
  );

  test('stop cancels everything and deletes nothing', () async {
    add('a');
    await pumpEventQueue();
    queue.stop();
    expect(cancels['a']!.isCancelled, isTrue);
    verifyNever(() => media.removeQuietly(any()));
  });
}
