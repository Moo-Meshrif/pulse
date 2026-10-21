import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/events/event_bus.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/post_draft_media_model.dart';
import 'package:pulse/features/post/data/model/post_draft_model.dart';
import 'package:pulse/features/post/data/model/post_draft_tag_model.dart';
import 'package:pulse/features/post/data/repository/post_draft_repository.dart';
import 'package:pulse/features/post/data/repository/post_share_repository.dart';
import 'package:pulse/features/post/data/repository/shared_posts_repository.dart';
import 'package:pulse/features/post/domain/entity/edit_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/domain/event/feed_refresh_requested.dart';
import 'package:pulse/features/post/domain/event/post_saved.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/domain/use_case/update_post_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/add_edit_post/add_edit_post_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/new_post_notice.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/data/repository/content_media_repository.dart';
import 'package:pulse/shared/content/data/repository/content_publish_repository.dart';
import 'package:pulse/shared/content/data/repository/media_upload_queue.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/publish_content_use_case.dart';

import '../../../../../helpers/content_mocks.dart';
import '../../../../../helpers/pump_app.dart';

class _Share extends Mock implements PostShareRepository {}

class _UpdatePost extends Mock implements UpdatePostUseCase {}

class _SignUrls extends Mock implements SignPostMediaUrlsUseCase {}

class _Picker extends Mock implements MediaPickerService {}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Thumbnails extends Mock implements VideoThumbnailService {}

class _Account extends Mock implements GetLastAccountUseCase {}

class _MediaRepo extends Mock implements ContentMediaRepository {}

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
  late _Share share;
  late _UpdatePost updatePost;
  late _SignUrls signUrls;
  late _Picker picker;
  late _Privacy privacy;
  late _Thumbnails thumbnails;
  late _Account account;
  late ContentPublishRepositoryImpl publish;
  late EventBus bus;
  late MockPostDraftDatasource drafts;
  late MediaUploadQueue uploads;
  late MockPendingContentDatasource server;
  late FakeContentDiscards discards;

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
    share = _Share();
    updatePost = _UpdatePost();
    signUrls = _SignUrls();
    picker = _Picker();
    privacy = _Privacy();
    thumbnails = _Thumbnails();
    account = _Account();
    bus = EventBus();
    discards = FakeContentDiscards();
    publish = ContentPublishRepositoryImpl(bus, discards, FakeConnectivity());
    drafts = noPostDraft();
    uploads = idleUploads();
    server = serverDraftOk();
    when(account.call).thenReturn(null);
    when(() => picker.describe(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as PickedMedia,
    );
    // Like the real one: the uploads still going are waited for first.
    when(
      () => share.share(
        any(),
        beforeUpload: any(named: 'beforeUpload'),
        onProgress: any(named: 'onProgress'),
      ),
    ).thenAnswer((invocation) async {
      final beforeUpload =
          invocation.namedArguments[#beforeUpload] as Future<void> Function()?;
      await beforeUpload?.call();
      return null;
    });
    when(() => thumbnails.thumbnail(any())).thenAnswer((_) async => '/t.jpg');
  });

  //urls --> which passign from post card
  AddEditPostCubit build([PostEntity? post, Map<String, String>? urls]) =>
      AddEditPostCubit(
        updatePost,
        PublishContentUseCase(publish),
        bus,
        signUrls,
        picker,
        privacy,
        thumbnails,
        account,
        PostDraftRepository(
          drafts,
          uploads,
          server,
          SharedPostsRepository(drafts, server, share, publish, bus),
          discards,
        ),
        post,
        urls,
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
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      );

      read.complete(
        PickedMedia(path: '/p.jpg', isVideo: false, width: 800, height: 600),
      );
      await pumpEventQueue();
      final sent =
          verify(
                () => share.share(
                  captureAny(),
                  beforeUpload: any(named: 'beforeUpload'),
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
                () => share.share(
                  captureAny(),
                  beforeUpload: any(named: 'beforeUpload'),
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
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) => done.future);
      final cubit = build()..captionChanged('hello');
      cubit.save();
      expect(cubit.state.isSaved, isTrue);
      done.complete(null);
    });

    test(
      'a failure is kept by the sender, then Retry sends the same id',
      () async {
        when(
          () => share.share(
            any(),
            beforeUpload: any(named: 'beforeUpload'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenThrow(const UnexpectedFailure());
        final cubit = build()..captionChanged('hello');
        cubit.save();
        await pumpEventQueue();
        expect(cubit.state.isSaved, isTrue);
        expect(publish.current(ContentKind.post), isA<ContentPublishFailed>());

        when(
          () => share.share(
            any(),
            beforeUpload: any(named: 'beforeUpload'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => null);
        publish.retry(ContentKind.post);
        await pumpEventQueue();
        final ids = verify(
          () => share.share(
            captureAny(),
            beforeUpload: any(named: 'beforeUpload'),
            onProgress: any(named: 'onProgress'),
          ),
        ).captured.cast<NewPostEntity>().map((p) => p.id).toSet();
        expect(ids, {cubit.state.postId});
        expect(publish.current(ContentKind.post), isA<ContentPublishIdle>());
      },
    );

    test('a second tap while the screen closes sends nothing more', () async {
      final cubit = build()..captionChanged('hello');
      cubit
        ..save()
        ..save();
      await pumpEventQueue();
      verify(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).called(1);
      expect(cubit.state.notice, isNull);
    });

    test('Discard on Home after a failure discards it on the server', () async {
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const NetworkFailure());
      final cubit = build()..captionChanged('hello');
      cubit.save();
      await pumpEventQueue();

      publish.discard(ContentKind.post);
      await pumpEventQueue();
      expect(discards.saved, [cubit.state.postId]);
      expect(discards.sent, [cubit.state.postId]);
      verify(() => drafts.deleteFiles(cubit.state.postId)).called(1);
    });

    test('a 4th post is refused while 3 are waiting for Retry', () async {
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const UnexpectedFailure());
      for (final text in ['first', 'second', 'third']) {
        build()
          ..captionChanged(text)
          ..save();
        await pumpEventQueue();
      }

      final fourth = build()..captionChanged('fourth');
      fourth.save();
      expect(fourth.state.isSaved, isFalse);
      expect(fourth.state.notice, NewPostNotice.publishBusy);
    });

    test('does not ask the feed to load when the author is unknown', () async {
      final events = <Object>[];
      bus.on<FeedRefreshRequested>().listen(events.add);
      build()
        ..captionChanged('hello')
        ..save();
      await pumpEventQueue();
      expect(events, isEmpty);
    });

    test('an empty post is not sent', () async {
      build().save();
      await pumpEventQueue();
      verifyNever(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
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
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
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
      when(
        () => share.share(
          any(),
          beforeUpload: any(named: 'beforeUpload'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => null);
      final cubit = build()
        ..captionChanged('hi')
        ..tagsChanged([omar.withSpot(0, 0.5, 0.25), laila]);
      expect(cubit.state.hasContent, isTrue);

      cubit.save();
      await pumpEventQueue();

      final sent =
          verify(
                () => share.share(
                  captureAny(),
                  beforeUpload: any(named: 'beforeUpload'),
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
        when(
          () => share.share(
            any(),
            beforeUpload: any(named: 'beforeUpload'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => null);
        final cubit = build()
          ..captionChanged('hi')
          ..moodChanged(happy);
        expect(cubit.state.hasContent, isTrue);

        cubit.save();
        await pumpEventQueue();

        final sent =
            verify(
                  () => share.share(
                    captureAny(),
                    beforeUpload: any(named: 'beforeUpload'),
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

  group('the draft on the device', () {
    const savedDraft = PostDraftModel(
      id: 'draft-1',
      caption: 'half written',
      location: 'Riyadh',
      commentsEnabled: false,
      visibility: 'followers',
      moodKind: 'feeling',
      moodKey: 'happy',
      tags: [PostDraftTagModel(userId: 'u2', username: 'bob')],
      media: [
        PostDraftMediaModel(
          path: '/drafts/draft-1/a.mp4',
          isVideo: true,
          width: 1080,
          height: 1920,
          durationMs: 5000,
          poster: '/drafts/draft-1/a.jpg',
        ),
      ],
    );

    PostDraftModel savedModel() =>
        verify(() => drafts.save(captureAny())).captured.last as PostDraftModel;

    test('opening New post restores everything the draft kept', () async {
      when(drafts.read).thenReturn(savedDraft);
      when(privacy.call).thenAnswer(
        (_) async => const PrivacyEntity(
          isPrivate: false,
          defaultVisibility: ContentAudience.public,
        ),
      );
      final cubit = build();
      await cubit.loadDefaultVisibility();

      final state = cubit.state;
      expect(state.postId, 'draft-1');
      expect(state.caption, 'half written');
      expect(state.location, 'Riyadh');
      expect(state.commentsEnabled, isFalse);
      expect(state.visibility, ContentAudience.followers);
      expect(
        state.mood,
        const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
      );
      expect(state.tags.single.id, 'u2');
      expect(state.media.single.path, '/drafts/draft-1/a.mp4');
      expect(state.posters, {'/drafts/draft-1/a.mp4': '/drafts/draft-1/a.jpg'});
      verifyNever(() => picker.describe(any()));
    });

    test('a restored file that was never read is read again', () async {
      when(drafts.read).thenReturn(
        const PostDraftModel(
          id: 'draft-1',
          media: [PostDraftMediaModel(path: '/drafts/draft-1/b.jpg')],
        ),
      );
      build();
      await pumpEventQueue();
      verify(() => picker.describe(any())).called(1);
    });

    test('a change is saved after a short pause, once', () {
      fakeAsync((async) {
        build()
          ..captionChanged('h')
          ..captionChanged('hi');
        async.elapse(const Duration(milliseconds: 100));
        verifyNever(() => drafts.save(any()));
        async.elapse(const Duration(milliseconds: 400));
        final saves = verify(() => drafts.save(captureAny())).captured;
        expect(saves, hasLength(1));
        expect((saves.single as PostDraftModel).caption, 'hi');
      });
    });

    test('a draft emptied of everything is forgotten', () {
      fakeAsync((async) {
        build()
          ..captionChanged('hi')
          ..captionChanged('');
        async.elapse(const Duration(seconds: 1));
        verify(drafts.forget).called(1);
        verifyNever(() => drafts.save(any()));
      });
    });

    test('Save draft saves at once', () async {
      final cubit = build()..captionChanged('hi');
      await cubit.saveDraft();
      final saved = savedModel();
      expect(saved.caption, 'hi');
      expect(saved.id, cubit.state.postId);
    });

    test(
      'Discard post of a draft that never reached the server only forgets it',
      () {
        fakeAsync((async) {
          final cubit = build()..captionChanged('hi');
          unawaited(cubit.discardDraft());
          async.flushMicrotasks();
          verify(drafts.forget).called(1);
          expect(discards.saved, isEmpty);
          expect(discards.sent, isEmpty);
          verify(() => drafts.deleteFiles(cubit.state.postId)).called(1);

          cubit.captionChanged('more');
          async.elapse(const Duration(seconds: 1));
          verifyNever(() => drafts.save(any()));
        });
      },
    );

    test('Discard post of a draft that reached the server tells it', () {
      fakeAsync((async) {
        when(drafts.read).thenReturn(
          const PostDraftModel(id: 'draft-1', caption: 'hi', isOnServer: true),
        );
        final cubit = build();
        unawaited(cubit.discardDraft());
        async.flushMicrotasks();
        expect(discards.saved, ['draft-1']);
        expect(discards.sent, ['draft-1']);
      });
    });

    test(
      'Save draft is saved closed, and the app going away saves it open',
      () async {
        final cubit = build()..captionChanged('hi');
        await cubit.saveDraft();
        expect(savedModel().isOpen, isFalse);

        clearInteractions(drafts);
        await cubit.saveDraftOpen();
        expect(savedModel().isOpen, isTrue);
      },
    );

    test('picked files are moved into the draft folder', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/tmp/a.jpg')]);
      when(() => drafts.keep(any(), '/tmp/a.jpg'))
          .thenAnswer((_) async => '/drafts/x/1.jpg');
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media.single.path, '/drafts/x/1.jpg');
      verify(() => drafts.keep(cubit.state.postId, '/tmp/a.jpg')).called(1);
    });

    test('a file that cannot be moved is kept where it is', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/tmp/a.jpg')]);
      when(() => drafts.keep(any(), any()))
          .thenThrow(const UnexpectedFailure());
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.media.single.path, '/tmp/a.jpg');
    });

    test('removing a photo deletes its file', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/drafts/x/1.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      cubit.removeMedia(0);
      verify(() => drafts.deleteFile('/drafts/x/1.jpg')).called(1);
    });

    test(
      'Share forgets the draft at once and deletes its files once sent',
      () async {
        final sent = Completer<PostEntity?>();
        when(
          () => share.share(
            any(),
            beforeUpload: any(named: 'beforeUpload'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) => sent.future);
        final cubit = build()..captionChanged('hello');
        cubit.save();
        await pumpEventQueue();
        verify(drafts.forget).called(1);
        verifyNever(() => drafts.deleteFiles(any()));

        sent.complete(null);
        await pumpEventQueue();
        verify(() => drafts.deleteFiles(cubit.state.postId)).called(1);
      },
    );

    test('editing a post never reads or writes the draft', () {
      fakeAsync((async) {
        build(
          PostEntity(
            id: 'p',
            authorId: 'u',
            username: 'omar',
            caption: 'Hello',
            likeCount: 0,
            commentCount: 0,
            commentsEnabled: true,
            visibility: ContentAudience.public,
            createdAt: DateTime(2026),
            likedByMe: false,
            savedByMe: false,
            media: const [],
          ),
        ).captionChanged('changed');
        async.elapse(const Duration(seconds: 1));
        verifyNever(drafts.read);
        verifyNever(() => drafts.save(any()));
      });
    });
    test('a share saves without words or media once something changed', () {
      final share = PostEntity(
        id: 's',
        authorId: 'u',
        username: 'omar',
        likeCount: 0,
        commentCount: 0,
        commentsEnabled: true,
        visibility: ContentAudience.public,
        createdAt: DateTime(2026),
        likedByMe: false,
        savedByMe: false,
        media: const [],
        isShare: true,
      );
      final cubit = build(share);
      expect(cubit.state.isShare, isTrue);
      expect(cubit.state.canSave, isFalse);
      cubit.locationChanged('Cairo');
      expect(cubit.state.canSave, isTrue);
    });
  });

  group('uploading on pick', () {
    late _MediaRepo media;

    /// File names in the post's folder on the server.
    late Set<String> onServer;

    /// The uploads in progress, by stem.
    late Map<String, Completer<SentMedia>> sends;

    setUpAll(() {
      registerFallbackValue(ContentKind.post);
      registerFallbackValue(const MediaToSend(filePath: '/x', isVideo: false));
    });

    setUp(() {
      media = _MediaRepo();
      onServer = {};
      sends = {};
      when(() => media.folderOf(any())).thenAnswer(
        (invocation) => 'u1/${invocation.positionalArguments.first}',
      );
      when(() => media.existing(any())).thenAnswer((_) async => {...onServer});
      when(() => media.removeQuietly(any())).thenAnswer((invocation) async {
        for (final path in invocation.positionalArguments.first as List) {
          onServer.remove((path as String).split('/').last);
        }
      });
      when(
        () => media.send(
          any(),
          any(),
          folder: any(named: 'folder'),
          stem: any(named: 'stem'),
          existing: any(named: 'existing'),
          onProgress: any(named: 'onProgress'),
          cancel: any(named: 'cancel'),
        ),
      ).thenAnswer((invocation) async {
        final stem = invocation.namedArguments[#stem] as String;
        final sent = await (sends[stem] = Completer<SentMedia>()).future;
        onServer.add('$stem.jpg');
        return sent;
      });
      uploads = MediaUploadQueue(media);
    });

    void finish(String stem) =>
        sends[stem]!.complete(SentMedia(path: 'u1/p/$stem.jpg'));

    List<String> sentStems() => verify(
      () => media.send(
        any(),
        any(),
        folder: any(named: 'folder'),
        stem: captureAny(named: 'stem'),
        existing: any(named: 'existing'),
        onProgress: any(named: 'onProgress'),
        cancel: any(named: 'cancel'),
      ),
    ).captured.cast<String>();

    Future<AddEditPostCubit> pickThree() async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [photo('/a.jpg'), photo('/b.jpg'), photo('/c.jpg')],
      );
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      return cubit;
    }

    test('the first pick opens the draft on the server, once', () async {
      final cubit = await pickThree();
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/d.jpg')]);
      await cubit.pickMedia();
      await pumpEventQueue();
      verify(() => server.openDraft(cubit.state.postId, ContentKind.post))
          .called(1);
    });

    test(
      'pick 3, remove 1 mid-upload, edit the text: 2 files, each sent once',
      () async {
        final cubit = await pickThree();
        final ids = cubit.state.mediaIds;
        final (a, b, c) = (ids['/a.jpg']!, ids['/b.jpg']!, ids['/c.jpg']!);
        expect(sends.keys, [a, b], reason: 'two at a time');

        cubit.removeMedia(1);
        await pumpEventQueue();
        finish(b); // a late answer for the removed photo
        finish(a);
        await pumpEventQueue();
        finish(c);
        cubit.captionChanged('hello');
        await pumpEventQueue();

        expect(onServer, {'$a.jpg', '$c.jpg'});
        expect(sentStems(), unorderedEquals([a, b, c]));
      },
    );

    test('a failed upload shows on the photo; a tap tries it again', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      final id = cubit.state.mediaIds['/a.jpg']!;
      sends[id]!.completeError(const NetworkFailure());
      await pumpEventQueue();
      expect(cubit.state.failedUploads, {'/a.jpg'});

      cubit.retryUpload('/a.jpg');
      await pumpEventQueue();
      expect(cubit.state.failedUploads, isEmpty);
      finish(id);
      await pumpEventQueue();
      expect(onServer, {'$id.jpg'});
    });

    test(
      'Share waits for the uploads still going and names files by their id',
      () async {
        when(() => picker.pickMany(limit: any(named: 'limit')))
            .thenAnswer((_) async => [photo('/a.jpg')]);
        final cubit = build();
        await cubit.pickMedia();
        await pumpEventQueue();
        cubit.save();
        await pumpEventQueue();
        final sent =
            verify(
                  () => share.share(
                    captureAny(),
                    beforeUpload: any(named: 'beforeUpload'),
                    onProgress: any(named: 'onProgress'),
                  ),
                ).captured.single
                as NewPostEntity;
        final id = cubit.state.mediaIds['/a.jpg']!;
        expect(sent.media.single.id, id);
        expect(publish.current(ContentKind.post), isA<ContentPublishing>());

        finish(id);
        await pumpEventQueue();
        expect(publish.current(ContentKind.post), isA<ContentPublishIdle>());
      },
    );

    test('a restored draft uploads its files again', () async {
      when(drafts.read).thenReturn(
        const PostDraftModel(
          id: 'draft-1',
          media: [
            PostDraftMediaModel(
              id: 'm1',
              path: '/drafts/draft-1/a.jpg',
              isVideo: false,
              width: 4,
              height: 3,
            ),
          ],
        ),
      );
      build();
      await pumpEventQueue();
      expect(sends.keys, ['m1']);
      verify(() => server.openDraft('draft-1', ContentKind.post)).called(1);
    });

    test('editing a post uploads nothing on pick', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg')]);
      final cubit = build(
        PostEntity(
          id: 'p',
          authorId: 'u',
          username: 'omar',
          caption: 'Hello',
          likeCount: 0,
          commentCount: 0,
          commentsEnabled: true,
          visibility: ContentAudience.public,
          createdAt: DateTime(2026),
          likedByMe: false,
          savedByMe: false,
          media: const [],
        ),
      );
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(sends, isEmpty);
      verifyNever(() => server.openDraft(any(), any()));
    });
  });
}
