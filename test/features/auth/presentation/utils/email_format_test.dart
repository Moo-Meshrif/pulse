import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/presentation/utils/email_format.dart';

void main() {
  test('accepts addresses', () {
    for (final email in ['ada@example.com', ' ada.l+x@mail.co.uk ', 'a@b.io']) {
      expect(isValidEmail(email), isTrue, reason: email);
    }
  });

  test('refuses text that is not an address', () {
    for (final email in [
      '',
      'ada',
      'ada@',
      '@example.com',
      'ada@example',
      'ada@example.',
      'ada @example.com',
      'ada@@example.com',
    ]) {
      expect(isValidEmail(email), isFalse, reason: email);
    }
  });
}
