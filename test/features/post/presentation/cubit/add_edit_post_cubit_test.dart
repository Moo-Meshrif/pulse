import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/data/repository/post_publish_repository.dart';
import 'package:pulse/features/post/domain/entity/edit_post_entity.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_entity.dart';
import 'package:pulse/features/post/domain/entity/post_media_entity.dart';
import 'package:pulse/features/post/domain/entity/post_publish_status.dart';
import 'package:pulse/features/post/domain/use_case/create_post_use_case.dart';
import 'package:pulse/features/post/domain/use_case/sign_post_media_urls_use_case.dart';
import 'package:pulse/features/post/domain/use_case/update_post_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/add_edit_post_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/new_post_notice.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';

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
  late PostPublishRepositoryImpl publish;

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
    publish = PostPublishRepositoryImpl();
    when(account.call).thenReturn(null);
    when(() => picker.describe(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as PickedMedia,
    );
    when(() => createPost(any())).thenAnswer((_) async {});
    when(() => thumbnails.thumbnail(any())).thenAnswer((_) async => '/t.jpg');
  });

  AddEditPostCubit build([PostEntity? post]) => AddEditPostCubit(
    createPost,
    updatePost,
    publish,
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
      verifyNever(() => createPost(any()));

      read.complete(
        PickedMedia(path: '/p.jpg', isVideo: false, width: 800, height: 600),
      );
      await pumpEventQueue();
      final sent =
          verify(() => createPost(captureAny())).captured.single
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

    test('a video over 50 MB is rejected', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [video(sizeBytes: 50 * 1024 * 1024 + 1)]);
      final cubit = build();
      await cubit.pickMedia();
      await pumpEventQueue();
      expect(cubit.state.media, isEmpty);
      expect(cubit.state.notice, NewPostNotice.videoTooBig);
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
          verify(() => createPost(captureAny())).captured.single
              as NewPostEntity;
      expect(sent.id, cubit.state.postId);
      expect(sent.caption, 'hello');
      expect(sent.commentsEnabled, isFalse);
      expect(sent.location, 'Kolkata');
      expect(sent.visibility, ContentAudience.public);
      expect(cubit.state.isSaved, isTrue);
    });

    test('closes at once, before the post is sent', () {
      final done = Completer<void>();
      when(() => createPost(any())).thenAnswer((_) => done.future);
      final cubit = build()..captionChanged('hello');
      cubit.save();
      expect(cubit.state.isSaved, isTrue);
      done.complete();
    });

    test(
      'a failure is kept by the sender, then Retry sends the same id',
      () async {
        when(() => createPost(any())).thenThrow(const UnexpectedFailure());
        final cubit = build()..captionChanged('hello');
        cubit.save();
        await pumpEventQueue();
        expect(cubit.state.isSaved, isTrue);
        expect(await publish.status.first, isA<PostPublishFailed>());

        when(() => createPost(any())).thenAnswer((_) async {});
        publish.retry();
        await pumpEventQueue();
        final ids = verify(() => createPost(captureAny())).captured
            .cast<NewPostEntity>()
            .map((p) => p.id)
            .toSet();
        expect(ids, {cubit.state.postId});
        expect(await publish.status.first, isA<PostPublishIdle>());
      },
    );

    test('another post is refused while one is waiting for Retry', () async {
      when(() => createPost(any())).thenThrow(const UnexpectedFailure());
      build()
        ..captionChanged('first')
        ..save();
      await pumpEventQueue();

      final second = build()..captionChanged('second');
      second.save();
      expect(second.state.isSaved, isFalse);
      expect(second.state.notice, NewPostNotice.publishBusy);
    });

    test('an empty post is not sent', () async {
      build().save();
      await pumpEventQueue();
      verifyNever(() => createPost(any()));
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
      when(() => updatePost(any(), before: any(named: 'before')))
          .thenAnswer((_) async {});
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

    test('save updates the post, not creates it', () async {
      final cubit = build(post)..captionChanged('  Changed  ');
      cubit.save();
      await pumpEventQueue();
      final edited =
          verify(() => updatePost(captureAny(), before: post)).captured.single
              as EditPostEntity;
      expect(edited.caption, 'Changed');
      expect(edited.kept, [m0, m1]);
      verifyNever(() => createPost(any()));
      expect(cubit.state.isSaved, isTrue);
    });
  });
}
