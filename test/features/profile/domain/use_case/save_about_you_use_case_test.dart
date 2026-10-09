import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/enums/gender.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';
import 'package:pulse/features/profile/domain/use_case/save_about_you_use_case.dart';

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
        .thenAnswer((_) async => const Right(true));
    when(() => profiles.updateProfile(any()))
        .thenAnswer((_) async => const Right(ProfileEntity()));
  });

  test(
    'checks the lowercase username, then saves the fields and advances',
    () async {
      final result = await useCase(
        fullName: '  Ada Lovelace ',
        username: ' Ada_L ',
        birthday: birthday,
        gender: Gender.female,
      );

      expect(result.isRight, isTrue);
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
        .thenAnswer((_) async => const Right(false));

    final result = await useCase(
      fullName: 'Ada',
      username: 'ada_l',
      birthday: birthday,
    );

    expect(result.fold((f) => f, (_) => null), const ConflictFailure());
    verifyNever(() => profiles.updateProfile(any()));
  });

  test(
    'a failed availability check is returned and nothing is saved',
    () async {
      when(() => profiles.isUsernameAvailable(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(
        fullName: 'Ada',
        username: 'ada_l',
        birthday: birthday,
      );

      expect(result.fold((f) => f, (_) => null), const NetworkFailure());
      verifyNever(() => profiles.updateProfile(any()));
    },
  );

  test(
    'losing the username to someone else while saving is a conflict',
    () async {
      when(() => profiles.updateProfile(any()))
          .thenAnswer((_) async => const Left(ConflictFailure()));

      final result = await useCase(
        fullName: 'Ada',
        username: 'ada_l',
        birthday: birthday,
      );

      expect(result.fold((f) => f, (_) => null), const ConflictFailure());
    },
  );
}
