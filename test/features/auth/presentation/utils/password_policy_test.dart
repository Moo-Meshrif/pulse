import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/presentation/utils/password_policy.dart';

void main() {
  group('PasswordPolicy.score counts length, mixed case, digit and symbol', () {
    final cases = <String, int>{
      '': 0,
      'abc': 0,
      'abcdefgh': 1, // length only
      'abcdefgH': 2, // length + mixed case
      'abcdefH1': 3, // + digit
      'abcdefH1!': 4, // + symbol
      'Ab1!': 3, // short, but mixed case + digit + symbol
    };
    cases.forEach((password, score) {
      test('"$password" -> $score', () {
        expect(PasswordPolicy.score(password), score);
      });
    });
  });

  test('a space is not a symbol', () {
    expect(PasswordPolicy.hasSymbol('a b'), isFalse);
    expect(PasswordPolicy.hasSymbol('a_b'), isTrue);
  });

  test('reset rules: length, a digit and both cases', () {
    expect(PasswordPolicy.meetsResetRules('Abcdefg1'), isTrue);
    expect(PasswordPolicy.meetsResetRules('abcdefg1'), isFalse);
    expect(PasswordPolicy.meetsResetRules('Abcdefgh'), isFalse);
    expect(PasswordPolicy.meetsResetRules('Abc1'), isFalse);
  });
}
