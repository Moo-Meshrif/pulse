import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/post/domain/entity/new_post_entity.dart';
import 'package:pulse/features/post/domain/use_case/create_post_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/new_post_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/new_post_notice.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';

class _CreatePost extends Mock implements CreatePostUseCase {}

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
  late _Picker picker;
  late _Privacy privacy;
  late _Thumbnails thumbnails;
  late _Account account;

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

  setUp(() {
    createPost = _CreatePost();
    picker = _Picker();
    privacy = _Privacy();
    thumbnails = _Thumbnails();
    account = _Account();
    when(account.call).thenReturn(null);
    when(() => createPost(any())).thenAnswer((_) async {});
    when(() => thumbnails.thumbnail(any())).thenAnswer((_) async => '/t.jpg');
  });

  NewPostCubit build() =>
      NewPostCubit(createPost, picker, privacy, thumbnails, account);

  group('Share is enabled', () {
    test('not when empty', () {
      expect(build().state.canShare, isFalse);
    });

    test('with text', () {
      final cubit = build()..captionChanged('hello');
      expect(cubit.state.canShare, isTrue);
    });

    test('not with only spaces', () {
      final cubit = build()..captionChanged('   ');
      expect(cubit.state.canShare, isFalse);
    });

    test('with one photo and no text', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo()]);
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.canShare, isTrue);
    });
  });

  group('picking media', () {
    test('asks only for the slots left', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg'), photo('/b.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
      await cubit.pickMedia();
      verify(() => picker.pickMany(limit: 10)).called(1);
      verify(() => picker.pickMany(limit: 8)).called(1);
      expect(cubit.state.media, hasLength(4));
    });

    test('a full post asks for nothing and says so', () async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          for (var i = 0; i < NewPostLimits.maxMedia; i++) photo('/$i.jpg'),
        ],
      );
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.canAddMedia, isFalse);

      await cubit.pickMedia();
      verify(() => picker.pickMany(limit: any(named: 'limit'))).called(1);
      expect(cubit.state.notice, NewPostNotice.mediaLimit);
    });

    test('a video over 10 minutes is rejected, the photo stays', () async {
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [photo(), video(durationMs: 10 * 60 * 1000 + 1)],
      );
      final cubit = build();
      await cubit.pickMedia();
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
      expect(cubit.state.media, hasLength(1));
      expect(cubit.state.notice, isNull);
    });

    test('a video over 50 MB is rejected', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [video(sizeBytes: 50 * 1024 * 1024 + 1)]);
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.media, isEmpty);
      expect(cubit.state.notice, NewPostNotice.videoTooBig);
    });

    test('a video gets a poster; a failing poster is skipped', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [video()]);
      final cubit = build();
      await cubit.pickMedia();
      expect(cubit.state.posters, {'/v.mp4': '/t.jpg'});

      when(() => thumbnails.thumbnail(any()))
          .thenThrow(const UnexpectedFailure());
      final other = build();
      await other.pickMedia();
      expect(other.state.media, hasLength(1));
      expect(other.state.posters, isEmpty);
    });

    test('cancelling changes nothing', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => []);
      final cubit = build();
      final before = cubit.state;
      await cubit.pickMedia();
      expect(cubit.state, before);
    });

    test('removing drops that one', () async {
      when(() => picker.pickMany(limit: any(named: 'limit')))
          .thenAnswer((_) async => [photo('/a.jpg'), photo('/b.jpg')]);
      final cubit = build();
      await cubit.pickMedia();
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
      await cubit.share();

      final sent =
          verify(() => createPost(captureAny())).captured.single
              as NewPostEntity;
      expect(sent.id, cubit.state.postId);
      expect(sent.caption, 'hello');
      expect(sent.commentsEnabled, isFalse);
      expect(sent.location, 'Kolkata');
      expect(sent.visibility, ContentAudience.public);
      expect(cubit.state.isShared, isTrue);
      expect(cubit.state.isSharing, isFalse);
    });

    test('a failure stays, then Retry sends the same post id', () async {
      when(() => createPost(any())).thenThrow(const UnexpectedFailure());
      final cubit = build()..captionChanged('hello');
      await cubit.share();
      expect(cubit.state.isShared, isFalse);
      expect(cubit.state.isSharing, isFalse);
      expect(cubit.state.notice, NewPostNotice.shareFailed);

      when(() => createPost(any())).thenAnswer((_) async {});
      await cubit.share();
      final ids = verify(() => createPost(captureAny())).captured
          .cast<NewPostEntity>()
          .map((p) => p.id)
          .toSet();
      expect(ids, {cubit.state.postId});
      expect(cubit.state.isShared, isTrue);
    });

    test('an empty post is not sent', () async {
      await build().share();
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
}
