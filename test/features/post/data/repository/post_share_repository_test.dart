import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/repository/post_share_repository.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_media_entity.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/enums/pending_content_state.dart';
import 'package:pulse/shared/content/data/model/pending_content_status_model.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';

import '../../../../helpers/pump_app.dart';

class _Media extends Mock implements ContentMediaRepository {}

class _Posts extends Mock implements PostsDatasource {}

const _photo = NewPostMediaEntity(
  id: 'm1',
  filePath: '/drafts/p1/a.jpg',
  isVideo: false,
  width: 800,
  height: 600,
);

const _post = NewPostEntity(
  id: 'p1',
  caption: 'hello',
  commentsEnabled: true,
  visibility: ContentAudience.followers,
  media: [_photo],
  authorUsername: 'me',
);

void main() {
  late MockPendingContentDatasource server;
  late _Media media;
  late _Posts posts;
  late PostShareRepository repository;

  setUpAll(() {
    registerFallbackValue(ContentKind.post);
    registerFallbackValue(const MediaToSend(filePath: '/x', isVideo: false));
  });

  setUp(() {
    server = serverDraftOk();
    media = _Media();
    posts = _Posts();
    when(() => posts.currentUserId).thenReturn('u1');
    when(
      () => media.folderOf(any()),
    ).thenAnswer((invocation) => 'u1/${invocation.positionalArguments.first}');
    when(
      () => media.target(
        any(),
        any(),
        folder: any(named: 'folder'),
        stem: any(named: 'stem'),
      ),
    ).thenAnswer(
      (invocation) async => MediaTarget(
        path:
            '${invocation.namedArguments[#folder]}/'
            '${invocation.namedArguments[#stem]}.jpg',
        mimeType: 'image/jpeg',
        sizeBytes: 1234,
      ),
    );
    when(() => media.existing(any())).thenAnswer((_) async => <String>{});
    when(
      () => media.send(
        any(),
        any(),
        folder: any(named: 'folder'),
        stem: any(named: 'stem'),
        existing: any(named: 'existing'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((_) async => const SentMedia(path: 'u1/p1/m1.jpg'));
    repository = PostShareRepository(server, media, posts);
  });

  void verifyNothingSent() => verifyNever(
    () => media.send(
      any(),
      any(),
      folder: any(named: 'folder'),
      stem: any(named: 'stem'),
      existing: any(named: 'existing'),
      onProgress: any(named: 'onProgress'),
    ),
  );

  void serverHas(PendingContentState state) => when(() => server.status(any()))
      .thenAnswer(
        (_) async => [PendingContentStatusModel(id: 'p1', state: state)],
      );

  test(
    'saves the post with each file by its id, type and size, then posts it',
    () async {
      final created = await repository.share(_post);

      final request =
          verify(() => server.share('p1', ContentKind.post, captureAny()))
                  .captured
                  .single
              as Map<String, dynamic>;
      expect(request['caption'], 'hello');
      expect(request['visibility'], 'followers');
      expect(request['media'], [
        {
          'type': 'image',
          'path': 'u1/p1/m1.jpg',
          'thumb_path': null,
          'width': 800,
          'height': 600,
          'duration_ms': null,
          'blurhash': null,
          'mime': 'image/jpeg',
          'size': 1234,
          'thumb_mime': null,
          'thumb_size': null,
        },
      ]);
      verify(() => server.publish('p1')).called(1);
      expect(created?.id, 'p1');
      expect(created?.media.single.path, 'u1/p1/m1.jpg');
    },
  );

  test(
    'saves on the server before it waits for the uploads still going',
    () async {
      final order = <String>[];
      when(() => server.share(any(), any(), any())).thenAnswer((_) async {
        order.add('share');
        return PendingContentState.waiting;
      });
      when(() => server.publish(any())).thenAnswer((_) async {
        order.add('publish');
        return PendingContentState.published;
      });

      await repository.share(
        _post,
        beforeUpload: () async => order.add('uploads settled'),
      );

      expect(order, ['share', 'uploads settled', 'publish']);
    },
  );

  test(
    'a post already out (a Retry) is neither sent nor posted again',
    () async {
      when(() => server.share(any(), any(), any()))
          .thenAnswer((_) async => PendingContentState.published);

      final created = await repository.share(_post);

      expect(created?.id, 'p1');
      verifyNothingSent();
      verifyNever(() => server.publish(any()));
    },
  );

  test('a share timing out asks the server, then goes on', () async {
    when(() => server.share(any(), any(), any()))
        .thenThrow(const TimeoutFailure());
    serverHas(PendingContentState.waiting);

    await repository.share(_post);

    verify(() => server.status(['p1'])).called(1);
    verify(() => server.publish('p1')).called(1);
  });

  test('a share the server never got fails with its failure', () async {
    when(() => server.share(any(), any(), any()))
        .thenThrow(const NetworkFailure());
    when(() => server.status(any())).thenThrow(const NetworkFailure());

    await expectLater(repository.share(_post), throwsA(isA<NetworkFailure>()));
    verifyNothingSent();
  });

  test(
    'a lost answer to posting asks the server: it went out, so it is done',
    () async {
      when(() => server.publish(any())).thenThrow(const NetworkFailure());
      serverHas(PendingContentState.published);

      final created = await repository.share(_post);

      expect(created?.id, 'p1');
      verify(() => server.publish('p1')).called(1);
    },
  );

  test(
    'a lost answer to posting while it is still waiting fails, for Retry',
    () async {
      when(() => server.publish(any())).thenThrow(const TimeoutFailure());
      serverHas(PendingContentState.waiting);

      await expectLater(
        repository.share(_post),
        throwsA(isA<TimeoutFailure>()),
      );
    },
  );

  test('the server still waiting for a file fails, for Retry', () async {
    when(() => server.publish(any()))
        .thenAnswer((_) async => PendingContentState.waiting);

    await expectLater(repository.share(_post), throwsA(isA<ServerFailure>()));
  });

  test('a post the server rejected fails for good', () async {
    when(() => server.publish(any()))
        .thenAnswer((_) async => PendingContentState.rejected);

    await expectLater(repository.share(_post), throwsA(isA<RejectedFailure>()));
  });

  test(
    'a Retry the server refuses because the post was rejected fails for good',
    () async {
      when(() => server.share(any(), any(), any()))
          .thenThrow(const ServerFailure());
      serverHas(PendingContentState.rejected);

      await expectLater(
        repository.share(_post),
        throwsA(isA<RejectedFailure>()),
      );
      verifyNothingSent();
    },
  );

  test('only the files missing on the server are sent', () async {
    final existing = {'m1.jpg'};
    when(() => media.existing(any())).thenAnswer((_) async => existing);

    await repository.share(_post);

    final passed = verify(
      () => media.send(
        any(),
        any(),
        folder: 'u1/p1',
        stem: 'm1',
        existing: captureAny(named: 'existing'),
        onProgress: any(named: 'onProgress'),
      ),
    ).captured.single;
    expect(passed, same(existing));
  });
}
