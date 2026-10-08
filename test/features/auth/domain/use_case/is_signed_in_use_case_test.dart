import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/auth/domain/use_case/is_signed_in_use_case.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  test('is true while a session is stored, false otherwise', () {
    final auth = MockAuthDatasource();
    final useCase = IsSignedInUseCase(auth);

    when(() => auth.hasSession).thenReturn(true);
    expect(useCase(), isTrue);

    when(() => auth.hasSession).thenReturn(false);
    expect(useCase(), isFalse);
  });
}
