import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/constants/app_config.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/shared/content/data/datasource/content_changes_datasource.dart';
import 'package:pulse/shared/content/data/datasource/content_changes_point_datasource.dart';
import 'package:pulse/shared/content/data/datasource/content_live_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_change_op.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/model/content_changes_model.dart';
import 'package:pulse/shared/content/data/model/content_changes_point_model.dart';
import 'package:pulse/shared/content/data/repository/content_changes_repository.dart';
import 'package:pulse/shared/content/domain/event/content_changed.dart';
import 'package:pulse/shared/content/domain/event/content_ping.dart';

/// A live connection the test can ping by hand.
class _Live implements ContentLiveDatasource {
  // ignore: close_sinks, lives for the test run.
  final controller = StreamController<ContentKind>.broadcast();

  @override
  Stream<ContentKind> pings() => controller.stream;
}

class _Server extends Mock implements ContentChangesDatasource {}

/// The saved points in memory.
class _Points implements ContentChangesPointDatasource {
  final saved = <ContentKind, ContentChangesPointModel>{};

  @override
  ContentChangesPointModel? read(ContentKind kind) => saved[kind];

  @override
  Future<void> write(ContentKind kind, ContentChangesPointModel point) async =>
      saved[kind] = point;
}

void main() {
  final now = DateTime.utc(2026, 10, 21, 12);
  late _Server server;
  late _Points points;
  late _Live live;
  late EventBus bus;
  late List<ContentChanged> events;
  late ContentChangesRepositoryImpl repository;

  ContentChangesModel answer({
    bool reset = false,
    List<ContentChangeModel> ops = const [],
    required DateTime nextAt,
    String? nextId,
    bool hasMore = false,
  }) => ContentChangesModel(
    reset: reset,
    ops: ops,
    nextAt: nextAt,
    nextId: nextId,
    hasMore: hasMore,
  );

  ContentChangeModel change(ContentChangeOp op, String id) =>
      ContentChangeModel(op: op, id: id, at: now);

  void serverReturns(List<ContentChangesModel> pages) {
    final queue = List.of(pages);
    when(
      () => server.changesSince(
        any(),
        afterAt: any(named: 'afterAt'),
        afterId: any(named: 'afterId'),
      ),
    ).thenAnswer((_) async => queue.removeAt(0));
  }

  setUpAll(() => registerFallbackValue(ContentKind.post));

  setUp(() {
    server = _Server();
    points = _Points();
    live = _Live();
    bus = EventBus();
    events = [];
    bus.on<ContentChanged>().listen(events.add);
    repository = ContentChangesRepositoryImpl(server, points, bus, live);
  });

  tearDown(() => bus.dispose());

  Future<void> check() =>
      withClock(Clock.fixed(now), () => repository.check(ContentKind.post));

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('the first check only saves a point and sends nothing', () async {
    final start = now.subtract(const Duration(seconds: 5));
    serverReturns([answer(reset: true, nextAt: start)]);

    await check();
    await settle();

    expect(events, isEmpty);
    expect(points.saved[ContentKind.post]?.at, start);
  });

  test(
    'changes are sent in one event, then the point moves, page by page',
    () async {
      points.saved[ContentKind.post] = ContentChangesPointModel(
        at: now.subtract(const Duration(hours: 2)),
      );
      final mid = now.subtract(const Duration(hours: 1));
      final end = now.subtract(const Duration(seconds: 5));
      serverReturns([
        answer(
          ops: [
            change(ContentChangeOp.upsert, 'a'),
            change(ContentChangeOp.remove, 'b'),
          ],
          nextAt: mid,
          nextId: 'b',
          hasMore: true,
        ),
        answer(ops: [change(ContentChangeOp.delete, 'c')], nextAt: end),
      ]);

      await check();
      await settle();

      expect(events, [
        const ContentChanged(
          ContentKind.post,
          upsertedIds: ['a'],
          removedIds: ['b'],
        ),
        const ContentChanged(ContentKind.post, removedIds: ['c']),
      ]);
      expect(points.saved[ContentKind.post]?.at, end);
      verify(
        () => server.changesSince(ContentKind.post, afterAt: mid, afterId: 'b'),
      ).called(1);
    },
  );

  test('a point older than the limit asks the screen to reload', () async {
    final old = now.subtract(AppConfig.contentChangesMaxAge * 2);
    points.saved[ContentKind.post] = ContentChangesPointModel(at: old);
    final start = now.subtract(const Duration(seconds: 5));
    serverReturns([answer(reset: true, nextAt: start)]);

    await check();
    await settle();

    expect(events, [const ContentChanged(ContentKind.post, mustReload: true)]);
    expect(points.saved[ContentKind.post]?.at, start);
  });

  test('a server reset asks the screen to reload', () async {
    points.saved[ContentKind.post] = ContentChangesPointModel(
      at: now.subtract(const Duration(hours: 1)),
    );
    final start = now.subtract(const Duration(seconds: 5));
    serverReturns([answer(reset: true, nextAt: start)]);

    await check();
    await settle();

    expect(events, [const ContentChanged(ContentKind.post, mustReload: true)]);
    expect(points.saved[ContentKind.post]?.at, start);
  });

  test('offline sends nothing and keeps the old point', () async {
    final old = now.subtract(const Duration(hours: 1));
    points.saved[ContentKind.post] = ContentChangesPointModel(at: old);
    when(
      () => server.changesSince(
        any(),
        afterAt: any(named: 'afterAt'),
        afterId: any(named: 'afterId'),
      ),
    ).thenThrow(const NetworkFailure());

    await check();
    await settle();

    expect(events, isEmpty);
    expect(points.saved[ContentKind.post]?.at, old);
  });

  group('live ping', () {
    late List<ContentPing> pings;

    setUp(() {
      pings = [];
      bus.on<ContentPing>().listen(pings.add);
    });

    tearDown(() => repository.stopLive());

    test('a burst of changes sends one ping per kind', () async {
      repository.startLive();
      live.controller
        ..add(ContentKind.post)
        ..add(ContentKind.post)
        ..add(ContentKind.story);

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(
        pings.map((p) => p.kind),
        unorderedEquals([ContentKind.post, ContentKind.story]),
      );
    });

    test('nothing is sent after it stops', () async {
      repository.startLive();
      live.controller.add(ContentKind.post);
      await Future<void>.delayed(Duration.zero);
      repository.stopLive();

      await Future<void>.delayed(const Duration(milliseconds: 1200));

      expect(pings, isEmpty);
    });
  });
}
