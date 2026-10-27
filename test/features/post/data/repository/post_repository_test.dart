import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/video_compress_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/datasource/comments_datasource.dart';
import 'package:pulse/features/post/data/datasource/comments_local_datasource.dart';
import 'package:pulse/features/post/data/datasource/post_actions_datasource.dart';
import 'package:pulse/features/post/data/datasource/post_likes_datasource.dart';
import 'package:pulse/features/post/data/datasource/post_tags_datasource.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/comment_sort.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/comment_model.dart';
import 'package:pulse/features/post/data/model/comment_page_model.dart';
import 'package:pulse/features/post/data/model/liked_by_preview_model.dart';
import 'package:pulse/features/post/data/model/mention_person_model.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/features/post/data/model/tag_person_model.dart';
import 'package:pulse/features/post/data/model/tagged_person_model.dart';
import 'package:pulse/features/post/data/repository/post_repository.dart';
import 'package:pulse/features/post/domain/entity/comment_cursor_entity.dart';
import 'package:pulse/features/post/domain/entity/comment_entity.dart';
import 'package:pulse/features/post/domain/entity/edit_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_changes_repository.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';

import '../../../../helpers/memory_snapshot_storage.dart';

class _MockPosts extends Mock implements PostsDatasource {}

class _MockActions extends Mock implements PostActionsDatasource {}

class _MockComments extends Mock implements CommentsDatasource {}

class _MockLikes extends Mock implements PostLikesDatasource {}

class _MockTags extends Mock implements PostTagsDatasource {}

class _MockFiles extends Mock implements MediaFilesDatasource {}

class _MockThumbnails extends Mock implements VideoThumbnailService {}

class _MockCompressor extends Mock implements VideoCompressService {}

class _MockPublish extends Mock implements ContentPublishRepository {}

class _MockChanges extends Mock implements ContentChangesRepository {}

void main() {
  late _MockPosts posts;
  late _MockActions actions;
  late _MockComments comments;
  late _MockLikes likes;
  late _MockTags tags;
  late _MockFiles files;
  late _MockPublish publish;
  late _MockChanges changes;
  late PostRepository repo;

  setUpAll(() {
    registerFallbackValue(CommentSort.relevant);
    registerFallbackValue(DateTime.utc(2026));
    registerFallbackValue(File(''));
    registerFallbackValue(ContentKind.post);
    registerFallbackValue(ContentAudience.public);
  });

  setUp(() {
    posts = _MockPosts();
    actions = _MockActions();
    comments = _MockComments();
    likes = _MockLikes();
    tags = _MockTags();
    files = _MockFiles();
    publish = _MockPublish();
    changes = _MockChanges();
    repo = PostRepositoryImpl(
      posts,
      actions,
      comments,
      CommentsLocalDatasource(MemorySnapshotStorage()),
      likes,
      tags,
      files,
      ContentMediaRepository(files, _MockThumbnails(), _MockCompressor()),
      publish,
      changes,
    );
  });

  CommentModel model(String id) => CommentModel(
    id: id,
    postId: 'p1',
    authorId: 'u1',
    username: 'sara',
    body: 'hello',
    createdAt: DateTime.utc(2026, 10, 25),
  );

  test('comments asks for a page and passes the cursor', () async {
    final cursor = CommentCursorEntity(
      rank: 1,
      createdAt: DateTime.utc(2026, 10, 25),
      id: 'c0',
    );
    when(
      () => comments.getComments(
        any(),
        sort: any(named: 'sort'),
        limit: any(named: 'limit'),
        beforeRank: any(named: 'beforeRank'),
        beforeCreated: any(named: 'beforeCreated'),
        beforeId: any(named: 'beforeId'),
        focusCommentId: any(named: 'focusCommentId'),
      ),
    ).thenAnswer((_) async => CommentPageModel(comments: [model('c1')]));

    final page = await repo.comments(
      'p1',
      sort: CommentSort.newest,
      before: cursor,
      focusCommentId: 'c9',
    );

    expect(page.comments.single.id, 'c1');
    verify(
      () => comments.getComments(
        'p1',
        sort: CommentSort.newest,
        limit: PostRepository.commentsPageSize,
        beforeRank: 1,
        beforeCreated: DateTime.utc(2026, 10, 25),
        beforeId: 'c0',
        focusCommentId: 'c9',
      ),
    ).called(1);
  });

  test('replies continues after the last reply', () async {
    final last = model('r1').createdAt;
    when(
      () => comments.getReplies(
        any(),
        limit: any(named: 'limit'),
        afterCreated: any(named: 'afterCreated'),
        afterId: any(named: 'afterId'),
      ),
    ).thenAnswer((_) async => [model('r2')]);

    final replies = await repo.replies('c1', after: _entity('r1'));

    expect(replies.single.id, 'r2');
    verify(
      () => comments.getReplies(
        'c1',
        limit: PostRepository.repliesPageSize,
        afterCreated: last,
        afterId: 'r1',
      ),
    ).called(1);
  });

  test('addComment returns the comment as written', () async {
    when(
      () => comments.addComment(
        any(),
        any(),
        parentId: any(named: 'parentId'),
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => model('c1'));

    final comment = await repo.addComment(
      'p1',
      'hello',
      parentId: 'c0',
      clientId: 'k1',
    );

    expect(comment.id, 'c1');
    verify(
      () => comments.addComment('p1', 'hello', parentId: 'c0', clientId: 'k1'),
    ).called(1);
  });

  test('addComment fails on an answer it cannot read', () async {
    when(
      () => comments.addComment(
        any(),
        any(),
        parentId: any(named: 'parentId'),
        clientId: any(named: 'clientId'),
      ),
    ).thenAnswer((_) async => const CommentModel());

    await expectLater(
      repo.addComment('p1', 'hello', clientId: 'k1'),
      throwsA(const ParseFailure()),
    );
  });

  test('editComment returns the comment as saved', () async {
    when(() => comments.editComment('c1', 'new'))
        .thenAnswer((_) async => model('c1'));

    final comment = await repo.editComment('c1', 'new');

    expect(comment.id, 'c1');
  });

  test('mentionCandidates leaves out rows without a username', () async {
    when(() => comments.getMentionCandidates('p1', 'sa')).thenAnswer(
      (_) async => const [
        MentionPersonModel(id: 'u1', username: 'sara'),
        MentionPersonModel(id: 'u2'),
      ],
    );

    final people = await repo.mentionCandidates('p1', 'sa');

    expect(people.map((p) => p.username), ['sara']);
  });

  group('deletePost', () {
    setUp(() {
      when(() => files.listFolder('p1'))
          .thenAnswer((_) async => ['u/p1/0.jpg']);
      when(() => files.remove(any())).thenAnswer((_) async {});
      when(() => changes.check(any())).thenAnswer((_) async {});
    });

    test('lists the files, deletes the row, removes the files, then checks changes', () async {
      when(() => actions.deletePost('p1')).thenAnswer((_) async {});

      await repo.deletePost('p1');

      verifyInOrder([
        () => files.listFolder('p1'),
        () => actions.deletePost('p1'),
        () => files.remove(['u/p1/0.jpg']),
        () => changes.check(ContentKind.post),
      ]);
    });

    test('a failed row delete keeps the files', () async {
      when(() => actions.deletePost('p1')).thenThrow(const NetworkFailure());

      await expectLater(repo.deletePost('p1'), throwsA(const NetworkFailure()));

      verifyNever(() => files.remove(any()));
    });
  });

  test('search maps the people and leaves out a row without a name', () async {
    when(() => tags.searchPeople('sa')).thenAnswer(
      (_) async => const [
        TagPersonModel(id: 'u2', username: 'sara', canTag: true),
        TagPersonModel(id: 'u3', username: 'omar'),
        TagPersonModel(username: 'no-id', canTag: true),
        TagPersonModel(id: 'u5', canTag: true),
      ],
    );

    final people = await repo.searchTagPeople('sa');

    expect(people.map((p) => p.id), ['u2', 'u3']);
    expect(people.map((p) => p.canTag), [true, false]);
  });

  test('a search with no text asks for the suggested people', () async {
    when(() => tags.searchPeople(null)).thenAnswer((_) async => const []);

    await repo.searchTagPeople();

    verify(() => tags.searchPeople(null)).called(1);
  });

  test('tagged people default an unknown follow state to none', () async {
    when(() => tags.getTaggedPeople('p1')).thenAnswer(
      (_) async => const [
        TaggedPersonModel(
          id: 'u2',
          username: 'sara',
          followState: FollowState.following,
        ),
        TaggedPersonModel(id: 'u3', username: 'omar'),
        TaggedPersonModel(id: 'u4'),
      ],
    );

    final people = await repo.taggedPeople('p1');

    expect(people.map((p) => p.followState), [
      FollowState.following,
      FollowState.none,
    ]);
  });

  test('remove my tag hands back what the server said', () async {
    when(() => tags.removeMyTag('p1')).thenAnswer((_) async => true);
    when(() => tags.removeMyTag('p2')).thenAnswer((_) async => false);

    expect(await repo.removeMyTag('p1'), isTrue);
    expect(await repo.removeMyTag('p2'), isFalse);
  });

  test(
    'likedByPreviews maps the rows and drops one without a username',
    () async {
      when(() => likes.getPreviews(['p1', 'p2'])).thenAnswer(
        (_) async => {
          'p1': const LikedByPreviewModel(
            postId: 'p1',
            firstUsername: 'salma.ash',
            others: 3,
          ),
          'p2': const LikedByPreviewModel(postId: 'p2', others: 1),
        },
      );

      final previews = await repo.likedByPreviews(['p1', 'p2']);

      expect(previews.keys, ['p1']);
    },
  );

  group('shareToFeed', () {
    late PublishWork work;

    setUp(() {
      when(() => changes.check(any())).thenAnswer((_) async {});
      when(
        () => publish.enqueue(
          kind: any(named: 'kind'),
          send: any(named: 'send'),
        ),
      ).thenAnswer((call) {
        work = call.namedArguments[#send] as PublishWork;
        return true;
      });
    });

    void answer() => when(
      () => posts.shareToFeed(
        postId: any(named: 'postId'),
        caption: any(named: 'caption'),
        audience: any(named: 'audience'),
        moodKind: any(named: 'moodKind'),
        moodKey: any(named: 'moodKey'),
        moodText: any(named: 'moodText'),
        location: any(named: 'location'),
        tags: any(named: 'tags'),
      ),
    ).thenAnswer((_) async => 'new-1');

    test('goes out in the post line, and false means the line is full', () {
      expect(repo.shareToFeed('o1'), isTrue);
      verify(
        () => publish.enqueue(
          kind: ContentKind.post,
          send: any(named: 'send'),
        ),
      ).called(1);

      when(
        () => publish.enqueue(
          kind: any(named: 'kind'),
          send: any(named: 'send'),
        ),
      ).thenReturn(false);
      expect(repo.shareToFeed('o1'), isFalse);
    });

    test(
      'sends the words, feeling, place and tags without a photo spot',
      () async {
        answer();

        repo.shareToFeed(
          'o1',
          caption: 'Look',
          audience: ContentAudience.followers,
          mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
          location: 'Cairo',
          tags: const [
            PostTagEntity(userId: 'u2', mediaPosition: 1, x: 0.5, y: 0.5),
          ],
        );
        await work((_) {});

        verify(
          () => posts.shareToFeed(
            postId: 'o1',
            caption: 'Look',
            audience: ContentAudience.followers,
            moodKind: MoodKind.feeling,
            moodKey: 'happy',
            moodText: null,
            location: 'Cairo',
            tags: const [PostTagModel(userId: 'u2')],
          ),
        ).called(1);
      },
    );

    test('runs the change check once the share exists', () async {
      answer();

      repo.shareToFeed('o1');
      await work((_) {});

      verify(() => changes.check(ContentKind.post)).called(1);
    });

    test('a failed share runs no check and passes the failure on', () async {
      when(
        () => posts.shareToFeed(
          postId: any(named: 'postId'),
          caption: any(named: 'caption'),
          audience: any(named: 'audience'),
          moodKind: any(named: 'moodKind'),
          moodKey: any(named: 'moodKey'),
          moodText: any(named: 'moodText'),
          location: any(named: 'location'),
          tags: any(named: 'tags'),
        ),
      ).thenThrow(StateError('offline'));

      repo.shareToFeed('o1');
      await expectLater(work((_) {}), throwsStateError);

      verifyNever(() => changes.check(any()));
    });
  });

  group('updatePost', () {
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
    const photo = NewPostMediaEntity(
      filePath: '/tmp/new.jpg',
      isVideo: false,
      width: 20,
      height: 20,
    );
    const video = NewPostMediaEntity(
      filePath: '/tmp/new.mp4',
      thumbFilePath: '/tmp/new_thumb.jpg',
      isVideo: true,
      width: 20,
      height: 20,
      durationMs: 1000,
    );

    final now = DateTime.utc(2026, 10, 27);
    final stem = 'u1/p1/e${now.microsecondsSinceEpoch}_';

    const edited = EditPostEntity(
      id: 'p1',
      caption: 'New',
      kept: [old0],
      added: [photo],
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

    /// The post as the server has it after the edit.
    PostModel serverPost({List<PostMediaModel>? media}) => PostModel(
      id: 'p1',
      authorId: 'u1',
      username: 'omar',
      caption: 'From the server',
      createdAt: DateTime(2026),
      tagCount: 1,
      media: media,
    );

    Future<T> atNow<T>(Future<T> Function() body) =>
        withClock(Clock.fixed(now), body);

    Future<PostEntity?> update(EditPostEntity post) =>
        atNow(() => repo.updatePost(post, before: before));

    /// Every file uploaded in this try, in order.
    List<String> uploaded() => verify(
      () => files.upload(
        path: captureAny(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
      ),
    ).captured.cast<String>();

    void saveAnswers() => when(
      () => posts.updatePost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        media: any(named: 'media'),
        moodKind: any(named: 'moodKind'),
        moodKey: any(named: 'moodKey'),
        moodText: any(named: 'moodText'),
        tags: any(named: 'tags'),
        commentsEnabled: any(named: 'commentsEnabled'),
        audience: any(named: 'audience'),
      ),
    ).thenAnswer((_) async {});

    void saveFails() => when(
      () => posts.updatePost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        media: any(named: 'media'),
        moodKind: any(named: 'moodKind'),
        moodKey: any(named: 'moodKey'),
        moodText: any(named: 'moodText'),
        tags: any(named: 'tags'),
        commentsEnabled: any(named: 'commentsEnabled'),
        audience: any(named: 'audience'),
      ),
    ).thenThrow(const NetworkFailure());

    setUp(() {
      when(() => posts.currentUserId).thenReturn('u1');
      when(
        () => files.upload(
          path: any(named: 'path'),
          file: any(named: 'file'),
          contentType: any(named: 'contentType'),
          onBytes: any(named: 'onBytes'),
        ),
      ).thenAnswer((_) async {});
      when(() => files.remove(any())).thenAnswer((_) async {});
      // The folder holds the old media, a file of an earlier edit and, once uploaded, this try's files.
      when(() => files.listFiles('u1/p1')).thenAnswer(
        (_) async => [
          '0.jpg',
          '1.jpg',
          'e1_0.jpg',
          'e${now.microsecondsSinceEpoch}_0.jpg',
          'e${now.microsecondsSinceEpoch}_0.mp4',
          'e${now.microsecondsSinceEpoch}_0_thumb.jpg',
        ],
      );
      when(() => posts.getPost('p1')).thenAnswer((_) async => serverPost());
      saveAnswers();
    });

    test(
      'saves the kept media then the added one, removes the dropped file and '
      'returns the post as the server has it',
      () async {
        final saved = await update(edited);

        final media =
            verify(
                  () => posts.updatePost(
                    id: 'p1',
                    caption: 'New',
                    location: null,
                    media: captureAny(named: 'media'),
                    commentsEnabled: null,
                    audience: null,
                  ),
                ).captured.single
                as List<PostMediaModel>;
        expect(media.map((m) => m.path).first, 'u1/p1/0.jpg');
        expect(media.last.path, startsWith(stem));
        verify(() => files.remove(['u1/p1/1.jpg'])).called(1);
        expect(saved?.caption, 'From the server');
        expect(saved?.tagCount, 1);
      },
    );

    test('sends the mood and the tags', () async {
      const withMood = EditPostEntity(
        id: 'p1',
        caption: 'New',
        kept: [old0],
        added: [],
        commentsEnabled: true,
        visibility: ContentAudience.public,
        mood: PostMoodEntity(
          kind: MoodKind.activity,
          key: 'watching',
          text: 'a film',
        ),
        tags: [PostTagEntity(userId: 'u2', username: 'sara')],
      );

      await update(withMood);

      verify(
        () => posts.updatePost(
          id: 'p1',
          caption: 'New',
          location: null,
          media: any(named: 'media'),
          moodKind: MoodKind.activity,
          moodKey: 'watching',
          moodText: 'a film',
          tags: const [PostTagModel(userId: 'u2')],
          commentsEnabled: null,
          audience: null,
        ),
      ).called(1);
    });

    group('settings', () {
      test('a changed comments switch and audience go in the same call as the '
          'edit, with no separate request', () async {
        await update(
          const EditPostEntity(
            id: 'p1',
            kept: [old0, old1],
            added: [],
            commentsEnabled: false,
            visibility: ContentAudience.followers,
          ),
        );

        verify(
          () => posts.updatePost(
            id: 'p1',
            caption: null,
            location: null,
            media: any(named: 'media'),
            commentsEnabled: false,
            audience: ContentAudience.followers,
          ),
        ).called(1);
        verifyNever(
          () =>
              actions.setCommentsEnabled(any(), enabled: any(named: 'enabled')),
        );
        verifyZeroInteractions(publish);
      });

      test('settings that did not change are not sent', () async {
        await update(edited);

        verify(
          () => posts.updatePost(
            id: 'p1',
            caption: 'New',
            location: null,
            media: any(named: 'media'),
            commentsEnabled: null,
            audience: null,
          ),
        ).called(1);
      });

      test('a failed save changes no setting', () async {
        saveFails();

        await expectLater(
          update(
            const EditPostEntity(
              id: 'p1',
              kept: [old0, old1],
              added: [],
              commentsEnabled: false,
              visibility: ContentAudience.followers,
            ),
          ),
          throwsA(isA<NetworkFailure>()),
        );

        verifyNever(
          () =>
              actions.setCommentsEnabled(any(), enabled: any(named: 'enabled')),
        );
      });
    });

    group('an upload fails', () {
      test('the files this try already sent are removed, nothing else, and the '
          'post is not saved', () async {
        const two = EditPostEntity(
          id: 'p1',
          caption: 'New',
          kept: [old0],
          added: [photo, photo],
          commentsEnabled: true,
          visibility: ContentAudience.public,
        );
        var uploads = 0;
        when(
          () => files.upload(
            path: any(named: 'path'),
            file: any(named: 'file'),
            contentType: any(named: 'contentType'),
            onBytes: any(named: 'onBytes'),
          ),
        ).thenAnswer((_) async {
          if (++uploads == 2) throw const NetworkFailure();
        });

        await expectLater(update(two), throwsA(isA<NetworkFailure>()));

        verify(
          () => files.remove([
            '${stem}0.jpg',
            '${stem}0.mp4',
            '${stem}0_thumb.jpg',
          ]),
        ).called(1);
        verifyNever(() => files.remove(['u1/p1/0.jpg']));
        verifyNever(
          () => posts.updatePost(
            id: any(named: 'id'),
            caption: any(named: 'caption'),
            location: any(named: 'location'),
            media: any(named: 'media'),
            commentsEnabled: any(named: 'commentsEnabled'),
            audience: any(named: 'audience'),
          ),
        );
      });

      test('a video whose thumbnail fails leaves no file behind, and the old '
          'media stays', () async {
        const withVideo = EditPostEntity(
          id: 'p1',
          kept: [old0, old1],
          added: [video],
          commentsEnabled: true,
          visibility: ContentAudience.public,
        );
        when(
          () => files.upload(
            path: any(named: 'path'),
            file: any(named: 'file'),
            contentType: any(named: 'contentType'),
            onBytes: any(named: 'onBytes'),
          ),
        ).thenAnswer((call) async {
          final path = call.namedArguments[#path] as String;
          if (path.endsWith('_thumb.jpg')) throw const NetworkFailure();
        });

        await expectLater(update(withVideo), throwsA(isA<NetworkFailure>()));

        expect(uploaded(), ['${stem}0.mp4', '${stem}0_thumb.jpg']);
        final removed =
            verify(() => files.remove(captureAny())).captured.single
                as List<String>;
        expect(removed, everyElement(startsWith(stem)));
        expect(removed, contains('${stem}0.mp4'));
      });

      test(
        'a cleanup that fails does not hide why the upload failed',
        () async {
          when(() => files.listFiles('u1/p1'))
              .thenThrow(const NetworkFailure());
          when(
            () => files.upload(
              path: any(named: 'path'),
              file: any(named: 'file'),
              contentType: any(named: 'contentType'),
              onBytes: any(named: 'onBytes'),
            ),
          ).thenThrow(const ServerFailure(statusCode: 413));

          await expectLater(
            update(edited),
            throwsA(const ServerFailure(statusCode: 413)),
          );
        },
      );
    });

    group('the save fails', () {
      setUp(saveFails);

      test('the server does not use the new files: they are removed, the old '
          'ones stay, and the failure is thrown', () async {
        when(() => posts.getPost('p1')).thenAnswer(
          (_) async =>
              serverPost(media: const [PostMediaModel(path: 'u1/p1/0.jpg')]),
        );

        await expectLater(update(edited), throwsA(isA<NetworkFailure>()));

        verify(
          () => files.remove([
            '${stem}0.jpg',
            '${stem}0.mp4',
            '${stem}0_thumb.jpg',
          ]),
        ).called(1);
        verifyNever(() => files.remove(['u1/p1/1.jpg']));
      });

      test('the server already uses the new files (only the answer was lost): '
          'nothing is removed', () async {
        when(() => posts.getPost('p1')).thenAnswer(
          (_) async => serverPost(
            media: [
              PostMediaModel(
                type: MediaType.image,
                path: '${stem}0.jpg',
                width: 20,
                height: 20,
              ),
            ],
          ),
        );

        await expectLater(update(edited), throwsA(isA<NetworkFailure>()));

        verifyNever(() => files.remove(any()));
      });

      test('the server cannot be asked: nothing is removed', () async {
        when(() => posts.getPost('p1')).thenThrow(const NetworkFailure());

        await expectLater(update(edited), throwsA(isA<NetworkFailure>()));

        verifyNever(() => files.remove(any()));
      });
    });

    group('the save worked', () {
      test('a failed read-back is not a failed edit: no throw, no second try, '
          'and the dropped file is still removed', () async {
        when(() => posts.getPost('p1')).thenThrow(const NetworkFailure());

        final saved = await update(edited);

        expect(saved, isNull);
        expect(uploaded(), hasLength(1));
        verify(() => files.remove(['u1/p1/1.jpg'])).called(1);
        verify(
          () => posts.updatePost(
            id: 'p1',
            caption: any(named: 'caption'),
            location: any(named: 'location'),
            media: any(named: 'media'),
            commentsEnabled: any(named: 'commentsEnabled'),
            audience: any(named: 'audience'),
          ),
        ).called(1);
      });

      test(
        'a read-back that breaks in any way is still not a failed edit',
        () async {
          when(() => posts.getPost('p1')).thenThrow(StateError('odd row'));

          expect(await update(edited), isNull);
        },
      );

      test('a post the server no longer shows comes back as null', () async {
        when(() => posts.getPost('p1')).thenAnswer((_) async => null);

        expect(await update(edited), isNull);
      });
    });
  });
}

CommentEntity _entity(String id) => CommentEntity(
  id: id,
  postId: 'p1',
  authorId: 'u1',
  username: 'sara',
  body: 'hello',
  createdAt: DateTime.utc(2026, 10, 25),
  likeCount: 0,
  likedByMe: false,
  isPostAuthor: false,
  replyCount: 0,
);
