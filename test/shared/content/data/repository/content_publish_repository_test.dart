import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';

void main() {
  late EventBus bus;
  late ContentPublishRepositoryImpl publish;
  late List<ContentPublishStatus> seen;

  setUp(() async {
    bus = EventBus();
    publish = ContentPublishRepositoryImpl(bus);
    seen = [];
    bus.on<ContentPublishStatus>().listen(seen.add);
    await pumpEventQueue();
  });

  tearDown(() => bus.dispose());

  PublishWork ok() => (_) async {};

  PublishWork failing() =>
      (_) async => throw const NetworkFailure();

  test('every kind starts idle', () {
    for (final kind in ContentKind.values) {
      expect(publish.current(kind), ContentPublishIdle(kind));
    }
  });

  test('a job goes publishing, done, idle and keeps its details', () async {
    publish.enqueue(
      kind: ContentKind.post,
      send: ok(),
      isEdit: true,
      previewPath: '/a.jpg',
    );
    await pumpEventQueue();

    expect(seen, const [
      ContentPublishing(ContentKind.post, isEdit: true, previewPath: '/a.jpg'),
      ContentPublishDone(ContentKind.post, isEdit: true),
      ContentPublishIdle(ContentKind.post),
    ]);
  });

  test('progress is reported, clamped and never goes back', () async {
    publish.enqueue(
      kind: ContentKind.story,
      send: (report) async {
        report(0.5);
        report(0.2); // a retried file counts from zero again
        report(0.8);
        report(3);
      },
    );
    await pumpEventQueue();

    expect(seen.whereType<ContentPublishing>().map((s) => s.progress), [
      0,
      0.5,
      0.8,
      1,
    ]);
  });

  test('a busy kind refuses a second job; other kinds go at once', () async {
    final gate = Completer<void>();
    expect(
      publish.enqueue(kind: ContentKind.post, send: (_) => gate.future),
      isTrue,
    );
    expect(publish.enqueue(kind: ContentKind.post, send: ok()), isFalse);
    expect(publish.enqueue(kind: ContentKind.story, send: ok()), isTrue);
    expect(publish.enqueue(kind: ContentKind.short, send: ok()), isTrue);
    await pumpEventQueue();

    expect(publish.current(ContentKind.post), isA<ContentPublishing>());
    expect(
      publish.current(ContentKind.story),
      const ContentPublishIdle(ContentKind.story),
    );
    gate.complete();
    await pumpEventQueue();
    expect(publish.enqueue(kind: ContentKind.post, send: ok()), isTrue);
  });

  group('failure', () {
    test('a Failure becomes the failed status with the details', () async {
      publish.enqueue(
        kind: ContentKind.post,
        send: failing(),
        previewPath: '/a.jpg',
      );
      await pumpEventQueue();

      expect(
        publish.current(ContentKind.post),
        const ContentPublishFailed(
          ContentKind.post,
          failure: NetworkFailure(),
          previewPath: '/a.jpg',
        ),
      );
    });

    test('an unknown error is mapped to a Failure', () async {
      publish.enqueue(
        kind: ContentKind.post,
        send: (_) async => throw const FormatException('bad'),
      );
      await pumpEventQueue();
      expect(publish.current(ContentKind.post), isA<ContentPublishFailed>());
    });

    test('a failed job waits: a new one is refused', () async {
      publish.enqueue(kind: ContentKind.post, send: failing());
      await pumpEventQueue();
      expect(publish.enqueue(kind: ContentKind.post, send: ok()), isFalse);
    });

    test('replacesFailed drops the failed job for the new one', () async {
      publish.enqueue(kind: ContentKind.story, send: failing());
      await pumpEventQueue();
      expect(
        publish.enqueue(
          kind: ContentKind.story,
          send: ok(),
          replacesFailed: true,
        ),
        isTrue,
      );
      await pumpEventQueue();
      expect(seen.last, const ContentPublishIdle(ContentKind.story));
    });

    test('retry runs the same job again', () async {
      var tries = 0;
      publish.enqueue(
        kind: ContentKind.post,
        send: (_) async {
          if (++tries == 1) throw const NetworkFailure();
        },
      );
      await pumpEventQueue();
      publish.retry(ContentKind.post);
      await pumpEventQueue();

      expect(tries, 2);
      expect(seen.whereType<ContentPublishDone>(), hasLength(1));
    });

    test('discard drops the failed job', () async {
      publish.enqueue(kind: ContentKind.post, send: failing());
      await pumpEventQueue();
      publish.discard(ContentKind.post);
      await pumpEventQueue();

      expect(seen.last, const ContentPublishIdle(ContentKind.post));
      publish.retry(ContentKind.post);
      await pumpEventQueue();
      expect(seen.last, const ContentPublishIdle(ContentKind.post));
    });

    test('retry and discard do nothing when nothing failed', () async {
      publish
        ..retry(ContentKind.post)
        ..discard(ContentKind.post);
      await pumpEventQueue();
      expect(seen, isEmpty);
    });

    test('retry and discard touch only their kind', () async {
      publish.enqueue(kind: ContentKind.post, send: failing());
      await pumpEventQueue();
      publish.discard(ContentKind.story);
      await pumpEventQueue();
      expect(publish.current(ContentKind.post), isA<ContentPublishFailed>());
    });
  });
}
