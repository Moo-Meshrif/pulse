import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/domain/entity/post_tag_entity.dart';
import 'package:pulse/features/post/presentation/cubit/share_sheet/share_sheet_cubit.dart';
import 'package:pulse/features/post/presentation/cubit/share_sheet/share_sheet_state.dart';
import 'package:pulse/features/post/presentation/utils/enums/share_result.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/entity/content_publish_status.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_publish_status_use_case.dart';

import '../../../post_doubles.dart';

class _Status extends Fake implements GetPublishStatusUseCase {
  @override
  ContentPublishStatus call(ContentKind kind) => ContentPublishIdle(kind);
}

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Account extends Mock implements GetLastAccountUseCase {}

void main() {
  late MockPostRepository posts;
  late _Privacy privacy;

  setUpAll(() => registerFallbackValue(ContentAudience.public));

  setUp(() {
    posts = MockPostRepository();
    privacy = _Privacy();
    when(privacy.call).thenAnswer(
      (_) async => const PrivacyEntity(
        isPrivate: false,
        defaultVisibility: ContentAudience.followers,
      ),
    );
  });

  ShareSheetCubit build() {
    final account = _Account();
    when(account.call).thenReturn(null);
    return ShareSheetCubit(posts, privacy, _Status(), account, 'o1');
  }

  void answer({required bool started}) => when(
    () => posts.shareToFeed(
      any(),
      caption: any(named: 'caption'),
      audience: any(named: 'audience'),
      mood: any(named: 'mood'),
      location: any(named: 'location'),
      tags: any(named: 'tags'),
    ),
  ).thenReturn(started);

  group('audience', () {
    blocTest<ShareSheetCubit, ShareSheetState>(
      'starts from the account default and remembers it for the chip',
      build: build,
      act: (cubit) => cubit.loadDefaultAudience(),
      expect: () => [
        const ShareSheetState(
          audience: ContentAudience.followers,
          defaultAudience: ContentAudience.followers,
        ),
      ],
      verify: (cubit) => expect(cubit.state.isAudienceNarrowed, isFalse),
    );

    test('a locked audience stays when the account default loads', () async {
      final cubit = build();

      cubit.lockAudience(ContentAudience.followers);
      await cubit.loadDefaultAudience();

      expect(cubit.state.audience, ContentAudience.followers);
      expect(cubit.state.isAudienceLocked, isTrue);
      expect(cubit.state.isAudienceNarrowed, isFalse);
      verifyNever(privacy.call);
    });

    blocTest<ShareSheetCubit, ShareSheetState>(
      'a default that cannot be read leaves the chip Public',
      build: () {
        when(privacy.call).thenThrow(const NetworkFailure());
        return build();
      },
      act: (cubit) => cubit.loadDefaultAudience(),
      expect: () => <ShareSheetState>[],
    );

    test(
      'a narrower pick shows as narrowed; "use for future" is the new default',
      () {
        final cubit = build();

        cubit.audienceChosen(
          const PostVisibilityResult(audience: ContentAudience.onlyMe),
        );
        expect(cubit.state.audience, ContentAudience.onlyMe);
        expect(cubit.state.isAudienceNarrowed, isTrue);

        cubit.audienceChosen(
          const PostVisibilityResult(
            audience: ContentAudience.closeFriends,
            savedAsDefault: true,
          ),
        );
        expect(cubit.state.defaultAudience, ContentAudience.closeFriends);
        expect(cubit.state.isAudienceNarrowed, isFalse);
      },
    );
  });

  group('tools', () {
    test('keep their values and a share has no photo to tag on', () {
      final cubit = build();
      const mood = PostMoodEntity(kind: MoodKind.feeling, key: 'happy');
      const tag = TagChoice(id: 'u2', username: 'omar');

      cubit
        ..moodChanged(mood)
        ..locationChanged('Cairo')
        ..tagsChanged(const [tag]);

      expect(cubit.state.mood, mood);
      expect(cubit.state.location, 'Cairo');
      expect(cubit.tagArgs.chosen, [tag]);
      expect(cubit.tagArgs.photos, isEmpty);
      expect(cubit.tagArgs.hasPhotos, isFalse);
    });
  });

  group('share', () {
    test('sends the words, audience, feeling, place and tags', () {
      answer(started: true);
      final cubit = build()
        ..captionChanged('  Look at this  ')
        ..audienceChosen(
          const PostVisibilityResult(audience: ContentAudience.followers),
        )
        ..moodChanged(
          const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
        )
        ..locationChanged('Cairo')
        ..tagsChanged(const [TagChoice(id: 'u2', username: 'omar')])
        ..share();

      verify(
        () => posts.shareToFeed(
          'o1',
          caption: 'Look at this',
          audience: ContentAudience.followers,
          mood: const PostMoodEntity(kind: MoodKind.feeling, key: 'happy'),
          location: 'Cairo',
          tags: const [PostTagEntity(userId: 'u2', username: 'omar')],
        ),
      ).called(1);
      expect(cubit.state.result, ShareResult.shared);
    });

    test('works with an empty caption', () {
      answer(started: true);
      final cubit = build()
        ..captionChanged('   ')
        ..share();

      verify(
        () => posts.shareToFeed(
          'o1',
          caption: null,
          audience: ContentAudience.public,
          mood: null,
          location: null,
          tags: const [],
        ),
      ).called(1);
      expect(cubit.state.result, ShareResult.shared);
    });

    test('a full line keeps everything written and can be tried again', () {
      answer(started: false);
      final cubit = build()
        ..captionChanged('Keep me')
        ..locationChanged('Cairo')
        ..share();

      expect(cubit.state.result, ShareResult.busy);
      expect(cubit.state.caption, 'Keep me');
      expect(cubit.state.location, 'Cairo');

      cubit.clearResult();
      expect(cubit.state.result, isNull);

      answer(started: true);
      cubit.share();
      expect(cubit.state.result, ShareResult.shared);
    });
  });
}
