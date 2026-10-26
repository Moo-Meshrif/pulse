import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/domain/entity/mention_person_entity.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_body.dart';
import 'package:pulse/features/post/presentation/widgets/comments/comment_mention_list.dart';

import '../../../../../helpers/pump_app.dart';

const people = [
  MentionPersonEntity(id: 'u1', username: 'sara.k', fullName: 'Sara Khan'),
  MentionPersonEntity(id: 'u2', username: 'omar'),
  MentionPersonEntity(id: 'u3', username: 'lina'),
];

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    testWidgets('the list shows 3 rows and picks (${locale.languageCode})', (
      tester,
    ) async {
      setUpView(tester, textScale: 1.5);
      MentionPersonEntity? picked;
      await tester.pumpApp(
        Scaffold(
          body: CommentMentionList(people: people, onPick: (p) => picked = p),
        ),
        locale: locale,
      );
      expect(find.text('@sara.k'), findsOneWidget);
      expect(find.text('@omar'), findsOneWidget);
      expect(find.text('@lina'), findsOneWidget);
      await tester.tap(find.text('@omar'));
      expect(picked, people[1]);
    });

    testWidgets('a comment draws its @name apart (${locale.languageCode})', (
      tester,
    ) async {
      setUpView(tester);
      await tester.pumpApp(
        const Scaffold(body: CommentBody('hi @sara.k welcome')),
        locale: locale,
      );
      final text = tester.widget<Text>(find.byType(Text).first);
      final spans = (text.textSpan! as TextSpan).children!;
      expect(spans, hasLength(3));
      expect((spans[1] as TextSpan).recognizer, isNotNull);
      expect((spans[1] as TextSpan).semanticsLabel, '@sara.k');
    });
  }
}
