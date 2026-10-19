import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/report_reason.dart';
import 'package:pulse/features/post/data/datasource/visibility_notice_datasource.dart';
import 'package:pulse/features/post/presentation/cubit/post_visibility/post_visibility_cubit.dart';
import 'package:pulse/features/post/presentation/utils/post_options_actions.dart';
import 'package:pulse/features/post/presentation/utils/post_options_data.dart';
import 'package:pulse/features/post/presentation/utils/post_visibility_result.dart';
import 'package:pulse/features/post/presentation/widgets/add_edit_post/visibility_chip.dart';
import 'package:pulse/features/post/presentation/widgets/post_options/post_options_flow.dart';
import 'package:pulse/features/post/presentation/widgets/post_visibility/post_visibility_sheet.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/enums/content_kind.dart';
import 'package:pulse/shared/content/domain/entity/audience_summary_entity.dart';
import 'package:pulse/shared/content/domain/entity/privacy_entity.dart';
import 'package:pulse/shared/content/domain/use_case/get_audience_summary_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/get_privacy_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/save_default_audience_use_case.dart';
import 'package:pulse/shared/content/domain/use_case/set_content_audience_use_case.dart';

import '../../../../../helpers/pump_app.dart';

class _Privacy extends Mock implements GetPrivacyUseCase {}

class _Summary extends Mock implements GetAudienceSummaryUseCase {}

class _SaveDefault extends Mock implements SaveDefaultAudienceUseCase {}

class _SetAudience extends Mock implements SetContentAudienceUseCase {}

class _Notices extends Mock implements VisibilityNoticeDatasource {}

void main() {
  late _Privacy privacy;
  late _SetAudience setAudience;
  PostVisibilityResult? result;
  final changed = <ContentAudience>[];

  setUpAll(() {
    registerFallbackValue(ContentAudience.public);
    registerFallbackValue(ContentKind.post);
  });

  setUp(() async {
    await getIt.reset();
    result = null;
    changed.clear();
    privacy = _Privacy();
    setAudience = _SetAudience();
    final summary = _Summary();
    final saveDefault = _SaveDefault();
    final notices = _Notices();
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
    when(() => notices.isSeen(any())).thenReturn(true);
    getIt.registerFactoryParam<PostVisibilityCubit, String?, ContentAudience>(
      (postId, audience) => PostVisibilityCubit(
        privacy,
        summary,
        saveDefault,
        setAudience,
        notices,
        postId,
        audience,
      ),
    );
  });

  tearDown(getIt.reset);

  Future<void> openPicker(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
    Size size = const Size(390, 844),
  }) async {
    setUpView(tester, textScale: textScale, size: size);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await PostVisibilitySheet.choose(
              context,
              audience: ContentAudience.public,
            ),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the four audiences with their numbers and Done', (
    tester,
  ) async {
    await openPicker(tester);
    expect(find.text(l10nEn.postVisibilityTitle), findsOneWidget);
    expect(find.text(l10nEn.postAudiencePublic), findsOneWidget);
    expect(find.text(l10nEn.postVisibilityPeople(120)), findsOneWidget);
    expect(find.text(l10nEn.postVisibilityPeople(12)), findsOneWidget);
    expect(find.text(l10nEn.postAudienceOnlyMe), findsOneWidget);
    expect(find.text(l10nEn.postVisibilityEdit), findsOneWidget);
    expect(find.text(l10nEn.postVisibilityFuture), findsOneWidget);
    expect(find.text(l10nEn.postVisibilityDone), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        '${l10nEn.postAudiencePublic}, ${l10nEn.postVisibilityPublicHint}',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a private account sees the note and a disabled Public', (
    tester,
  ) async {
    when(privacy.call).thenAnswer(
      (_) async => const PrivacyEntity(
        isPrivate: true,
        defaultVisibility: ContentAudience.followers,
      ),
    );
    await openPicker(tester);

    expect(
      find.textContaining(l10nEn.postVisibilityPrivateNote),
      findsOneWidget,
    );
    expect(find.text(l10nEn.postVisibilityPublicOff), findsOneWidget);
    await tester.tap(find.text(l10nEn.postAudiencePublic));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.postVisibilityDone));
    await tester.pumpAndSettle();
    expect(result?.audience, ContentAudience.followers);
  });

  testWidgets('choosing a row and pressing Done hands the choice back', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.tap(find.text(l10nEn.postAudienceOnlyMe));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10nEn.postVisibilityDone));
    await tester.pumpAndSettle();

    expect(result?.audience, ContentAudience.onlyMe);
    expect(find.text(l10nEn.postVisibilityTitle), findsNothing);
  });

  testWidgets('closing the sheet hands back nothing', (tester) async {
    await openPicker(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('Arabic at 1.5x text does not overflow', (tester) async {
    await openPicker(tester, locale: const Locale('ar'), textScale: 1.5);
    expect(find.text(l10nAr.postVisibilityTitle), findsOneWidget);
    expect(find.text(l10nAr.postVisibilityDone), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a 320 dp phone at 2.0x text, EN and AR, does not overflow', (
    tester,
  ) async {
    for (final locale in const [Locale('en'), Locale('ar')]) {
      await tester.pumpWidget(const SizedBox());
      await openPicker(
        tester,
        locale: locale,
        textScale: 2,
        size: const Size(320, 640),
      );
      expect(tester.takeException(), isNull, reason: locale.languageCode);
    }
  });

  group('the chip', () {
    Future<void> showChip(WidgetTester tester, {required bool narrowed}) async {
      setUpView(tester);
      await tester.pumpApp(
        Scaffold(
          body: VisibilityChip(
            audience: ContentAudience.closeFriends,
            isNarrowed: narrowed,
          ),
        ),
      );
    }

    Color? fill(WidgetTester tester) =>
        ((tester.widget<Container>(
                  find
                      .descendant(
                        of: find.byType(VisibilityChip),
                        matching: find.byType(Container),
                      )
                      .first,
                )).decoration!
                as BoxDecoration)
            .color;

    testWidgets('is the plain chip by default', (tester) async {
      await showChip(tester, narrowed: false);
      expect(fill(tester), const Color(0xFFF3F4F3));
      expect(find.text(l10nEn.postAudienceCloseFriends), findsOneWidget);
    });

    testWidgets('turns primary soft when narrower than the default', (
      tester,
    ) async {
      await showChip(tester, narrowed: true);
      expect(fill(tester), const Color(0xFFE2EEEB));
    });
  });

  group('Change who can see', () {
    Future<void> openFromOptions(WidgetTester tester) async {
      setUpView(tester);
      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => PostOptionsFlow.show(
                context,
                data: const PostOptionsData(
                  postId: 'p9',
                  isMine: true,
                  username: 'me',
                  visibility: ContentAudience.followers,
                ),
                actions: PostOptionsActions(
                  onSave: () async {},
                  onNotInterested: () async {},
                  onUnfollow: () async {},
                  onUndoUnfollow: () async {},
                  onMute: () async {},
                  onUndoMute: () async {},
                  onReport: (ReportReason reason, String? note) async {},
                  onToggleComments: () async {},
                  onDelete: () {},
                  onUndoDelete: () {},
                  onCommitDelete: () {},
                  onAudienceChanged: changed.add,
                  onEdit: () {},
                  onRemoveMyTag: () async {},
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.postChangeWhoCanSee));
      await tester.pumpAndSettle();
    }

    testWidgets('shows what the post has now and a footer, no toggle', (
      tester,
    ) async {
      await openFromOptions(tester);
      expect(
        find.text(l10nEn.postVisibilityCurrently(l10nEn.postAudienceFollowers)),
        findsOneWidget,
      );
      expect(find.text(l10nEn.postVisibilityKeptNote), findsOneWidget);
      expect(find.text(l10nEn.postVisibilityFuture), findsNothing);
      expect(find.text(l10nEn.postVisibilitySave), findsOneWidget);
    });

    testWidgets(
      'Save changes the post, tells the list and says Visibility updated',
      (tester) async {
        await openFromOptions(tester);
        await tester.tap(find.text(l10nEn.postAudienceOnlyMe));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10nEn.postVisibilitySave));
        await tester.pumpAndSettle();

        verify(
          () => setAudience(ContentKind.post, 'p9', ContentAudience.onlyMe),
        ).called(1);
        expect(changed, [ContentAudience.onlyMe]);
        expect(find.text(l10nEn.postVisibilityUpdated), findsOneWidget);
      },
    );

    testWidgets('closing without a change tells nobody', (tester) async {
      await openFromOptions(tester);
      await tester.tap(find.bySemanticsLabel(l10nEn.close));
      await tester.pumpAndSettle();
      expect(changed, isEmpty);
      expect(find.text(l10nEn.postVisibilityUpdated), findsNothing);
    });
  });
}
