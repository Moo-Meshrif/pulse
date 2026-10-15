import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/post/presentation/utils/tag_choice.dart';
import 'package:pulse/features/post/presentation/utils/tag_value.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  TagChoice named(String name) =>
      TagChoice(id: name, username: name, fullName: name);

  test('nobody has no value', () {
    expect(tagValue(l10nEn, const []), isNull);
  });

  test('one, two, then the first two and the others', () {
    expect(tagValue(l10nEn, [named('Omar')]), 'Omar');
    expect(tagValue(l10nEn, [named('Omar'), named('Laila')]), 'Omar, Laila');
    expect(
      tagValue(l10nEn, [named('Omar'), named('Laila'), named('Sam')]),
      'Omar, Laila and 1 other',
    );
    expect(
      tagValue(l10nEn, [for (final n in 'abcd'.split('')) named(n)]),
      'a, b and 2 others',
    );
  });

  test('Arabic says it with the Arabic comma and و', () {
    expect(
      tagValue(l10nAr, [named('Omar'), named('Laila'), named('Sam')]),
      'Omar، Laila و1 آخرين',
    );
  });
}
