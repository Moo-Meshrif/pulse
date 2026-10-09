import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';
import 'package:pulse/features/profile/domain/use_case/save_profile_details_use_case.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late MockProfileRepository profiles;
  late SaveProfileDetailsUseCase useCase;

  final photo = Uint8List.fromList([1, 2, 3]);

  setUpAll(() {
    registerFallbackValue(const ProfileUpdateEntity());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    profiles = MockProfileRepository();
    useCase = SaveProfileDetailsUseCase(profiles);
    when(
      () =>
          profiles.uploadAvatar(any(), contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => const Right('https://cdn/avatar?v=1'));
    when(() => profiles.updateProfile(any()))
        .thenAnswer((_) async => const Right(ProfileEntity()));
  });

  test(
    'uploads the photo first, then saves its URL with the trimmed fields',
    () async {
      final result = await useCase(
        photo: photo,
        photoContentType: 'image/png',
        bio: ' Hi ',
        city: 'Cairo ',
        phone: '+20 100 123 4567',
      );

      expect(result.isRight, isTrue);
      verifyInOrder([
        () => profiles.uploadAvatar(photo, contentType: 'image/png'),
        () => profiles.updateProfile(
          const ProfileUpdateEntity(
            avatarUrl: 'https://cdn/avatar?v=1',
            bio: 'Hi',
            city: 'Cairo',
            phone: '+201001234567',
            signupStep: SignupStep.interests,
          ),
        ),
      ]);
    },
  );

  test(
    'without anything given it only moves the resume point (Skip)',
    () async {
      await useCase();

      verifyNever(
        () => profiles.uploadAvatar(
          any(),
          contentType: any(named: 'contentType'),
        ),
      );
      verify(
        () => profiles.updateProfile(
          const ProfileUpdateEntity(signupStep: SignupStep.interests),
        ),
      ).called(1);
    },
  );

  test('blank fields count as not given', () async {
    await useCase(bio: '  ', city: '', phone: ' ');

    verify(
      () => profiles.updateProfile(
        const ProfileUpdateEntity(signupStep: SignupStep.interests),
      ),
    ).called(1);
  });

  test('a failed upload is returned and nothing is saved', () async {
    when(
      () =>
          profiles.uploadAvatar(any(), contentType: any(named: 'contentType')),
    ).thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await useCase(photo: photo, bio: 'Hi');

    expect(result.fold((f) => f, (_) => null), const NetworkFailure());
    verifyNever(() => profiles.updateProfile(any()));
  });
}
