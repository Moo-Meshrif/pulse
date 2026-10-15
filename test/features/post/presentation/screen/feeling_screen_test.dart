import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/domain/entity/post_mood_entity.dart';
import 'package:pulse/features/post/presentation/screen/feeling_screen.dart';
import 'package:pulse/features/post/presentation/utils/mood_choice.dart';
import 'package:pulse/features/post/presentation/utils/post_feeling.dart';

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
  const happy = PostMoodEntity(kind: MoodKind.feeling, key: 'happy');

  setUp(() => result = null);
  tearDown(Notices.clear);

  Future<void> open(
    WidgetTester tester, {
    PostMoodEntity? current,
    Locale locale = const Locale('en'),
    double textScale = 1,
  }) async {
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await Navigator.of(context)
                .push<Object>(
                  MaterialPageRoute<Object>(
                    builder: (_) => FeelingScreen(current: current),
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

  semanticTest('shows the 14 feelings with their emoji and words', (
    tester,
  ) async {
    await open(tester);
    tester.view.physicalSize = const Size(390, 2400);
    await tester.pump();

    expect(find.text(l10nEn.postFeelingTitle), findsOneWidget);
    for (final key in postFeelingKeys) {
      expect(find.text(feelingEmoji(key)!), findsOneWidget);
      expect(find.text(feelingWord(l10nEn, key)!), findsOneWidget);
    }
    expect(find.text(l10nEn.postFeelingRemove), findsNothing);
  });

  semanticTest('a tap goes back with that feeling at once', (tester) async {
    await open(tester);

    await tester.tap(find.text(l10nEn.postFeelingExcited));
    await tester.pumpAndSettle();

    expect(
      result,
      const MoodChoice(PostMoodEntity(kind: MoodKind.feeling, key: 'excited')),
    );
  });

  semanticTest('the chosen one is marked, and a tap on it clears it', (
    tester,
  ) async {
    await open(tester, current: happy);
    expect(
      find.bySemanticsLabel(
        l10nEn.postFeelingSelected(l10nEn.postFeelingHappy),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(l10nEn.postFeelingHappy));
    await tester.pumpAndSettle();

    expect(result, const MoodChoice(null));
  });

  semanticTest('Remove shows only with a mood and clears it', (tester) async {
    await open(tester, current: happy);

    await tester.tap(find.text(l10nEn.postFeelingRemove));
    await tester.pumpAndSettle();

    expect(result, const MoodChoice(null));
  });

  semanticTest('back goes back with nothing', (tester) async {
    await open(tester, current: happy);

    await tester.tap(find.bySemanticsLabel(l10nEn.back));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(find.text(l10nEn.postFeelingTitle), findsNothing);
  });

  semanticTest('another feeling replaces the current one', (tester) async {
    await open(tester, current: happy);

    await tester.tap(find.text(l10nEn.postFeelingSad));
    await tester.pumpAndSettle();

    expect(
      result,
      const MoodChoice(PostMoodEntity(kind: MoodKind.feeling, key: 'sad')),
    );
  });

  semanticTest('search finds by name, by a synonym and by an Arabic word', (
    tester,
  ) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'tir');
    await tester.pump();
    expect(find.text(l10nEn.postFeelingTired), findsOneWidget);
    expect(find.text(l10nEn.postFeelingHappy), findsNothing);

    await tester.enterText(find.byType(TextField), 'lol');
    await tester.pump();
    expect(find.text(l10nEn.postFeelingFunny), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'حزن');
    await tester.pump();
    expect(find.text(l10nEn.postFeelingSad), findsOneWidget);
  });

  semanticTest('no match says so', (tester) async {
    await open(tester);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.text(l10nEn.postFeelingNoMatches), findsOneWidget);
  });

  semanticTest('Activities says coming soon and stays on Feelings', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(find.text(l10nEn.postFeelingTabActivities));
    await tester.pump();

    expect(Notices.current.value?.title, l10nEn.comingSoon);
    expect(find.text(l10nEn.postFeelingHappy), findsOneWidget);
    expect(result, isNull);
  });

  semanticTest('Arabic uses nouns, mirrors, and 1.5x text fits', (
    tester,
  ) async {
    await open(
      tester,
      current: happy,
      locale: const Locale('ar'),
      textScale: 1.5,
    );

    expect(find.text(l10nAr.postFeelingHappy), findsOneWidget);
    final first = tester.getCenter(find.text(l10nAr.postFeelingHappy)).dx;
    final second = tester.getCenter(find.text(l10nAr.postFeelingExcited)).dx;
    expect(first, greaterThan(second));
    expect(tester.takeException(), isNull);
  });
}
