import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/enums/story_audience.dart';
import 'package:pulse/features/story/data/model/audience_summary_model.dart';
import 'package:pulse/features/story/presentation/cubit/story_audience_cubit.dart';
import 'package:pulse/features/story/presentation/utils/enums/story_audience_status.dart';

class _Stories extends Mock implements StoriesDatasource {}

void main() {
  late _Stories stories;

  setUpAll(() => registerFallbackValue(StoryAudience.followers));

  setUp(() {
    stories = _Stories();
    when(() => stories.getAudienceSummary()).thenAnswer(
      (_) async => const AudienceSummaryModel(
        followers: 312,
        closeFriends: 12,
        hidden: 2,
      ),
    );
    when(() => stories.setAudience(any(), any())).thenAnswer((_) async {});
  });

  StoryAudienceCubit build([
    StoryAudience audience = StoryAudience.followers,
  ]) => StoryAudienceCubit(stories, 's1', audience);

  test('opens on the story audience, then loads the counts', () async {
    final cubit = build(StoryAudience.closeFriends);
    expect(cubit.state.audience, StoryAudience.closeFriends);
    expect(cubit.state.status, StoryAudienceStatus.loading);
    await cubit.load();
    expect(cubit.state.status, StoryAudienceStatus.ready);
    expect(cubit.state.summary.followers, 312);
    expect(cubit.state.summary.closeFriends, 12);
    expect(cubit.state.summary.hidden, 2);
    await cubit.close();
  });

  test('counts that fail to load do not block choosing', () async {
    when(() => stories.getAudienceSummary()).thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.load();
    expect(cubit.state.status, StoryAudienceStatus.failed);
    await cubit.select(StoryAudience.closeFriends);
    expect(cubit.state.audience, StoryAudience.closeFriends);
    await cubit.close();
  });

  test('a choice shows at once and is saved for that story', () async {
    final cubit = build();
    final seen = <StoryAudience>[];
    final sub = cubit.stream.listen((s) => seen.add(s.audience));
    await cubit.select(StoryAudience.closeFriends);
    await sub.cancel();
    expect(seen.first, StoryAudience.closeFriends);
    verify(() => stories.setAudience('s1', StoryAudience.closeFriends))
        .called(1);
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test('choosing what is already chosen saves nothing', () async {
    final cubit = build();
    await cubit.select(StoryAudience.followers);
    verifyNever(() => stories.setAudience(any(), any()));
    await cubit.close();
  });

  test('a failed save goes back and says why, once', () async {
    when(() => stories.setAudience(any(), any()))
        .thenThrow(const NetworkFailure());
    final cubit = build();
    await cubit.select(StoryAudience.closeFriends);
    expect(cubit.state.audience, StoryAudience.followers);
    expect(cubit.state.failure, const NetworkFailure());
    cubit.clearFailure();
    expect(cubit.state.failure, isNull);
    await cubit.close();
  });

  test(
    'a retry after a failure shows the loader again, then the numbers',
    () async {
      when(() => stories.getAudienceSummary())
          .thenThrow(const NetworkFailure());
      final cubit = build();
      await cubit.load();
      expect(cubit.state.status, StoryAudienceStatus.failed);

      when(() => stories.getAudienceSummary()).thenAnswer(
        (_) async => const AudienceSummaryModel(
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

      when(() => stories.getAudienceSummary())
          .thenThrow(const NetworkFailure());
      await cubit.load();
      await sub.cancel();

      expect(seen, isNot(contains(StoryAudienceStatus.loading)));
      expect(cubit.state.status, StoryAudienceStatus.ready);
      expect(cubit.state.summary.followers, 312);
      await cubit.close();
    },
  );

  group('a Close friends story with nobody on the list', () {
    const empty = AudienceSummaryModel(
      followers: 5,
      closeFriends: 0,
      hidden: 0,
    );

    test('goes back to Followers and is saved', () async {
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
      final cubit = build(StoryAudience.closeFriends);
      await cubit.load();
      expect(cubit.state.audience, StoryAudience.followers);
      verify(() => stories.setAudience('s1', StoryAudience.followers))
          .called(1);
      await cubit.close();
    });

    test('stays Close friends while the list has people', () async {
      final cubit = build(StoryAudience.closeFriends);
      await cubit.load();
      expect(cubit.state.audience, StoryAudience.closeFriends);
      verifyNever(() => stories.setAudience(any(), any()));
      await cubit.close();
    });

    test('a Followers story is left alone', () async {
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      verifyNever(() => stories.setAudience(any(), any()));
      await cubit.close();
    });

    test(
      'after a list screen emptied the list, the reload switches it',
      () async {
        final cubit = build(StoryAudience.closeFriends);
        await cubit.load();
        expect(cubit.state.audience, StoryAudience.closeFriends);

        when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
        await cubit.load();
        expect(cubit.state.audience, StoryAudience.followers);
        await cubit.close();
      },
    );
  });

  group('after a list screen saved', () {
    const empty = AudienceSummaryModel(
      followers: 5,
      closeFriends: 0,
      hidden: 0,
    );
    const three = AudienceSummaryModel(
      followers: 5,
      closeFriends: 3,
      hidden: 0,
    );

    test('the first close friends added mark Close friends', () async {
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();

      when(() => stories.getAudienceSummary()).thenAnswer((_) async => three);
      await cubit.listEdited(isCloseFriends: true);

      expect(cubit.state.audience, StoryAudience.closeFriends);
      verify(() => stories.setAudience('s1', StoryAudience.closeFriends))
          .called(1);
      await cubit.close();
    });

    test(
      'editing a list that already had people leaves the audience',
      () async {
        final cubit = build(); // 12 close friends
        await cubit.load();
        await cubit.listEdited(isCloseFriends: true);
        expect(cubit.state.audience, StoryAudience.followers);
        verifyNever(() => stories.setAudience(any(), any()));
        await cubit.close();
      },
    );

    test('Hide story from never changes the audience', () async {
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => three);
      await cubit.listEdited(isCloseFriends: false);
      expect(cubit.state.audience, StoryAudience.followers);
      await cubit.close();
    });

    test('a list still empty after saving changes nothing', () async {
      when(() => stories.getAudienceSummary()).thenAnswer((_) async => empty);
      final cubit = build();
      await cubit.load();
      await cubit.listEdited(isCloseFriends: true);
      expect(cubit.state.audience, StoryAudience.followers);
      verifyNever(() => stories.setAudience(any(), any()));
      await cubit.close();
    });
  });
}
