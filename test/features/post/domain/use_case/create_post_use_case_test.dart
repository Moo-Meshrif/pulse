import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/repository/feed_refresh_repository.dart';
import 'package:pulse/features/post/data/repository/post_media_repository.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_media_entity.dart';
import 'package:pulse/features/post/domain/use_case/create_post_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

class _MockPosts extends Mock implements PostsDatasource {}

class _MockThumbnails extends Mock implements VideoThumbnailService {}

class _MockFeedRefresh extends Mock implements FeedRefreshRepository {}

void main() {
  late _MockPosts posts;
  late _MockThumbnails thumbnails;
  late _MockFeedRefresh feedRefresh;
  late CreatePostUseCase useCase;

  const photo = NewPostMediaEntity(
    filePath: '/tmp/a.JPG',
    isVideo: false,
    width: 1080,
    height: 1350,
    blurhash: 'LEHV6n',
  );
  const video = NewPostMediaEntity(
    filePath: '/tmp/b.mov',
    isVideo: true,
    width: 720,
    height: 1280,
    durationMs: 5000,
  );
  const post = NewPostEntity(
    id: 'p1',
    caption: 'Hello',
    location: 'Cairo',
    commentsEnabled: false,
    visibility: ContentAudience.closeFriends,
    media: [photo, video],
  );

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(ContentAudience.public);
  });

  setUp(() {
    posts = _MockPosts();
    thumbnails = _MockThumbnails();
    feedRefresh = _MockFeedRefresh();
    useCase = CreatePostUseCase(
      posts,
      PostMediaRepository(posts, thumbnails),
      feedRefresh,
    );
    when(() => posts.currentUserId).thenReturn('u1');
    when(() => posts.listFiles(any())).thenAnswer((_) async => const []);
    when(
      () => posts.uploadFile(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async {});
    when(() => posts.removeFiles(any())).thenAnswer((_) async {});
    when(
      () => posts.createPost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        commentsEnabled: any(named: 'commentsEnabled'),
        visibility: any(named: 'visibility'),
        media: any(named: 'media'),
      ),
    ).thenAnswer((_) async {});
    when(() => thumbnails.thumbnail(any()))
        .thenAnswer((_) async => '/tmp/t.jpg');
  });

  List<String> uploadedPaths() => verify(
    () => posts.uploadFile(
      path: captureAny(named: 'path'),
      file: any(named: 'file'),
      contentType: any(named: 'contentType'),
    ),
  ).captured.cast<String>();

  test('uploads under uid/postId, then creates the post once', () async {
    await useCase(post);

    expect(uploadedPaths(), [
      'u1/p1/0.jpg',
      'u1/p1/1.mov',
      'u1/p1/1_thumb.jpg',
    ]);
    final media =
        verify(
              () => posts.createPost(
                id: 'p1',
                caption: 'Hello',
                location: 'Cairo',
                commentsEnabled: false,
                visibility: ContentAudience.closeFriends,
                media: captureAny(named: 'media'),
              ),
            ).captured.single
            as List<PostMediaModel>;
    expect(media, const [
      PostMediaModel(
        type: MediaType.image,
        path: 'u1/p1/0.jpg',
        width: 1080,
        height: 1350,
        blurhash: 'LEHV6n',
      ),
      PostMediaModel(
        type: MediaType.video,
        path: 'u1/p1/1.mov',
        thumbPath: 'u1/p1/1_thumb.jpg',
        width: 720,
        height: 1280,
        durationMs: 5000,
      ),
    ]);
    verifyNever(() => posts.removeFiles(any()));
  });

  test('sends the content type of each file', () async {
    await useCase(post);

    final types = verify(
      () => posts.uploadFile(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: captureAny(named: 'contentType'),
      ),
    ).captured;
    expect(types, ['image/jpeg', 'video/quicktime', 'image/jpeg']);
  });

  test('a retry uploads only the files that are missing', () async {
    when(() => posts.listFiles('u1/p1'))
        .thenAnswer((_) async => const ['0.jpg', '1.mov']);

    await useCase(post);

    expect(uploadedPaths(), ['u1/p1/1_thumb.jpg']);
    verify(
      () => posts.createPost(
        id: 'p1',
        caption: 'Hello',
        location: 'Cairo',
        commentsEnabled: false,
        visibility: ContentAudience.closeFriends,
        media: any(named: 'media'),
      ),
    ).called(1);
  });

  test('a failed insert removes every uploaded file and rethrows', () async {
    when(
      () => posts.createPost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        commentsEnabled: any(named: 'commentsEnabled'),
        visibility: any(named: 'visibility'),
        media: any(named: 'media'),
      ),
    ).thenThrow(const ServerFailure());

    await expectLater(useCase(post), throwsA(isA<ServerFailure>()));

    verify(
      () => posts.removeFiles([
        'u1/p1/0.jpg',
        'u1/p1/1.mov',
        'u1/p1/1_thumb.jpg',
      ]),
    ).called(1);
  });

  test('a failed cleanup does not hide the original failure', () async {
    when(
      () => posts.createPost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        commentsEnabled: any(named: 'commentsEnabled'),
        visibility: any(named: 'visibility'),
        media: any(named: 'media'),
      ),
    ).thenThrow(const ServerFailure());
    when(() => posts.removeFiles(any())).thenThrow(const NetworkFailure());

    await expectLater(useCase(post), throwsA(isA<ServerFailure>()));
  });

  test(
    'a failed upload stops before the insert and keeps the files for a retry',
    () async {
      when(
        () => posts.uploadFile(
          path: 'u1/p1/1.mov',
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
        ),
      ).thenThrow(const NetworkFailure());

      await expectLater(useCase(post), throwsA(isA<NetworkFailure>()));

      verifyNever(
        () => posts.createPost(
          id: any(named: 'id'),
          caption: any(named: 'caption'),
          location: any(named: 'location'),
          commentsEnabled: any(named: 'commentsEnabled'),
          visibility: any(named: 'visibility'),
          media: any(named: 'media'),
        ),
      );
      verifyNever(() => posts.removeFiles(any()));
    },
  );

  test('asks the home feed to load again once the post exists', () async {
    await useCase(post);
    verify(() => feedRefresh.request()).called(1);
  });

  test('does not ask when the post could not be created', () async {
    when(
      () => posts.createPost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        commentsEnabled: any(named: 'commentsEnabled'),
        visibility: any(named: 'visibility'),
        media: any(named: 'media'),
      ),
    ).thenThrow(const NetworkFailure());
    await expectLater(useCase(post), throwsA(isA<NetworkFailure>()));
    verifyNever(() => feedRefresh.request());
  });
}
