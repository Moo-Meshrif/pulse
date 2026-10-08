import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_step_use_case.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late MockProfileRepository profiles;
  late GetSignupStepUseCase useCase;

  setUp(() {
    profiles = MockProfileRepository();
    useCase = GetSignupStepUseCase(profiles);
  });

  void profileIs(ProfileEntity profile) =>
      when(() => profiles.getProfile()).thenAnswer((_) async => Right(profile));

  test('returns the step of the profile, and nothing else about it', () async {
    profileIs(
      const ProfileEntity(
        id: 'u',
        username: 'dip',
        signupStep: SignupStep.interests,
      ),
    );
    expect(
      await useCase(),
      const Right<Failure, SignupStep>(SignupStep.interests),
    );
  });

  test('a finished sign-up is complete', () async {
    profileIs(const ProfileEntity(signupStep: SignupStep.complete));
    expect(
      await useCase(),
      const Right<Failure, SignupStep>(SignupStep.complete),
    );
  });

  test('a step the app does not know counts as the first one', () async {
    profileIs(const ProfileEntity(id: 'u'));
    expect(
      await useCase(),
      const Right<Failure, SignupStep>(SignupStep.aboutYou),
    );
  });

  test('a failure passes through', () async {
    when(() => profiles.getProfile())
        .thenAnswer((_) async => const Left(NetworkFailure()));
    expect(await useCase(), const Left<Failure, SignupStep>(NetworkFailure()));
  });
}
