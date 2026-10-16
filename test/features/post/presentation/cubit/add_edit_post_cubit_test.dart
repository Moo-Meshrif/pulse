import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/edit_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';
import 'package:pulse/features/post/domain/event/post_saved.dart';
import 'package:pulse/features/post/domain/use_case/create_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/domain/use_case/update_post_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/add_edit_post_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/new_post_notice.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/publish_content_use_case.dart';

class _CreatePost extends Mock implements CreatePostUseCase {}

class _UpdatePost extends Mock implements UpdatePostUseCase {}

class _SignUrls extends Mock implements SignPostMediaUrlsUseCase {}

class _Picker extends Mock implements MediaPickerService {}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Thumbnails extends Mock implements VideoThumbnailService {}

class _Account extends Mock implements GetLastAccountUseCase {}

PickedMedia photo([String path = '/p.jpg']) =>
    PickedMedia(path: path, isVideo: false, width: 800, height: 600);

PickedMedia video({int durationMs = 30000, int sizeBytes = 1000}) =>
    PickedMedia(
      path: '/v.mp4',
      isVideo: true,
      durationMs: durationMs,
      sizeBytes: sizeBytes,
      width: 1080,
      height: 1920,
    );

void main() {
  late _CreatePost createPost;
  late _UpdatePost updatePost;
  late _SignUrls signUrls;
  late _Picker picker;
  late _Privacy privacy;
  late _Thumbnails thumbnails;
  late _Account account;
  late ContentPublishRepositoryImpl publish;
  late EventBus bus;

  setUpAll(() {
    registerFallbackValue(const PickedMedia(path: '/x', isVideo: false));
    registerFallbackValue(
      const NewPostEntity(
        id: 'x',
        commentsEnabled: true,
        visibility: ContentAudience.public,
        media: [],
      ),
    );
  });

  setUp(() {
    createPost = _CreatePost();
    updatePost = _UpdatePost();
    signUrls = _SignUrls();
    picker = _Picker();
    privacy = _Privacy();
    thumbnails = _Thumbnails();
    account = _Account();
    bus = EventBus();
    publish = ContentPublishRepositoryImpl(bus);
    when(account.call).thenReturn(null);
    when(() => picker.describe(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as PickedMedia,
    );
    when(() => createPost(any(), onProgress: any(named: 'onProgress')))
        .thenAnswer((_) async => null);
    when(() => thumbnails.thumbnail(any())).thenAnswer((_) async => '/t.jpg');
  });

  AddEditPostCubit build([PostEntity? post]) => AddEditPostCubit(
    createPost,
    updatePost,
    PublishContentUseCase(publish),
    bus,
    signUrls,
    picker,
    privacy,
    thumbnails,
    account,
    post,
  );

  group('Share is enabled', () {
    test('not when empty', () {
      expect(build().state.canSave, isFalse);
    });

    test('with text', () {
      final cubit = build()..captionChanged('hello');
      expect(cubit.state.canSave, isTrue);
    });

    test('not with only spaces', () {
      final cubit = build()..captionChanged('   ');
      expect(cubit.state.canSave, isFalse);
    });

    test('with one photo and no text', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo()]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.canSave, isTrue);
    });
  });

  group('picking media', () {
    test('asks only for the slots left', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg'), photo('/b.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      await cubit.pickMedia();
      await pumpEventQueue();
      verify(() => picker.pickMany(limit: 10)).called(1);
      verify(() => picker.pickMany(limit: 8)).called(1);
      expect(cubit.state.media, hasLength(4));
    });

    test('the files are on the strip before they are read', () async {
      final read = Completer<PickedMedia>();
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [const PickedMedia(path: '/p.jpg', isVideo: false)],
      );
      when(() => picker.describe(any())).thenAnswer((_) => read.future);
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.media.single.width, isNull);
      expect(cubit.state.canSave, isTrue);

      read.complete(
        PickedMedia(path: '/p.jpg', isVideo: false, width: 800, height: 600),
      );
      await pumpEventQueue();
      expect(cubit.state.media.single.width, 800);
    });

    test('sharing waits for the files that are still being read', () async {
      final read = Completer<PickedMedia>();
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [const PickedMedia(path: '/p.jpg', isVideo: false)],
      );
      when(() => picker.describe(any())).thenAnswer((_) => read.future);
      final cubit = build();
      await cubit.pickMedia();
      cubit.save();
      expect(cubit.state.isSaved, isTrue);
      await pumpEventQueue();
      verifyNever(
        () => createPost(any(), onProgress: any(named: 'onProgress')),
      );

      read.complete(
        PickedMedia(path: '/p.jpg', isVideo: false, width: 800, height: 600),
      );
      await pumpEventQueue();
      final sent =
          verify(
                () => createPost(
                  captureAny(),
                  onProgress: any(named: 'onProgress'),
                ),
              ).captured.single
              as NewPostEntity;
      expect(sent.media.single.width, 800);
    });

    test('a full post asks for nothing and says so', () async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          for (var i = 0; i < NewPostLimits.maxMedia; i++) photo('/$i.jpg'),
        ],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.canAddMedia, isFalse);

      await cubit.pickMedia();

      await pumpEventQueue();
      verify(() => picker.pickMany(limit: any(named: 'limit'))).called(1);
      expect(cubit.state.notice, NewPostNotice.mediaLimit);
    });

    test('a video over 10 minutes is rejected, the photo stays', () async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [photo(), video(durationMs: 10 * 60 * 1000 + 1)],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media.map((m) => m.path), ['/p.jpg']);
      expect(cubit.state.notice, NewPostNotice.videoTooLong);
    });

    test('exactly 10 minutes and 50 MB are allowed', () async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          video(durationMs: 10 * 60 * 1000, sizeBytes: 50 * 1024 * 1024),
        ],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media, hasLength(1));
      expect(cubit.state.notice, isNull);
    });

    test('a video over 50 MB is kept: it is shrunk when sent', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [video(sizeBytes: 50 * 1024 * 1024 + 1)]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media, hasLength(1));
      expect(cubit.state.notice, isNull);
    });

    test('a video too long to shrink under 50 MB is rejected', () async {
      // 6 minutes and 200 MB: under 1.2 Mbps after shrinking.
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          video(durationMs: 6 * 60 * 1000, sizeBytes: 200 * 1024 * 1024),
        ],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media, isEmpty);
      expect(cubit.state.notice, NewPostNotice.videoTooLong);
    });

    test('a video gets a poster; a failing poster is skipped', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [video()]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.posters, {'/v.mp4': '/t.jpg'});

      when(() => thumbnails.thumbnail(any()))
          .thenThrow(const UnexpectedFailure());
      final other = build();
      await other.pickMedia();
      await pumpEventQueue();
      expect(other.state.media, hasLength(1));
      expect(other.state.posters, isEmpty);
    });

    test('cancelling changes nothing', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      final cubit = build();
      final before = cubit.state;
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state, before);
    });

    test('removing drops that one', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg'), photo('/b.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      cubit.removeMedia(0);
      expect(cubit.state.media.map((m) => m.path), ['/b.jpg']);
    });
  });

  group('sharing', () {
    test('sends the trimmed caption, switch, place and audience', () async {
      final cubit = build()
        ..captionChanged('  hello  ')
        ..commentsChanged(false)
        ..locationChanged('Kolkata');
      cubit.save();
      await pumpEventQueue();

      final sent =
          verify(
                () => createPost(
                  captureAny(),
                  onProgress: any(named: 'onProgress'),
                ),
              ).captured.single
              as NewPostEntity;
      expect(sent.id, cubit.state.postId);
      expect(sent.caption, 'hello');
      expect(sent.commentsEnabled, isFalse);
      expect(sent.location, 'Kolkata');
      expect(sent.visibility, ContentAudience.public);
      expect(cubit.state.isSaved, isTrue);
    });

    test('closes at once, before the post is sent', () {
      final done = Completer<PostEntity?>();
      when(() => createPost(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) => done.future);
      final cubit = build()..captionChanged('hello');
      cubit.save();
      expect(cubit.state.isSaved, isTrue);
      done.complete(null);
    });

    test(
      'a failure is kept by the sender, then Retry sends the same id',
      () async {
        when(() => createPost(any(), onProgress: any(named: 'onProgress')))
            .thenThrow(const UnexpectedFailure());
        final cubit = build()..captionChanged('hello');
        cubit.save();
        await pumpEventQueue();
        expect(cubit.state.isSaved, isTrue);
        expect(publish.current(ContentKind.post), isA<ContentPublishFailed>());

        when(() => createPost(any(), onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async => null);
        publish.retry(ContentKind.post);
        await pumpEventQueue();
        final ids = verify(
          () => createPost(captureAny(), onProgress: any(named: 'onProgress')),
        ).captured.cast<NewPostEntity>().map((p) => p.id).toSet();
        expect(ids, {cubit.state.postId});
        expect(publish.current(ContentKind.post), isA<ContentPublishIdle>());
      },
    );

    test('another post is refused while one is waiting for Retry', () async {
      when(() => createPost(any(), onProgress: any(named: 'onProgress')))
          .thenThrow(const UnexpectedFailure());
      build()
        ..captionChanged('first')
        ..save();
      await pumpEventQueue();

      final second = build()..captionChanged('second');
      second.save();
      expect(second.state.isSaved, isFalse);
      expect(second.state.notice, NewPostNotice.publishBusy);
    });

    test('tells the feed to load again when the author is unknown', () async {
      final events = <Object>[];
      bus.on<FeedRefreshRequested>().listen(events.add);
      build()
        ..captionChanged('hello')
        ..save();
      await pumpEventQueue();
      expect(events, [const FeedRefreshRequested()]);
    });

    test('an empty post is not sent', () async {
      build().save();
      await pumpEventQueue();
      verifyNever(
        () => createPost(any(), onProgress: any(named: 'onProgress')),
      );
    });
  });

  group('closing', () {
    test('an empty post needs no confirmation', () {
      expect(build().state.hasContent, isFalse);
    });

    test('text, a photo or a place counts as content', () async {
      expect((build()..captionChanged('a')).state.hasContent, isTrue);
      expect((build()..locationChanged('Kolkata')).state.hasContent, isTrue);
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo()]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.hasContent, isTrue);
    });
  });

  group('audience', () {
    test('starts from the account default', () async {
      when(() => privacy()).thenAnswer(
        (_) async => const PrivacyEntity(
          isPrivate: true,
          defaultVisibility: ContentAudience.followers,
        ),
      );
      final cubit = build();
      await cubit.loadDefaultVisibility();
      expect(cubit.state.visibility, ContentAudience.followers);
    });

    test(
      'a narrower choice than the default is narrowed on the chip',
      () async {
        final cubit = build();
        expect(cubit.state.isVisibilityNarrowed, isFalse);
        cubit.audienceChosen(
          const PostVisibilityResult(audience: ContentAudience.onlyMe),
        );
        expect(cubit.state.visibility, ContentAudience.onlyMe);
        expect(cubit.state.isVisibilityNarrowed, isTrue);
      },
    );

    test('a choice saved as the default is no longer narrowed', () async {
      final cubit = build()
        ..audienceChosen(
          const PostVisibilityResult(
            audience: ContentAudience.closeFriends,
            savedAsDefault: true,
          ),
        );
      expect(cubit.state.defaultVisibility, ContentAudience.closeFriends);
      expect(cubit.state.isVisibilityNarrowed, isFalse);
    });

    test('stays Public when the default cannot be read', () async {
      when(() => privacy()).thenThrow(const UnexpectedFailure());
      final cubit = build();
      await cubit.loadDefaultVisibility();
      expect(cubit.state.visibility, ContentAudience.public);
    });
  });

  group('editing a post', () {
    const m0 = PostMediaEntity(
      isVideo: false,
      path: 'u/p/0.jpg',
      width: 1,
      height: 1,
    );
    const m1 = PostMediaEntity(
      isVideo: false,
      path: 'u/p/1.jpg',
      width: 1,
      height: 1,
    );
    final post = PostEntity(
      id: 'p',
      authorId: 'u',
      username: 'omar',
      caption: 'Hello',
      location: 'Cairo',
      likeCount: 0,
      commentCount: 0,
      commentsEnabled: true,
      visibility: ContentAudience.public,
      createdAt: DateTime(2026),
      likedByMe: false,
      savedByMe: false,
      media: const [m0, m1],
    );

    setUp(() {
      registerFallbackValue(
        const EditPostEntity(
          id: 'x',
          kept: [],
          added: [],
          commentsEnabled: true,
          visibility: ContentAudience.public,
        ),
      );
      registerFallbackValue(post);
      when(
        () => updatePost(
          any(),
          before: any(named: 'before'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => post);
      when(() => signUrls(any())).thenAnswer((_) async => {'u/p/0.jpg': 'u0'});
      when(privacy.call).thenAnswer(
        (_) async => const PrivacyEntity(
          isPrivate: false,
          defaultVisibility: ContentAudience.followers,
        ),
      );
    });

    test('starts from the post and cannot save until something changes', () {
      final cubit = build(post);
      expect(cubit.state.caption, 'Hello');
      expect(cubit.state.kept, [m0, m1]);
      expect(cubit.state.canSave, isFalse);
      expect(cubit.state.hasContent, isFalse);
    });

    test(
      'the account default audience does not replace the post\'s own',
      () async {
        final cubit = build(post);
        await cubit.loadDefaultVisibility();
        expect(cubit.state.visibility, ContentAudience.public);
        expect(cubit.state.defaultVisibility, ContentAudience.followers);
      },
    );

    test(
      'the comments switch, audience, and removing media count as changes',
      () {
        expect((build(post)..commentsChanged(false)).state.canSave, isTrue);
        expect((build(post)..removeMedia(0)).state.kept, [m1]);
        expect((build(post)..removeMedia(0)).state.canSave, isTrue);
      },
    );

    test('an emptied post cannot be saved', () {
      final cubit = build(post)
        ..captionChanged('')
        ..removeMedia(0)
        ..removeMedia(0);
      expect(cubit.state.canSave, isFalse);
    });

    test('loads signed links for the post\'s media', () async {
      final cubit = build(post);
      await cubit.loadUrls();
      expect(cubit.state.urls, {'u/p/0.jpg': 'u0'});
    });

    test('a saved edit is sent to the feed as it is now', () async {
      final events = <PostSaved>[];
      bus.on<PostSaved>().listen(events.add);
      build(post)
        ..captionChanged('Changed')
        ..save();
      await pumpEventQueue();
      expect(events, [PostSaved(post)]);
    });

    test('save updates the post, not creates it', () async {
      final cubit = build(post)..captionChanged('  Changed  ');
      cubit.save();
      await pumpEventQueue();
      final edited =
          verify(
                () => updatePost(
                  captureAny(),
                  before: post,
                  onProgress: any(named: 'onProgress'),
                ),
              ).captured.single
              as EditPostEntity;
      expect(edited.caption, 'Changed');
      expect(edited.kept, [m0, m1]);
      verifyNever(
        () => createPost(any(), onProgress: any(named: 'onProgress')),
      );
      expect(cubit.state.isSaved, isTrue);
    });
  });

  group('tags', () {
    const omar = TagChoice(id: 'u1', username: 'omar');
    const laila = TagChoice(id: 'u2', username: 'laila');

    Future<AddEditPostCubit> withPhotos(int count) async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [for (var i = 0; i < count; i++) photo('/p$i.jpg')],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      return cubit;
    }

    test('what is chosen is something to lose, and goes in the post', () async {
      when(() => createPost(any(), onProgress: any(named: 'onProgress')))
          .thenAnswer((_) async => null);
      final cubit = build()
        ..captionChanged('hi')
        ..tagsChanged([omar.withSpot(0, 0.5, 0.25), laila]);
      expect(cubit.state.hasContent, isTrue);

      cubit.save();
      await pumpEventQueue();

      final sent =
          verify(
                () => createPost(
                  captureAny(),
                  onProgress: any(named: 'onProgress'),
                ),
              ).captured.single
              as NewPostEntity;
      expect(sent.tags.map((t) => t.userId), ['u1', 'u2']);
      expect(sent.tags.first.mediaPosition, 0);
      expect(sent.tags.first.x, 0.5);
      expect(sent.tags.last.mediaPosition, isNull);
    });

    test(
      'the tag pages open with the chosen people and the media in order',
      () async {
        final cubit = await withPhotos(2);
        cubit.tagsChanged([omar]);

        final args = cubit.tagArgs;

        expect(args.chosen, [omar]);
        expect(args.photos.map((p) => p.position), [0, 1]);
        expect(args.photos.first.filePath, '/p0.jpg');
        expect(args.photos.first.aspect, closeTo(800 / 600, 0.001));
        expect(args.hasPhotos, isTrue);
      },
    );

    test(
      'removing a photo clears its spots and moves the later ones up',
      () async {
        final cubit = await withPhotos(3);
        cubit.tagsChanged([
          omar.withSpot(0, 0.1, 0.1),
          laila.withSpot(2, 0.9, 0.8),
          const TagChoice(id: 'u3', username: 'yousef'),
        ]);

        cubit.removeMedia(0);

        final tags = cubit.state.tags;
        expect(tags[0].hasSpot, isFalse);
        expect(tags[0].id, 'u1');
        expect(tags[1].mediaPosition, 1);
        expect(tags[1].x, 0.9);
        expect(tags[2].hasSpot, isFalse);
        expect(tags.length, 3);
      },
    );

    test('a tag on a photo before the removed one stays', () async {
      final cubit = await withPhotos(3);
      cubit.tagsChanged([omar.withSpot(0, 0.1, 0.1)]);

      cubit.removeMedia(2);

      expect(cubit.state.tags.single.mediaPosition, 0);
    });

    test('editing starts from the post\'s tags and knows when they change', () {
      final post = PostEntity(
        id: 'p1',
        authorId: 'u1',
        username: 'nour',
        caption: 'Hello',
        likeCount: 0,
        commentCount: 0,
        commentsEnabled: true,
        visibility: ContentAudience.public,
        createdAt: DateTime(2026),
        likedByMe: false,
        savedByMe: false,
        media: const [],
        tags: const [
          PostTagEntity(userId: 'u2', username: 'laila', fullName: 'Laila F'),
        ],
        tagCount: 1,
      );

      final cubit = build(post);

      expect(cubit.state.tags.single.id, 'u2');
      expect(cubit.state.tags.single.fullName, 'Laila F');
      expect(cubit.state.canSave, isFalse);

      cubit.tagsChanged([...cubit.state.tags, omar]);
      expect(cubit.state.hasChanges, isTrue);
      cubit.tagsChanged([TagChoice.tag(post.tags.single)]);
      expect(cubit.state.hasChanges, isFalse);
    });
  });

  group('feeling', () {
    const happy = PostMoodEntity(kind: MoodKind.feeling, key: 'happy');

    test(
      'a chosen feeling is something to lose, and goes in the post',
      () async {
        when(() => createPost(any(), onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async => null);
        final cubit = build()
          ..captionChanged('hi')
          ..moodChanged(happy);
        expect(cubit.state.hasContent, isTrue);

        cubit.save();
        await pumpEventQueue();

        final sent =
            verify(
                  () => createPost(
                    captureAny(),
                    onProgress: any(named: 'onProgress'),
                  ),
                ).captured.single
                as NewPostEntity;
        expect(sent.mood, happy);
      },
    );

    test('Remove clears it', () {
      final cubit = build()
        ..moodChanged(happy)
        ..moodChanged(null);
      expect(cubit.state.mood, isNull);
      expect(cubit.state.hasContent, isFalse);
    });

    test('editing starts from the post\'s feeling; changing or clearing is a change', () async {
      final post = PostEntity(
        id: 'p1',
        authorId: 'u1',
        username: 'nour',
        caption: 'Hello',
        likeCount: 0,
        commentCount: 0,
        commentsEnabled: true,
        visibility: ContentAudience.public,
        createdAt: DateTime(2026),
        likedByMe: false,
        savedByMe: false,
        media: const [],
        mood: happy,
      );
      registerFallbackValue(post);
      registerFallbackValue(
        const EditPostEntity(
          id: 'x',
          kept: [],
          added: [],
          commentsEnabled: true,
          visibility: ContentAudience.public,
        ),
      );
      when(
        () => updatePost(
          any(),
          before: any(named: 'before'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => post);
      final cubit = build(post);

      expect(cubit.state.mood, happy);
      expect(cubit.state.canSave, isFalse);

      cubit.moodChanged(
        const PostMoodEntity(kind: MoodKind.feeling, key: 'sad'),
      );
      expect(cubit.state.hasChanges, isTrue);
      cubit.moodChanged(null);
      expect(cubit.state.hasChanges, isTrue);

      cubit.save();
      await pumpEventQueue();
      final sent =
          verify(
                () => updatePost(
                  captureAny(),
                  before: any(named: 'before'),
                  onProgress: any(named: 'onProgress'),
                ),
              ).captured.single
              as EditPostEntity;
      expect(sent.mood, isNull);
    });
  });
}
