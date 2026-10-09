import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/presentation/utils/avatar_initials.dart';

void main() {
  group('initialsOf', () {
    test('takes the first letters of the first two words', () {
      expect(initialsOf('Salma Kamal'), 'SK');
      expect(initialsOf('  ada   king lovelace '), 'AK');
    });

    test('a single word gives one letter, nothing gives none', () {
      expect(initialsOf('Cy'), 'C');
      expect(initialsOf(''), '');
      expect(initialsOf(null), '');
    });
  });

  group('stablePaletteIndex', () {
    test('is the same for the same seed and inside the palette', () {
      expect(stablePaletteIndex('user-1', 6), stablePaletteIndex('user-1', 6));
      for (final seed in ['a', 'b', 'user-2', '', null]) {
        expect(stablePaletteIndex(seed, 6), inInclusiveRange(0, 5));
      }
    });
  });
}
