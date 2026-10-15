import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/repository/post_media_repository.dart';
import 'package:pulse/features/post/domain/entity/edit_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/features/post/domain/use_case/set_comments_enabled_use_case.dart';
import 'package:pulse/features/post/domain/use_case/update_post_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';

class _MockPosts extends Mock implements PostsDatasource {}

class _MockThumbnails extends Mock implements VideoThumbnailService {}

class _MockSetComments extends Mock implements SetCommentsEnabledUseCase {}

class _MockSetAudience extends Mock implements SetContentAudienceUseCase {}

void main() {
  late _MockPosts posts;
  late _MockSetComments setComments;
  late _MockSetAudience setAudience;
  late UpdatePostUseCase useCase;

  const old0 = PostMediaEntity(
    isVideo: false,
    path: 'u1/p1/0.jpg',
    width: 10,
    height: 10,
  );
  const old1 = PostMediaEntity(
    isVideo: false,
    path: 'u1/p1/1.jpg',
    width: 10,
    height: 10,
  );
  const added = NewPostMediaEntity(
    filePath: '/tmp/new.jpg',
    isVideo: false,
    width: 20,
    height: 20,
  );

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(ContentKind.post);
    registerFallbackValue(ContentAudience.public);
  });

  setUp(() {
    posts = _MockPosts();
    setComments = _MockSetComments();
    setAudience = _MockSetAudience();
    when(() => setComments(any(), enabled: any(named: 'enabled')))
        .thenAnswer((_) async {});
    when(() => setAudience(any(), any(), any())).thenAnswer((_) async {});
    useCase = UpdatePostUseCase(
      posts,
      PostMediaRepository(posts, _MockThumbnails()),
      setComments,
      setAudience,
    );
    when(() => posts.currentUserId).thenReturn('u1');
    when(
      () => posts.uploadFile(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async {});
    when(() => posts.removeFiles(any())).thenAnswer((_) async {});
    when(
      () => posts.updatePost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        media: any(named: 'media'),
      ),
    ).thenAnswer((_) async {});
  });

  const edited = EditPostEntity(
    id: 'p1',
    caption: 'New',
    kept: [old0],
    added: [added],
    commentsEnabled: true,
    visibility: ContentAudience.public,
  );

  final before = PostEntity(
    id: 'p1',
    authorId: 'u1',
    username: 'omar',
    likeCount: 0,
    commentCount: 0,
    commentsEnabled: true,
    visibility: ContentAudience.public,
    createdAt: DateTime(2026),
    likedByMe: false,
    savedByMe: false,
    media: const [old0, old1],
  );
  setUpAll(() => registerFallbackValue(before));

  test(
    'saves the kept media then the added one, and removes the dropped file',
    () async {
      final saved = await useCase(edited, before: before);

      final media =
          verify(
                () => posts.updatePost(
                  id: 'p1',
                  caption: 'New',
                  location: null,
                  media: captureAny(named: 'media'),
                ),
              ).captured.single
              as List<PostMediaModel>;
      expect(media.map((m) => m.path).first, 'u1/p1/0.jpg');
      expect(media.last.path, startsWith('u1/p1/e'));
      verify(() => posts.removeFiles(['u1/p1/1.jpg'])).called(1);
      expect(saved.id, 'p1');
      expect(saved.caption, 'New');
      expect(saved.media.first.path, 'u1/p1/0.jpg');
      expect(saved.media.last.path, startsWith('u1/p1/e'));
    },
  );

  test(
    'a failed save removes the new files, keeps the old ones and rethrows',
    () async {
      when(
        () => posts.updatePost(
          id: any(named: 'id'),
          caption: any(named: 'caption'),
          location: any(named: 'location'),
          media: any(named: 'media'),
        ),
      ).thenThrow(const NetworkFailure());

      await expectLater(
        useCase(edited, before: before),
        throwsA(isA<NetworkFailure>()),
      );

      final removed =
          verify(() => posts.removeFiles(captureAny())).captured.single
              as List<String>;
      expect(removed.single, startsWith('u1/p1/e'));
    },
  );

  test(
    'applies a changed comments switch and audience, and only those',
    () async {
      await useCase(edited, before: before);
      verifyNever(() => setComments(any(), enabled: any(named: 'enabled')));
      verifyNever(() => setAudience(any(), any(), any()));

      await useCase(
        const EditPostEntity(
          id: 'p1',
          kept: [old0, old1],
          added: [],
          commentsEnabled: false,
          visibility: ContentAudience.followers,
        ),
        before: before,
      );
      verify(() => setComments('p1', enabled: false)).called(1);
      verify(
        () => setAudience(ContentKind.post, 'p1', ContentAudience.followers),
      ).called(1);
    },
  );
}
