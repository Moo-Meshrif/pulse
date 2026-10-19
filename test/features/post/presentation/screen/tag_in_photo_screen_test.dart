import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/features/post/presentation/cubit/tag_in_photo/tag_in_photo_cubit.dart';
import 'package:pulse/features/post/presentation/screen/tag_in_photo_screen.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_people_args.dart';
import 'package:pulse/features/post/presentation/utils/tag_photo.dart';
import 'package:pulse/features/post/presentation/widgets/tag_in_photo/tag_photo_canvas.dart';

import '../../../../helpers/pump_app.dart';

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
  Object? result;

  const omar = TagChoice(id: 'u1', username: 'omarkh', fullName: 'Omar Khaled');
  const laila = TagChoice(id: 'u2', username: 'laila', fullName: 'Laila Fouad');
  const photos = [
    TagPhoto(position: 0, isVideo: false, aspect: 1),
    TagPhoto(position: 1, isVideo: true),
    TagPhoto(position: 2, isVideo: false, aspect: 1),
  ];

  setUp(() async {
    await getIt.reset();
    result = null;
    getIt.registerFactoryParam<TagInPhotoCubit, TagPeopleArgs, void>(
      (args, _) => TagInPhotoCubit(args),
    );
    addTearDown(getIt.reset);
  });

  Future<void> open(
    WidgetTester tester, {
    List<TagChoice> chosen = const [omar, laila],
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
                    builder: (_) => TagInPhotoScreen(
                      args: TagPeopleArgs(chosen: chosen, photos: photos),
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

  Future<void> tapPhoto(WidgetTester tester, {double dx = 0, double dy = 0}) =>
      tester.tapAt(
        tester.getCenter(find.byType(TagPhotoCanvas)) + Offset(dx, dy),
      );

  semanticTest('shows the hint, the counter, the thumbs and the no-spot card', (
    tester,
  ) async {
    await open(tester);

    expect(find.text(l10nEn.postTagInPhotoHint), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(
      find.bySemanticsLabel(l10nEn.postTagInPhotoThumb(1, 0)),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(l10nEn.postTagInPhotoThumb(2, 0)),
      findsOneWidget,
    );
    expect(find.text(l10nEn.postTagInPhotoNoSpotMany(2)), findsOneWidget);
  });

  semanticTest(
    'a tap opens the list of people, a pick puts their label there',
    (tester) async {
      await open(tester);

      await tapPhoto(tester);
      await tester.pumpAndSettle();
      expect(find.text('@omarkh'), findsOneWidget);
      expect(find.text('@laila'), findsOneWidget);

      await tester.tap(find.text('Omar Khaled'));
      await tester.pumpAndSettle();

      expect(find.text('omarkh'), findsOneWidget);
      expect(
        find.text(l10nEn.postTagInPhotoNoSpot('Laila Fouad')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(l10nEn.postTagInPhotoThumb(1, 1)),
        findsOneWidget,
      );
    },
  );

  semanticTest('the list filters, and dismissing it leaves no label', (
    tester,
  ) async {
    await open(tester);
    await tapPhoto(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'lai');
    await tester.pump();
    expect(find.text('@omarkh'), findsNothing);
    expect(find.text('@laila'), findsOneWidget);

    await tester.tapAt(const Offset(200, 20));
    await tester.pumpAndSettle();

    expect(find.text('omarkh'), findsNothing);
    expect(find.text('laila'), findsNothing);
  });

  semanticTest('a label can be dragged, and its × takes the spot off', (
    tester,
  ) async {
    await open(tester, chosen: [omar.withSpot(0, 0.5, 0.5), laila]);
    expect(find.text('omarkh'), findsOneWidget);
    final before = tester.getCenter(find.text('omarkh'));

    await tester.drag(find.text('omarkh'), const Offset(30, 20));
    await tester.pump();

    final after = tester.getCenter(find.text('omarkh'));
    expect(after.dx, greaterThan(before.dx));
    expect(after.dy, greaterThan(before.dy));

    await tester.tap(
      find.bySemanticsLabel(l10nEn.postTagInPhotoRemoveSpot('Omar Khaled')),
    );
    await tester.pump();

    expect(find.text('omarkh'), findsNothing);
    expect(find.text(l10nEn.postTagInPhotoNoSpotMany(2)), findsOneWidget);
  });

  semanticTest('a label never leaves the photo', (tester) async {
    await open(tester, chosen: [omar.withSpot(0, 0.5, 0.5), laila]);

    await tester.drag(find.text('omarkh'), const Offset(2000, 2000));
    await tester.pump();

    final photo = tester.getRect(find.byType(TagPhotoCanvas));
    final spot = tester.getCenter(find.text('omarkh'));
    expect(spot.dx, lessThanOrEqualTo(photo.right));
    expect(spot.dy, lessThanOrEqualTo(photo.bottom));
  });

  semanticTest('the thumbs switch the photo and the counter follows', (
    tester,
  ) async {
    await open(tester, chosen: [omar.withSpot(2, 0.5, 0.5), laila]);
    expect(find.text('omarkh'), findsNothing);

    await tester.tap(find.bySemanticsLabel(l10nEn.postTagInPhotoThumb(2, 1)));
    await tester.pump();

    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('omarkh'), findsOneWidget);
  });

  semanticTest('Done goes back with the spots', (tester) async {
    await open(tester);
    await tapPhoto(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Omar Khaled'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10nEn.postTagPeopleDone));
    await tester.pumpAndSettle();

    final chosen = result! as List<TagChoice>;
    expect(chosen.first.mediaPosition, 0);
    expect(chosen.first.x, closeTo(0.5, 0.05));
    expect(chosen.last.hasSpot, isFalse);
  });

  semanticTest('back asks only when something changed', (tester) async {
    await open(tester);
    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.postTagInPhotoTitle), findsNothing);
  });

  semanticTest('back with unsaved spots asks to discard', (tester) async {
    await open(tester, chosen: [omar.withSpot(0, 0.5, 0.5), laila]);
    await tester.tap(
      find.bySemanticsLabel(l10nEn.postTagInPhotoRemoveSpot('Omar Khaled')),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();

    expect(find.text(l10nEn.editPostDiscardTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.newPostDiscard));
    await tester.pumpAndSettle();
    expect(find.text(l10nEn.postTagInPhotoTitle), findsNothing);
    expect(result, isNull);
  });

  semanticTest('Arabic keeps the spot where it was drawn, 1.5x fits', (
    tester,
  ) async {
    await open(
      tester,
      chosen: [omar.withSpot(0, 0.25, 0.5), laila],
      locale: const Locale('ar'),
      textScale: 1.5,
    );

    final photo = tester.getRect(find.byType(TagPhotoCanvas));
    final label = tester.getCenter(find.text('omarkh'));
    expect(label.dx, lessThan(photo.center.dx));
    expect(tester.takeException(), isNull);
  });
}
