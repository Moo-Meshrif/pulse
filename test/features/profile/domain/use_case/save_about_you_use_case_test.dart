import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';
import 'package:pulse/features/profile/domain/use_case/save_about_you_use_case.dart';

import '../../../../helpers/failure_of.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockProfileRepository profiles;
  late SaveAboutYouUseCase useCase;

  final birthday = DateTime(1999, 5, 20);

  setUpAll(() => registerFallbackValue(const ProfileUpdateEntity()));

  setUp(() {
    profiles = MockProfileRepository();
    useCase = SaveAboutYouUseCase(profiles);
    when(() => profiles.isUsernameAvailable(any()))
        .thenAnswer((_) async => true);
    when(() => profiles.updateProfile(any()))
        .thenAnswer((_) async => const ProfileEntity());
  });

  test(
    'checks the lowercase username, then saves the fields and advances',
    () async {
      await useCase(
        fullName: '  Ada Lovelace ',
        username: ' Ada_L ',
        birthday: birthday,
        gender: Gender.female,
      );

      verifyInOrder([
        () => profiles.isUsernameAvailable('ada_l'),
        () => profiles.updateProfile(
          ProfileUpdateEntity(
            fullName: 'Ada Lovelace',
            username: 'ada_l',
            birthday: birthday,
            gender: Gender.female,
            signupStep: SignupStep.profile,
          ),
        ),
      ]);
    },
  );

  test('a taken username is a conflict and nothing is saved', () async {
    when(() => profiles.isUsernameAvailable(any()))
        .thenAnswer((_) async => false);

    expect(
      await failureOf(
        useCase(fullName: 'Ada', username: 'ada_l', birthday: birthday),
      ),
      const ConflictFailure(),
    );
    verifyNever(() => profiles.updateProfile(any()));
  });

  test(
    'a failed availability check is returned and nothing is saved',
    () async {
      when(() => profiles.isUsernameAvailable(any()))
          .thenThrow(const NetworkFailure());

      expect(
        await failureOf(
          useCase(fullName: 'Ada', username: 'ada_l', birthday: birthday),
        ),
        const NetworkFailure(),
      );
      verifyNever(() => profiles.updateProfile(any()));
    },
  );

  test(
    'losing the username to someone else while saving is a conflict',
    () async {
      when(() => profiles.updateProfile(any()))
          .thenThrow(const ConflictFailure());

      expect(
        await failureOf(
          useCase(fullName: 'Ada', username: 'ada_l', birthday: birthday),
        ),
        const ConflictFailure(),
      );
    },
  );
}
