import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/features/post/data/datasource/post_draft_datasource.dart';
import 'package:pulse/features/post/data/model/post_draft_media_model.dart';
import 'package:pulse/features/post/data/model/post_draft_model.dart';
import 'package:pulse/features/post/data/repository/post_share_repository.dart';
import 'package:pulse/features/post/data/repository/shared_posts_repository.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/model/pending_content_status_model.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';

import '../../../../helpers/content_mocks.dart';
import '../../../../helpers/pump_app.dart';

class _Share extends Mock implements PostShareRepository {}

/// The device: the draft, the shared list and the folders deleted.
class _Device implements PostDraftDatasource {
  PostDraftModel? draft;
  List<PostDraftModel>? shared = [];
  final deleted = <String>[];
  Set<String>? keptFolders;

  @override
  PostDraftModel? read() => draft;

  @override
  Future<void> save(PostDraftModel draft) async => this.draft = draft;

  @override
  Future<String> keep(String draftId, String path) async => path;

  @override
  Future<void> forget() async => draft = null;

  @override
  Future<void> deleteFiles(String draftId) async => deleted.add(draftId);

  @override
  Future<void> deleteFile(String path) async {}

  @override
  List<PostDraftModel>? readShared() => shared == null ? null : [...shared!];

  @override
  Future<void> saveShared(PostDraftModel post) async =>
      shared = [...?shared?.where((item) => item.id != post.id), post];

  @override
  Future<void> forgetShared(String id) async =>
      shared = [...?shared?.where((item) => item.id != id)];

  @override
  Future<void> deleteFoldersExcept(Set<String> ids) async => keptFolders = ids;
}

PostDraftModel _post(String id, {String caption = 'hello'}) => PostDraftModel(
  id: id,
  caption: caption,
  commentsEnabled: true,
  visibility: 'followers',
  media: const [
    PostDraftMediaModel(
      id: 'm1',
      path: '/drafts/a.jpg',
      isVideo: false,
      width: 800,
      height: 600,
    ),
  ],
);

void main() {
  late _Device device;
  late MockPendingContentDatasource server;
  late _Share share;
  late EventBus bus;
  late ContentPublishRepositoryImpl publish;
  late SharedPostsRepository shared;
  late List<Object> events;

  setUpAll(() {
    registerFallbackValue(
      const NewPostEntity(
        id: 'x',
        commentsEnabled: true,
        visibility: ContentAudience.public,
        media: [],
      ),
    );
  });

  setUp(() async {
    device = _Device();
    server = serverDraftOk();
    share = _Share();
    when(
      () => share.share(
        any(),
        beforeUpload: any(named: 'beforeUpload'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => null);
    bus = EventBus();
    publish = ContentPublishRepositoryImpl(
      bus,
      FakeContentDiscards(),
      FakeConnectivity(),
    );
    shared = SharedPostsRepository(device, server, share, publish, bus);
    events = [];
    bus.on<Object>().listen(events.add);
    await pumpEventQueue();
  });

  tearDown(() => bus.dispose());

  void serverHas(Map<String, PendingContentState> states) =>
      when(() => server.status(any())).thenAnswer(
        (_) async => [
          for (final entry in states.entries)
            PendingContentStatusModel(id: entry.key, state: entry.value),
        ],
      );

  NewPostEntity sharedPost() =>
      verify(
            () => share.share(
              captureAny(),
              beforeUpload: any(named: 'beforeUpload'),
              onProgress: any(named: 'onProgress'),
            ),
          ).captured.single
          as NewPostEntity;

  group('send', () {
    test('saves the post as shared and forgets the draft, then forgets it once out', () async {
      device.draft = _post('p1');
      final seen = <List<String?>>[];
      final gate = Completer<void>();
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async {
        seen.add([for (final post in device.shared!) post.caption]);
        await gate.future;
        return null;
      });

      final isStarted = shared.send(
        _post('p1', caption: '  hi  '),
        build: () async => const NewPostEntity(
          id: 'p1',
          caption: 'hi',
          commentsEnabled: true,
          visibility: ContentAudience.followers,
          media: [],
        ),
      );
      await pumpEventQueue();

      expect(isStarted, isTrue);
      expect(device.draft, isNull);
      expect(seen, [
        ['hi'], // the read post replaced the draft as left
      ]);
      gate.complete();
      await pumpEventQueue();
      expect(device.shared, isEmpty);
      expect(device.deleted, ['p1']);
      expect(events, isNot(contains(const FeedRefreshRequested())));
    });

    test('a failed post discarded is forgotten with its files', () async {
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const NetworkFailure());
      var stopped = false;
      shared.send(
        _post('p1'),
        build: () async => const NewPostEntity(
          id: 'p1',
          commentsEnabled: true,
          visibility: ContentAudience.public,
          media: [],
        ),
        onStop: () => stopped = true,
      );
      await pumpEventQueue();
      expect(device.shared!.single.id, 'p1');

      publish.discard(ContentKind.post);
      await pumpEventQueue();
      expect(stopped, isTrue);
      expect(device.shared, isEmpty);
      expect(device.deleted, ['p1']);
    });
  });

  group('resume', () {
    test('a post the server has not posted goes again, the same', () async {
      device.shared = [_post('p1', caption: '  hello  ')];
      serverHas({'p1': PendingContentState.waiting});

      await shared.resume();
      await pumpEventQueue();

      verify(() => server.status(['p1'])).called(1);
      final post = sharedPost();
      expect(post.id, 'p1');
      expect(post.caption, 'hello');
      expect(post.visibility, ContentAudience.followers);
      expect(post.media.single.id, 'm1');
      expect(post.media.single.filePath, '/drafts/a.jpg');
      expect(device.shared, isEmpty);
      expect(device.keptFolders, {'p1'});
    });

    test('a post already out is forgotten, and the feed loads again', () async {
      device.shared = [_post('p1')];
      serverHas({'p1': PendingContentState.published});

      await shared.resume();

      verifyNever(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      );
      expect(device.shared, isEmpty);
      expect(device.deleted, ['p1']);
      expect(events, isNot(contains(const FeedRefreshRequested())));
      expect(device.keptFolders, isEmpty);
    });

    test('a discarded or abandoned post is forgotten', () async {
      device.shared = [_post('p1'), _post('p2')];
      serverHas({
        'p1': PendingContentState.discarded,
        'p2': PendingContentState.abandoned,
      });

      await shared.resume();

      expect(device.shared, isEmpty);
      expect(device.deleted, ['p1', 'p2']);
    });

    test('a post already being sent is not sent twice', () async {
      final gate = Completer<NewPostEntity>();
      shared.send(_post('p1'), build: () => gate.future);
      await pumpEventQueue();
      serverHas({'p1': PendingContentState.waiting});

      await shared.resume();

      expect(publish.current(ContentKind.post), isA<ContentPublishing>());
      expect(device.keptFolders, {'p1'});
      gate.complete(
        const NewPostEntity(
          id: 'p1',
          commentsEnabled: true,
          visibility: ContentAudience.public,
          media: [],
        ),
      );
      await pumpEventQueue();
      verify(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
    });

    test('a draft the server says is finished is forgotten', () async {
      device.draft = _post('d1');
      serverHas({'d1': PendingContentState.discarded});

      await shared.resume();

      expect(device.draft, isNull);
      expect(device.deleted, ['d1']);
      expect(device.keptFolders, isEmpty);
    });

    test('offline, a draft stays and a shared post still goes', () async {
      device.draft = _post('d1');
      device.shared = [_post('p1')];
      when(() => server.status(any())).thenThrow(const NetworkFailure());

      await shared.resume();
      await pumpEventQueue();

      expect(device.draft?.id, 'd1');
      expect(sharedPost().id, 'p1');
      expect(device.keptFolders, {'p1', 'd1'});
    });

    test(
      'an unreadable list deletes nothing the server has not finished',
      () async {
        device.shared = null;
        device.draft = _post('d1');
        serverHas({
          'p1': PendingContentState.waiting,
          'p2': PendingContentState.rejected,
        });

        await shared.resume();

        verify(() => server.status(null)).called(1);
        verify(() => server.publish('p1')).called(1);
        verifyNever(() => server.publish('p2'));
        expect(device.keptFolders, {'d1', 'p1', 'p2'});
      },
    );

    test('an unreadable list offline deletes nothing', () async {
      device.shared = null;
      when(() => server.status(any())).thenThrow(const NetworkFailure());

      await shared.resume();

      expect(device.keptFolders, isNull);
    });
  });
}
