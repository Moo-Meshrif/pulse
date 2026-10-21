import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/shared/content/data/datasource/content_discards_datasource.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/model/content_cleanup_model.dart';
import 'package:pulse/shared/content/data/model/content_discard_model.dart';
import 'package:pulse/shared/content/data/repository/content_discard_repository.dart';

import '../../../../helpers/pump_app.dart';

class _Files extends Mock implements MediaFilesDatasource {}

class _Connectivity extends Mock implements ConnectivityService {}

/// The device list in memory.
class _Saved implements ContentDiscardsDatasource {
  final items = <ContentDiscardModel>[];

  List<String?> get ids => [for (final item in items) item.id];

  @override
  List<ContentDiscardModel> read() => List.of(items);

  @override
  Future<void> add(ContentDiscardModel discard) async {
    if (!ids.contains(discard.id)) items.add(discard);
  }

  @override
  Future<void> remove(String id) async =>
      items.removeWhere((item) => item.id == id);
}

void main() {
  late _Saved saved;
  late MockPendingContentDatasource server;
  late _Files files;
  late StreamController<void> hints;
  late ContentDiscardRepositoryImpl discards;

  setUp(() {
    saved = _Saved();
    server = serverDraftOk();
    when(server.cleanupList).thenAnswer((_) async => const []);
    when(() => server.confirmCleanup(any())).thenAnswer((_) async => 0);
    files = _Files();
    when(() => files.remove(any())).thenAnswer((_) async {});
    hints = StreamController<void>.broadcast();
    final connectivity = _Connectivity();
    when(() => connectivity.connectionHints).thenAnswer((_) => hints.stream);
    discards = ContentDiscardRepositoryImpl(saved, server, files, connectivity);
  });

  tearDown(() => hints.close());

  test('the server is told, the saved discard forgotten', () async {
    await discards.save('p1', ContentKind.post);
    expect(saved.ids, ['p1']);

    final state = await discards.send('p1', ContentKind.post);

    expect(state, PendingContentState.discarded);
    verify(() => server.discard('p1', ContentKind.post)).called(1);
    expect(saved.ids, isEmpty);
    expect(discards.isWaiting(ContentKind.post), isFalse);
  });

  test('a post that had already gone out answers published', () async {
    when(() => server.discard(any(), any()))
        .thenAnswer((_) async => PendingContentState.published);
    await discards.save('p1', ContentKind.post);

    expect(
      await discards.send('p1', ContentKind.post),
      PendingContentState.published,
    );
    expect(saved.ids, isEmpty);
  });

  test(
    'offline it stays saved and waits, then goes when the connection is back',
    () async {
      when(() => server.discard(any(), any()))
          .thenThrow(const NetworkFailure());
      final changes = <ContentKind>[];
      discards.changes.listen(changes.add);
      await discards.save('p1', ContentKind.post);

      expect(await discards.send('p1', ContentKind.post), isNull);
      await pumpEventQueue();
      expect(saved.ids, ['p1']);
      expect(discards.isWaiting(ContentKind.post), isTrue);
      expect(changes, [ContentKind.post]);

      when(() => server.discard(any(), any()))
          .thenAnswer((_) async => PendingContentState.discarded);
      hints.add(null);
      await pumpEventQueue();

      expect(saved.ids, isEmpty);
      expect(discards.isWaiting(ContentKind.post), isFalse);
      expect(changes, [ContentKind.post, ContentKind.post]);
      expect(hints.hasListener, isFalse);
    },
  );

  test('discards saved before (the app closed) are sent at start', () async {
    saved.items.addAll(const [
      ContentDiscardModel(id: 'p1', kind: ContentKind.post),
      ContentDiscardModel(id: 'p2', kind: ContentKind.post),
    ]);

    await discards.sendSaved();

    verify(() => server.discard('p1', ContentKind.post)).called(1);
    verify(() => server.discard('p2', ContentKind.post)).called(1);
    expect(saved.ids, isEmpty);
  });

  test('the files the server lists are deleted, then confirmed', () async {
    when(server.cleanupList).thenAnswer(
      (_) async => const [
        ContentCleanupModel(id: 'p1', paths: ['u1/p1/a.jpg', 'u1/p1/b.jpg']),
      ],
    );

    await discards.send('p1', ContentKind.post);
    await pumpEventQueue();

    verifyInOrder([
      () => files.remove(['u1/p1/a.jpg', 'u1/p1/b.jpg']),
      () => server.confirmCleanup('p1'),
    ]);
  });

  test('a cleanup that fails is tried again next time', () async {
    when(server.cleanupList).thenThrow(const NetworkFailure());
    await discards.sendSaved();
    verifyNever(() => server.confirmCleanup(any()));

    when(server.cleanupList).thenAnswer(
      (_) async => const [
        ContentCleanupModel(id: 'p1', paths: ['u1/p1/a.jpg']),
      ],
    );
    await discards.sendSaved();
    verify(() => server.confirmCleanup('p1')).called(1);
  });

  test('nothing is cleaned while a saved discard cannot be sent', () async {
    when(() => server.discard(any(), any())).thenThrow(const TimeoutFailure());
    saved.items.add(
      const ContentDiscardModel(id: 'p1', kind: ContentKind.post),
    );

    await discards.sendSaved();

    verifyNever(server.cleanupList);
    expect(saved.ids, ['p1']);
  });

  test(
    'a discard that could not be saved stops waiting at the next sweep',
    () async {
      when(() => server.discard(any(), any()))
          .thenThrow(const NetworkFailure());
      expect(await discards.send('p1', ContentKind.post), isNull);
      expect(discards.isWaiting(ContentKind.post), isTrue);

      await discards.sendSaved();

      expect(discards.isWaiting(ContentKind.post), isFalse);
    },
  );

  test('another user signing in stops the waiting of the last one', () async {
    discards.useAccount('a');
    when(() => server.discard(any(), any())).thenThrow(const NetworkFailure());
    await discards.save('p1', ContentKind.post);
    await discards.send('p1', ContentKind.post);
    expect(discards.isWaiting(ContentKind.post), isTrue);

    discards.useAccount('b');

    expect(discards.isWaiting(ContentKind.post), isFalse);
    expect(hints.hasListener, isFalse);
  });
}
