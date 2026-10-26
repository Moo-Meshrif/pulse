import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/mention_query.dart';

TextEditingValue at(String text, [int? cursor]) => TextEditingValue(
  text: text,
  selection: TextSelection.collapsed(offset: cursor ?? text.length),
);

void main() {
  test('finds the @word at the cursor', () {
    final query = MentionQuery.find(at('hi @sa'))!;
    expect(query.text, 'sa');
    expect(query.start, 3);
  });

  test('is null for a bare @, an email, no @ or a selection', () {
    expect(MentionQuery.find(at('hi @')), isNull);
    expect(MentionQuery.find(at('mail me@site')), isNull);
    expect(MentionQuery.find(at('hello')), isNull);
    expect(
      MentionQuery.find(
        const TextEditingValue(
          text: '@sam',
          selection: TextSelection(baseOffset: 0, extentOffset: 4),
        ),
      ),
      isNull,
    );
  });

  test('is null once a space follows the word', () {
    expect(MentionQuery.find(at('@sam ')), isNull);
  });

  test('uses only the text before the cursor', () {
    expect(MentionQuery.find(at('@sam and more', 4))!.text, 'sam');
  });

  test('pick replaces the typed part and keeps the rest', () {
    final value = at('hi @sa there', 6);
    final result = MentionQuery.find(value)!.pick(value, 'sara.k');
    expect(result.text, 'hi @sara.k  there');
    expect(result.selection.baseOffset, 11);
  });
}
