import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/follow/data/enums/follow_status.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/post/data/enums/follow_state.dart';
import 'package:pulse/features/post/domain/entity/tagged_person_entity.dart';
import 'package:pulse/features/post/domain/use_case/get_tagged_people_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/tagged_people_cubit.dart';
import 'package:pulse/features/post/presentation/utils/tagged_people_result.dart';
import 'package:pulse/features/post/presentation/widgets/tagged_people/tagged_people_sheet.dart';

import '../../../../helpers/pump_app.dart';

class _GetPeople extends Mock implements GetTaggedPeopleUseCase {}

class _Follow extends Mock implements ToggleFollowUseCase {}

void main() {
  late _GetPeople getPeople;
  late _Follow follow;
  TaggedPeopleResult? result;

  const people = [
    TaggedPersonEntity(
      id: 'me',
      username: 'me',
      fullName: 'Mona Me',
      followState: FollowState.me,
    ),
    TaggedPersonEntity(
      id: 'u2',
      username: 'omarkh',
      fullName: 'Omar Khaled',
      followState: FollowState.following,
    ),
    TaggedPersonEntity(
      id: 'u3',
      username: 'laila.fouad',
      fullName: 'Laila Fouad',
      followState: FollowState.none,
    ),
    TaggedPersonEntity(
      id: 'u4',
      username: 'yousef.s',
      followState: FollowState.pending,
    ),
  ];

  setUp(() async {
    await getIt.reset();
    result = null;
    getPeople = _GetPeople();
    follow = _Follow();
    when(() => getPeople('p1')).thenAnswer((_) async => people);
    getIt.registerFactoryParam<TaggedPeopleCubit, String, void>(
      (postId, _) => TaggedPeopleCubit(getPeople, follow, postId),
    );
    addTearDown(getIt.reset);
  });

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await TaggedPeopleSheet.show(context, postId: 'p1'),
            child: const Text('open'),
          ),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists everyone with their name, @username and pill', (
    tester,
  ) async {
    await open(tester);

    expect(find.text(l10nEn.postTaggedPeopleTitle), findsOneWidget);
    expect(find.text('Omar Khaled'), findsOneWidget);
    expect(find.text('@omarkh'), findsOneWidget);
    expect(find.text('yousef.s'), findsOneWidget);
    expect(find.text(l10nEn.postTaggedFollowing), findsOneWidget);
    expect(find.text(l10nEn.postTaggedFollow), findsOneWidget);
    expect(find.text(l10nEn.postTaggedRequested), findsOneWidget);
    expect(find.text(l10nEn.postTagRemoveConfirm), findsOneWidget);
  });

  testWidgets('Follow updates in place', (tester) async {
    when(() => follow('u3', follow: true))
        .thenAnswer((_) async => FollowStatus.accepted);
    await open(tester);

    await tester.tap(find.text(l10nEn.postTaggedFollow));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.postTaggedFollow), findsNothing);
    expect(find.text(l10nEn.postTaggedFollowing), findsNWidgets(2));
  });

  testWidgets('a failed follow goes back and says so', (tester) async {
    when(() => follow('u3', follow: true)).thenThrow(const NetworkFailure());
    await open(tester);

    await tester.tap(find.text(l10nEn.postTaggedFollow));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.postTaggedFollow), findsOneWidget);
    expect(find.text(l10nEn.errorNetwork), findsOneWidget);
  });

  testWidgets('a row opens the profile, your own pill asks to remove', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Omar Khaled'));
    await tester.pumpAndSettle();
    expect(result, const TaggedPeopleResult.profile('u2'));

    await open(tester);
    await tester.tap(find.text(l10nEn.postTagRemoveConfirm));
    await tester.pumpAndSettle();
    expect(result, const TaggedPeopleResult.removeMe());
  });

  testWidgets('a list that fails to load can be retried', (tester) async {
    when(() => getPeople('p1')).thenThrow(const NetworkFailure());
    await open(tester);
    expect(find.text(l10nEn.postTaggedLoadError), findsOneWidget);

    when(() => getPeople('p1')).thenAnswer((_) async => people);
    await tester.tap(find.text(l10nEn.retry));
    await tester.pumpAndSettle();

    expect(find.text('Omar Khaled'), findsOneWidget);
  });

  testWidgets('Arabic: pills are at the left, and 1.5x text fits', (
    tester,
  ) async {
    await open(tester, locale: const Locale('ar'), textScale: 1.5);

    final name = tester.getCenter(find.text('Omar Khaled')).dx;
    final pill = tester.getCenter(find.text(l10nAr.postTaggedFollowing)).dx;
    expect(pill, lessThan(name));
    expect(tester.takeException(), isNull);
  });
}
