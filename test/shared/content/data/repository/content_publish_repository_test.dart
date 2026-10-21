import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_line.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';

import '../../../../helpers/content_mocks.dart';

void main() {
  late EventBus bus;
  late ContentPublishRepositoryImpl publish;
  late List<ContentPublishStatus> seen;
  late FakeContentDiscards discards;

  setUp(() async {
    bus = EventBus();
    discards = FakeContentDiscards();
    publish = ContentPublishRepositoryImpl(bus, discards, FakeConnectivity());
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

  test('a busy story refuses a second one; other kinds go at once', () async {
    final gate = Completer<void>();
    expect(
      publish.enqueue(kind: ContentKind.story, send: (_) => gate.future),
      isTrue,
    );
    expect(publish.enqueue(kind: ContentKind.story, send: ok()), isFalse);
    expect(publish.enqueue(kind: ContentKind.short, send: ok()), isTrue);
    await pumpEventQueue();

    expect(publish.current(ContentKind.story), isA<ContentPublishing>());
    expect(
      publish.current(ContentKind.short),
      const ContentPublishIdle(ContentKind.short),
    );
    gate.complete();
    await pumpEventQueue();
    expect(publish.enqueue(kind: ContentKind.story, send: ok()), isTrue);
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

    test('a failed story waits: a new one is refused', () async {
      publish.enqueue(kind: ContentKind.story, send: failing());
      await pumpEventQueue();
      expect(publish.enqueue(kind: ContentKind.story, send: ok()), isFalse);
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

    test(
      'discard tells the job, once; a job that is going is not told',
      () async {
        var told = 0;
        Future<void> onDiscard() async => told++;
        final going = Completer<void>();
        publish.enqueue(
          kind: ContentKind.post,
          send: (_) => going.future,
          onDiscard: onDiscard,
        );
        publish.discard(ContentKind.post);
        expect(told, 0);
        going.completeError(const NetworkFailure());
        await pumpEventQueue();

        publish
          ..discard(ContentKind.post)
          ..discard(ContentKind.post);
        await pumpEventQueue();
        expect(told, 1);
      },
    );

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

  group('discard on the server', () {
    Future<void> failedWithId() async {
      publish.enqueue(
        kind: ContentKind.post,
        send: failing(),
        pendingId: 'p1',
        onDiscard: () async => discards.saved.add('device side'),
      );
      await pumpEventQueue();
    }

    test('saves the discard, then the device side, then sends it', () async {
      await failedWithId();
      publish.discard(ContentKind.post);
      await pumpEventQueue();

      expect(discards.saved, ['p1', 'device side']);
      expect(discards.sent, ['p1']);
      expect(seen.last, const ContentPublishIdle(ContentKind.post));
    });

    test('a post that had already gone out is announced, then idle', () async {
      discards.answer = PendingContentState.published;
      await failedWithId();
      publish.discard(ContentKind.post);
      await pumpEventQueue();

      expect(seen.sublist(seen.length - 2), const [
        ContentDiscardRefused(ContentKind.post),
        ContentPublishIdle(ContentKind.post),
      ]);
    });

    test(
      'offline the banner is gone at once, and a new post is not blocked',
      () async {
        discards.answer = null;
        await failedWithId();
        publish.discard(ContentKind.post);
        await pumpEventQueue();
        expect(seen.last, const ContentPublishIdle(ContentKind.post));

        expect(publish.enqueue(kind: ContentKind.post, send: ok()), isTrue);
      },
    );

    test('a job without an id is only dropped', () async {
      publish.enqueue(kind: ContentKind.post, send: failing());
      await pumpEventQueue();
      publish.discard(ContentKind.post);
      await pumpEventQueue();
      expect(discards.saved, isEmpty);
      expect(discards.sent, isEmpty);
    });
  });

  test('a rejected job cannot be retried, only discarded', () async {
    var tries = 0;
    publish.enqueue(
      kind: ContentKind.post,
      send: (_) async {
        tries++;
        throw const RejectedFailure();
      },
    );
    await pumpEventQueue();
    final status = publish.current(ContentKind.post);
    expect((status as ContentPublishFailed).canRetry, isFalse);

    publish.retry(ContentKind.post);
    await pumpEventQueue();
    expect(tries, 1);
    publish.discard(ContentKind.post);
    await pumpEventQueue();
    expect(seen.last, const ContentPublishIdle(ContentKind.post));
  });

  group('accounts', () {
    test('another user drops the jobs; their late answer is ignored', () async {
      publish.useAccount('a');
      final going = Completer<void>();
      publish.enqueue(
        kind: ContentKind.post,
        send: (_) => going.future,
        pendingId: 'p1',
      );
      await pumpEventQueue();
      expect(publish.hasJob('p1'), isTrue);

      publish.useAccount('b');
      await pumpEventQueue();
      expect(publish.hasJob('p1'), isFalse);
      expect(seen.last, const ContentPublishIdle(ContentKind.post));

      going.completeError(const NetworkFailure());
      await pumpEventQueue();
      expect(seen.last, const ContentPublishIdle(ContentKind.post));
      expect(publish.current(ContentKind.post), isA<ContentPublishIdle>());
    });

    test('the same user keeps the jobs', () async {
      publish.useAccount('a');
      publish.enqueue(kind: ContentKind.post, send: failing());
      await pumpEventQueue();
      publish.useAccount('a');
      expect(publish.current(ContentKind.post), isA<ContentPublishFailed>());
    });
  });

  test('retryLost sends again only what failed for the connection', () async {
    var postTries = 0;
    var storyTries = 0;
    publish
      ..enqueue(
        kind: ContentKind.post,
        send: (_) async {
          if (++postTries == 1) throw const TimeoutFailure();
        },
      )
      ..enqueue(
        kind: ContentKind.story,
        send: (_) async {
          storyTries++;
          throw const ServerFailure();
        },
      );
    await pumpEventQueue();

    publish.retryLost();
    await pumpEventQueue();

    expect(postTries, 2);
    expect(storyTries, 1);
    expect(publish.current(ContentKind.post), isA<ContentPublishIdle>());
  });

  group('a line of posts', () {
    List<ContentLineState> states() => [
      for (final item in publish.line(ContentKind.post).items) item.state,
    ];

    test(
      'goes out one at a time in the order shared; a 4th is refused',
      () async {
        final order = <String>[];
        final gates = [for (var i = 0; i < 3; i++) Completer<void>()];
        for (final (i, gate) in gates.indexed) {
          expect(
            publish.enqueue(
              kind: ContentKind.post,
              pendingId: 'p$i',
              send: (_) {
                order.add('p$i');
                return gate.future;
              },
            ),
            isTrue,
          );
        }
        expect(publish.enqueue(kind: ContentKind.post, send: ok()), isFalse);
        await pumpEventQueue();
        expect(order, ['p0']);
        expect(states(), [
          ContentLineState.sending,
          ContentLineState.waiting,
          ContentLineState.waiting,
        ]);

        gates[0].complete();
        await pumpEventQueue();
        gates[1].complete();
        await pumpEventQueue();
        expect(order, ['p0', 'p1', 'p2']);
        expect(states(), [
          ContentLineState.done,
          ContentLineState.done,
          ContentLineState.sending,
        ]);
      },
    );

    test('a failed post does not stop the next; Retry names it', () async {
      var tries = 0;
      publish
        ..enqueue(
          kind: ContentKind.post,
          pendingId: 'p0',
          send: (_) async {
            if (++tries == 1) throw const ServerFailure();
          },
        )
        ..enqueue(kind: ContentKind.post, pendingId: 'p1', send: ok());
      await pumpEventQueue();
      expect(states(), [ContentLineState.done, ContentLineState.failed]);

      publish.retry(ContentKind.post, id: 'p0');
      await pumpEventQueue();
      expect(tries, 2);
      expect(publish.line(ContentKind.post).isAllDone, isTrue);
    });

    test('Discard names the failed post; the rest stays', () async {
      publish
        ..enqueue(kind: ContentKind.post, pendingId: 'p0', send: failing())
        ..enqueue(kind: ContentKind.post, pendingId: 'p1', send: failing());
      await pumpEventQueue();

      publish.discard(ContentKind.post, id: 'p1');
      await pumpEventQueue();

      expect(
        [for (final item in publish.line(ContentKind.post).items) item.id],
        ['p0'],
      );
      expect(discards.saved, ['p1']);
    });

    test('the finished posts stay until the next post starts', () async {
      publish.enqueue(kind: ContentKind.post, send: ok());
      await pumpEventQueue();
      expect(publish.line(ContentKind.post).isAllDone, isTrue);

      publish.enqueue(
        kind: ContentKind.post,
        send: (_) => Completer<void>().future,
      );
      await pumpEventQueue();
      expect(states(), [ContentLineState.sending]);
    });
  });
}
