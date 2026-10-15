import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/features/post/domain/entity/tag_person_entity.dart';
import 'package:pulse/features/post/domain/use_case/search_tag_people_use_case.dart';
import 'package:pulse/features/post/presentation/cubit/tag_people_cubit.dart';
import 'package:pulse/features/post/presentation/screen/tag_people_screen.dart';
import 'package:pulse/features/post/presentation/utils/new_post_limits.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_people_args.dart';
import 'package:pulse/features/post/presentation/utils/tag_photo.dart';

import '../../../../helpers/pump_app.dart';

class _Search extends Mock implements SearchTagPeopleUseCase {}

/// A widget test with the semantics tree on, so labels can be found.
void semanticTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) => testWidgets(description, (tester) async {
  final semantics = tester.ensureSemantics();
  try {
    await body(tester);
  } finally {
    semantics.dispose();
  }
});

void main() {
  late _Search search;
  Object? result;

  const omar = TagPersonEntity(
    id: 'u1',
    username: 'omarkh',
    fullName: 'Omar Khaled',
    canTag: true,
  );
  const laila = TagPersonEntity(
    id: 'u2',
    username: 'laila.fouad',
    fullName: 'Laila Fouad',
    canTag: true,
  );
  const sam = TagPersonEntity(
    id: 'u3',
    username: 'sam',
    fullName: 'Sam Private',
    canTag: false,
  );
  const photos = [TagPhoto(position: 0, isVideo: false)];

  setUp(() async {
    await getIt.reset();
    result = null;
    search = _Search();
    when(() => search(any())).thenAnswer((_) async => [omar, laila, sam]);
    getIt.registerFactoryParam<TagPeopleCubit, TagPeopleArgs, void>(
      (args, _) => TagPeopleCubit(search, args),
    );
    addTearDown(() {
      getIt.reset();
      Notices.clear();
    });
  });

  Future<void> open(
    WidgetTester tester, {
    List<TagChoice> chosen = const [],
    List<TagPhoto> media = photos,
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await Navigator.of(context).push<Object>(
                  MaterialPageRoute<Object>(
                    builder: (_) => TagPeopleScreen(
                      args: TagPeopleArgs(chosen: chosen, photos: media),
                    ),
                  ),
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

  semanticTest('shows the suggested people with a counter and checks', (
    tester,
  ) async {
    await open(tester);

    expect(find.text(l10nEn.postTagPeopleTitle), findsOneWidget);
    expect(find.text('SUGGESTED'), findsOneWidget);
    expect(find.text(l10nEn.postTagPeopleCounter(0, 20)), findsOneWidget);
    expect(find.text('Omar Khaled'), findsOneWidget);
    expect(find.text('@laila.fouad'), findsOneWidget);
    expect(find.text(l10nEn.postTagPeopleNoTags), findsOneWidget);
  });

  semanticTest('a tap chooses a person: a chip, the counter and Done', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Omar Khaled'));
    await tester.pump();

    expect(
      find.bySemanticsLabel(l10nEn.postTagPeopleRemoveChip('Omar Khaled')),
      findsOneWidget,
    );
    expect(find.text(l10nEn.postTagPeopleCounter(1, 20)), findsOneWidget);

    await tester.tap(find.text(l10nEn.postTagPeopleDone));
    await tester.pumpAndSettle();

    expect((result! as List<TagChoice>).map((c) => c.id), ['u1']);
  });

  semanticTest('a chip × takes the person off', (tester) async {
    await open(tester);
    await tester.tap(find.text('Omar Khaled'));
    await tester.pump();

    await tester.tap(
      find.bySemanticsLabel(l10nEn.postTagPeopleRemoveChip('Omar Khaled')),
    );
    await tester.pump();

    expect(find.text(l10nEn.postTagPeopleCounter(0, 20)), findsOneWidget);
  });

  semanticTest('someone who does not allow tags cannot be picked', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text('Sam Private'));
    await tester.pump();

    expect(find.text(l10nEn.postTagPeopleCounter(0, 20)), findsOneWidget);
  });

  semanticTest('at 20 people the counter is red and a pick says so', (
    tester,
  ) async {
    final chosen = [
      for (var i = 0; i < TagLimits.maxPeople; i++)
        TagChoice(id: 'c$i', username: 'c$i'),
    ];
    await open(tester, chosen: chosen);

    await tester.tap(find.text('Omar Khaled'));
    await tester.pump();

    expect(find.text(l10nEn.postTagPeopleCounter(20, 20)), findsOneWidget);
    expect(
      Notices.current.value?.title,
      l10nEn.postTagPeopleMax(TagLimits.maxPeople),
    );
  });

  semanticTest('"Tag in photo" shows only with photos and waits for a person', (
    tester,
  ) async {
    await open(tester);
    expect(find.text(l10nEn.postTagPeopleInPhoto), findsOneWidget);
    final off = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.text(l10nEn.postTagPeopleInPhoto),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(off.opacity, lessThan(1));

    await tester.tap(find.text('Omar Khaled'));
    await tester.pump();
    final on = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.text(l10nEn.postTagPeopleInPhoto),
            matching: find.byType(Opacity),
          )
          .first,
    );
    expect(on.opacity, 1);
  });

  semanticTest('no photos, no "Tag in photo"', (tester) async {
    await open(tester, media: const []);
    expect(find.text(l10nEn.postTagPeopleInPhoto), findsNothing);
  });

  semanticTest('no matches shows the empty state', (tester) async {
    await open(tester);
    when(() => search('zzz')).thenAnswer((_) async => []);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(TagLimits.searchDelay + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.postTagPeopleEmpty), findsOneWidget);
    expect(find.text('SUGGESTED'), findsNothing);
  });

  semanticTest('a failed load says so with Retry', (tester) async {
    when(() => search(any()))
        .thenAnswer((_) async => throw const NetworkFailure());
    await open(tester);

    expect(Notices.current.value?.title, l10nEn.postTagPeopleError);
    expect(Notices.current.value?.actionLabel, l10nEn.retry);
  });

  semanticTest('back leaves at once when nothing changed', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.postTagPeopleTitle), findsNothing);
  });

  semanticTest('back asks when something changed', (tester) async {
    await open(tester);
    await tester.tap(find.text('Omar Khaled'));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.editPostDiscardTitle), findsOneWidget);

    await tester.tap(find.text(l10nEn.newPostKeepEditing));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.postTagPeopleTitle), findsOneWidget);
  });

  semanticTest('Arabic mirrors and 1.5x text does not overflow', (
    tester,
  ) async {
    await open(
      tester,
      chosen: const [
        TagChoice(id: 'c1', username: 'c1', fullName: 'Omar Khaled'),
        TagChoice(id: 'c2', username: 'c2', fullName: 'Laila Fouad'),
      ],
      locale: const Locale('ar'),
      textScale: 1.5,
    );

    expect(find.text(l10nAr.postTagPeopleTitle), findsOneWidget);
    final done = tester.getCenter(find.text(l10nAr.postTagPeopleDone)).dx;
    final title = tester.getCenter(find.text(l10nAr.postTagPeopleTitle)).dx;
    expect(done, lessThan(title));
    expect(tester.takeException(), isNull);
  });
}
