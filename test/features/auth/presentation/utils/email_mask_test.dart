import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/auth/presentation/utils/email_mask.dart';

void main() {
  test('shows the first 3 characters of the local part', () {
    expect(maskEmail('dipanjan@gmail.com'), 'dip•••@gmail.com');
  });

  test('a short local part is shown whole, then the mask', () {
    expect(maskEmail('ab@x.io'), 'ab•••@x.io');
    expect(maskEmail('abc@x.io'), 'abc•••@x.io');
  });

  test('text without "@" is returned unchanged', () {
    expect(maskEmail('not-an-email'), 'not-an-email');
  });
}
