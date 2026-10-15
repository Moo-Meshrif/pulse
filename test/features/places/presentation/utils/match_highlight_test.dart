import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/places/presentation/utils/match_highlight.dart';

void main() {
  test('the typed part is cut out of the name, whatever its case', () {
    final match = MatchHighlight.of('Karnak Temple', 'kar');
    expect(match.before, '');
    expect(match.match, 'Kar');
    expect(match.after, 'nak Temple');
  });

  test('a match in the middle keeps both sides', () {
    final match = MatchHighlight.of('Cairo Tower', ' tow ');
    expect([match.before, match.match, match.after], ['Cairo ', 'Tow', 'er']);
  });

  test('no match leaves the whole name plain', () {
    final match = MatchHighlight.of('Zamalek', 'xyz');
    expect(match.hasMatch, isFalse);
    expect(match.before, 'Zamalek');
  });

  test('an empty query matches nothing', () {
    expect(MatchHighlight.of('Zamalek', '  ').hasMatch, isFalse);
  });

  test('works for Arabic', () {
    final match = MatchHighlight.of('الزمالك', 'زم');
    expect([match.before, match.match, match.after], ['ال', 'زم', 'الك']);
  });
}
