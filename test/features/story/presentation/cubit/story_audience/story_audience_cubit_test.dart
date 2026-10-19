import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/presentation/cubit/story_audience/story_audience_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_audience_status.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';

import '../../../../../helpers/content_mocks.dart';

void main() {
  late MockGetAudienceSummary summary;
  late MockSetContentAudience setAudience;

  setUpAll(registerContentFallbacks);

  setUp(() {
    summary = MockGetAudienceSummary();
    setAudience = okSetContentAudience();
    when(() => summary()).thenAnswer(
      (_) async => const AudienceSummaryEntity(
        followers: 312,
        closeFriends: 12,
        hidden: 2,
      ),
    );
  });

  StoryAudienceCubit build([
    ContentAudience audience = ContentAudience.followers,
  ]) => StoryAudienceCubit(summary, setAudience, 's1', audience);

  test('opens on the story audience, then loads the counts', () async {
    final cubit = build(ContentAudience.closeFriends);
    expect(cubit.state.audience, ContentAudience.closeFriends);
    expect(cubit.state.status, StoryAudienceStatus.loading);
    await cubit.load();
    expect(cubit.state.status, StoryAudienceStatus.ready);
    expect(cubit.state.summary.followers, 312);
    expect(cubit.state.summary.closeFriends, 12);
    expect(cubit.state.summary.hidden, 2);
    await cubit.close();
  });

  test('counts that fail to load do not block choosing', () async {
    when(() => summary()).thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.load();
    expect(cubit.state.status, StoryAudienceStatus.failed);
    await cubit.select(ContentAudience.closeFriends);
    expect(cubit.state.audience, ContentAudience.closeFriends);
    await cubit.close();
  });

  test('a choice shows at once and is saved for that story', () async {
    final cubit = build();
    final seen = <ContentAudience>[];
    final sub = cubit.stream.listen((s) => seen.add(s.audience));
    await cubit.select(ContentAudience.closeFriends);
    await sub.cancel();
    expect(seen.first, ContentAudience.closeFriends);
    verify(
      () => setAudience(ContentKind.story, 's1', ContentAudience.closeFriends),
    ).called(1);
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test('choosing what is already chosen saves nothing', () async {
    final cubit = build();
    await cubit.select(ContentAudience.followers);
    verifyNever(() => setAudience(any(), any(), any()));
    await cubit.close();
  });

  test('a failed save goes back and says why, once', () async {
    when(() => setAudience(any(), any(), any()))
        .thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.select(ContentAudience.closeFriends);
    expect(cubit.state.audience, ContentAudience.followers);
    expect(cubit.state.failure, const NetworkFailure());
    cubit.clearFailure();
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test(
    'a retry after a failure shows the loader again, then the numbers',
    () async {
      when(() => summary()).thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, StoryAudienceStatus.failed);

      when(() => summary()).thenAnswer(
        (_) async => const AudienceSummaryEntity(
          followers: 5,
          closeFriends: 1,
          hidden: 0,
        ),
      );
      final seen = <StoryAudienceStatus>[];
      final sub = cubit.stream.listen((s) => seen.add(s.status));
      await cubit.load();
      await sub.cancel();
      expect(seen.first, StoryAudienceStatus.loading);
      expect(cubit.state.status, StoryAudienceStatus.ready);
      expect(cubit.state.summary.followers, 5);
      await cubit.close();
    },
  );

  test(
    'a reload with the sheet showing keeps it showing, even if it fails',
    () async {
      final cubit = build();
      await cubit.load();
      final seen = <StoryAudienceStatus>[];
      final sub = cubit.stream.listen((s) => seen.add(s.status));

      when(() => summary()).thenThrow(const NetworkFailure());
      await cubit.load();
      await sub.cancel();

      expect(seen, isNot(contains(StoryAudienceStatus.loading)));
      expect(cubit.state.status, StoryAudienceStatus.ready);
      expect(cubit.state.summary.followers, 312);
      await cubit.close();
    },
  );

  group('a Close friends story with nobody on the list', () {
    const empty = AudienceSummaryEntity(
      followers: 5,
      closeFriends: 0,
      hidden: 0,
    );

    test('goes back to Followers and is saved', () async {
      when(() => summary()).thenAnswer((_) async => empty);
      final cubit = build(ContentAudience.closeFriends);
      await cubit.load();
      expect(cubit.state.audience, ContentAudience.followers);
      verify(
        () => setAudience(ContentKind.story, 's1', ContentAudience.followers),
      ).called(1);
      await cubit.close();
    });

    test('stays Close friends while the list has people', () async {
      final cubit = build(ContentAudience.closeFriends);
      await cubit.load();
      expect(cubit.state.audience, ContentAudience.closeFriends);
      verifyNever(() => setAudience(any(), any(), any()));
      await cubit.close();
    });

    test('a Followers story is left alone', () async {
      when(() => summary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      verifyNever(() => setAudience(any(), any(), any()));
      await cubit.close();
    });

    test(
      'after a list screen emptied the list, the reload switches it',
      () async {
        final cubit = build(ContentAudience.closeFriends);
        await cubit.load();
        expect(cubit.state.audience, ContentAudience.closeFriends);

        when(() => summary()).thenAnswer((_) async => empty);
        await cubit.load();
        expect(cubit.state.audience, ContentAudience.followers);
        await cubit.close();
      },
    );
  });

  group('after a list screen saved', () {
    const empty = AudienceSummaryEntity(
      followers: 5,
      closeFriends: 0,
      hidden: 0,
    );
    const three = AudienceSummaryEntity(
      followers: 5,
      closeFriends: 3,
      hidden: 0,
    );

    test('the first close friends added mark Close friends', () async {
      when(() => summary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();

      when(() => summary()).thenAnswer((_) async => three);
      await cubit.listEdited(isCloseFriends: true);

      expect(cubit.state.audience, ContentAudience.closeFriends);
      verify(
        () =>
            setAudience(ContentKind.story, 's1', ContentAudience.closeFriends),
      ).called(1);
      await cubit.close();
    });

    test(
      'editing a list that already had people leaves the audience',
      () async {
        final cubit = build(); // 12 close friends
        await cubit.load();
        await cubit.listEdited(isCloseFriends: true);
        expect(cubit.state.audience, ContentAudience.followers);
        verifyNever(() => setAudience(any(), any(), any()));
        await cubit.close();
      },
    );

    test('Hide story from never changes the audience', () async {
      when(() => summary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      when(() => summary()).thenAnswer((_) async => three);
      await cubit.listEdited(isCloseFriends: false);
      expect(cubit.state.audience, ContentAudience.followers);
      await cubit.close();
    });

    test('a list still empty after saving changes nothing', () async {
      when(() => summary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      await cubit.listEdited(isCloseFriends: true);
      expect(cubit.state.audience, ContentAudience.followers);
      verifyNever(() => setAudience(any(), any(), any()));
      await cubit.close();
    });
  });
}
