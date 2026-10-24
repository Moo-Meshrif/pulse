import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/use_case/is_signup_done_on_device_use_case.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late MockProfileRepository profiles;
  late IsSignupDoneOnDeviceUseCase useCase;

  setUp(() {
    profiles = MockProfileRepository();
    useCase = IsSignupDoneOnDeviceUseCase(profiles);
  });

  test('is true only when the saved step is complete', () {
    when(() => profiles.savedSignupStep()).thenReturn(SignupStep.complete);
    expect(useCase(), isTrue);
  });

  test('is false for a missing step or no saved copy', () {
    when(() => profiles.savedSignupStep()).thenReturn(SignupStep.interests);
    expect(useCase(), isFalse);
    when(() => profiles.savedSignupStep()).thenReturn(null);
    expect(useCase(), isFalse);
  });
}
