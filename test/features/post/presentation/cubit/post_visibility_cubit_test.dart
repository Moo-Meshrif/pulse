import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/post/data/datasource/visibility_notice_datasource.dart';
import 'package:pulse/features/post/presentation/cubit/post_visibility_cubit.dart';
import 'package:pulse/features/post/presentation/utils/enums/post_visibility_status.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_audience_summary_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/save_default_audience_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Summary extends Mock implements GetAudienceSummaryUseCase {}

class _SaveDefault extends Mock implements SaveDefaultAudienceUseCase {}

class _SetAudience extends Mock implements SetContentAudienceUseCase {}

class _Notices extends Mock implements VisibilityNoticeDatasource {}

void main() {
  late _Privacy privacy;
  late _Summary summary;
  late _SaveDefault saveDefault;
  late _SetAudience setAudience;
  late _Notices notices;

  setUpAll(() {
    registerFallbackValue(ContentAudience.public);
    registerFallbackValue(ContentKind.post);
  });

  setUp(() {
    privacy = _Privacy();
    summary = _Summary();
    saveDefault = _SaveDefault();
    setAudience = _SetAudience();
    notices = _Notices();
    when(privacy.call).thenAnswer(
      (_) async => const PrivacyEntity(
        isPrivate: false,
        defaultVisibility: ContentAudience.public,
      ),
    );
    when(summary.call).thenAnswer(
      (_) async =>
          const AudienceSummaryEntity(followers: 120, closeFriends: 12),
    );
    when(() => saveDefault(any())).thenAnswer((_) async {});
    when(() => setAudience(any(), any(), any())).thenAnswer((_) async {});
    when(() => notices.isSeen(any())).thenReturn(false);
    when(() => notices.markSeen(any())).thenAnswer((_) async {});
  });

  PostVisibilityCubit build({
    String? postId,
    ContentAudience audience = ContentAudience.public,
  }) => PostVisibilityCubit(
    privacy,
    summary,
    saveDefault,
    setAudience,
    notices,
    postId,
    audience,
  );

  group('a private account', () {
    setUp(() {
      when(privacy.call).thenAnswer(
        (_) async => const PrivacyEntity(
          isPrivate: true,
          defaultVisibility: ContentAudience.followers,
        ),
      );
    });

    test('moves a Public choice to Followers', () async {
      final cubit = build();
      await cubit.loadChoices();
      expect(cubit.state.isPrivate, isTrue);
      expect(cubit.state.audience, ContentAudience.followers);
    });

    test('cannot choose Public', () async {
      final cubit = build(audience: ContentAudience.followers);
      await cubit.loadChoices();
      cubit.select(ContentAudience.public);
      expect(cubit.state.audience, ContentAudience.followers);
      cubit.select(ContentAudience.onlyMe);
      expect(cubit.state.audience, ContentAudience.onlyMe);
    });
  });

  group('loading', () {
    test('a public account keeps its choice and gets the counts', () async {
      final cubit = build(audience: ContentAudience.closeFriends);
      await cubit.loadChoices();
      expect(cubit.state.status, PostVisibilityStatus.ready);
      expect(cubit.state.audience, ContentAudience.closeFriends);
      expect(cubit.state.summary.followers, 120);
    });

    test('a failure can be retried', () async {
      when(summary.call).thenThrow(const UnexpectedFailure());
      final cubit = build();
      await cubit.loadChoices();
      expect(cubit.state.status, PostVisibilityStatus.failed);

      when(summary.call)
          .thenAnswer((_) async => const AudienceSummaryEntity(followers: 3));
      await cubit.loadChoices();
      expect(cubit.state.status, PostVisibilityStatus.ready);
    });
  });

  group('Done on New post', () {
    test(
      'returns the choice and saves nothing when the toggle is off',
      () async {
        final cubit = build();
        await cubit.loadChoices();
        cubit.select(ContentAudience.followers);
        await cubit.confirm();

        expect(cubit.state.result?.audience, ContentAudience.followers);
        expect(cubit.state.result?.savedAsDefault, isFalse);
        verifyNever(() => saveDefault(any()));
        verifyNever(() => setAudience(any(), any(), any()));
      },
    );

    test('saves the default when the toggle is on', () async {
      final cubit = build();
      await cubit.loadChoices();
      cubit
        ..select(ContentAudience.followers)
        ..saveAsDefaultChanged(true);
      await cubit.confirm();

      verify(() => saveDefault(ContentAudience.followers)).called(1);
      expect(cubit.state.result?.savedAsDefault, isTrue);
    });

    test('a failed save stays open with the failure', () async {
      when(() => saveDefault(any())).thenThrow(const UnexpectedFailure());
      final cubit = build();
      await cubit.loadChoices();
      cubit.saveAsDefaultChanged(true);
      await cubit.confirm();

      expect(cubit.state.result, isNull);
      expect(cubit.state.isSaving, isFalse);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
    });
  });

  group('the first-use notice', () {
    test('comes once for Close friends, with how many people', () async {
      final cubit = build();
      await cubit.loadChoices();
      cubit.select(ContentAudience.closeFriends);
      await cubit.confirm();

      expect(cubit.state.result?.firstUseNotice, ContentAudience.closeFriends);
      expect(cubit.state.result?.reach, 12);
      verify(() => notices.markSeen(ContentAudience.closeFriends)).called(1);
    });

    test('does not come again once seen', () async {
      when(() => notices.isSeen(ContentAudience.onlyMe)).thenReturn(true);
      final cubit = build();
      await cubit.loadChoices();
      cubit.select(ContentAudience.onlyMe);
      await cubit.confirm();

      expect(cubit.state.result?.firstUseNotice, isNull);
      verifyNever(() => notices.markSeen(any()));
    });

    test('never comes for Public or Followers', () async {
      final cubit = build();
      await cubit.loadChoices();
      cubit.select(ContentAudience.followers);
      await cubit.confirm();
      expect(cubit.state.result?.firstUseNotice, isNull);
    });
  });

  group('Save on an existing post', () {
    test('calls the shared use case for that post', () async {
      final cubit = build(postId: 'p9', audience: ContentAudience.followers);
      await cubit.loadChoices();
      cubit.select(ContentAudience.onlyMe);
      await cubit.confirm();

      verify(() => setAudience(ContentKind.post, 'p9', ContentAudience.onlyMe))
          .called(1);
      expect(cubit.state.result?.audience, ContentAudience.onlyMe);
    });

    test('saving the same audience calls nothing', () async {
      final cubit = build(postId: 'p9', audience: ContentAudience.followers);
      await cubit.loadChoices();
      await cubit.confirm();
      verifyNever(() => setAudience(any(), any(), any()));
      expect(cubit.state.result, isNotNull);
    });

    test('a failure keeps the sheet open on the choice', () async {
      when(() => setAudience(any(), any(), any()))
          .thenThrow(const UnexpectedFailure());
      final cubit = build(postId: 'p9', audience: ContentAudience.followers);
      await cubit.loadChoices();
      cubit.select(ContentAudience.onlyMe);
      await cubit.confirm();

      expect(cubit.state.result, isNull);
      expect(cubit.state.audience, ContentAudience.onlyMe);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
    });
  });

  group('the close friends list', () {
    test('new counts replace the old ones', () async {
      final cubit = build();
      await cubit.loadChoices();
      when(summary.call).thenAnswer(
        (_) async =>
            const AudienceSummaryEntity(followers: 120, closeFriends: 20),
      );
      await cubit.reloadCounts();
      expect(cubit.state.summary.closeFriends, 20);
    });

    test('emptying it moves a Close friends choice to Followers', () async {
      final cubit = build(audience: ContentAudience.closeFriends);
      await cubit.loadChoices();
      when(summary.call)
          .thenAnswer((_) async => const AudienceSummaryEntity(followers: 120));
      await cubit.reloadCounts();
      expect(cubit.state.audience, ContentAudience.followers);
    });

    test('a failed reload leaves the sheet as it is', () async {
      final cubit = build();
      await cubit.loadChoices();
      final before = cubit.state;
      when(summary.call).thenThrow(const UnexpectedFailure());
      await cubit.reloadCounts();
      expect(cubit.state, before);
    });
  });
}
