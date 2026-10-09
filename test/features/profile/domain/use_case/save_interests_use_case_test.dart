import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/error/failures.dart';
import 'package:pulse/core/utils/either.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/domain/entity/profile_entity.dart';
import 'package:pulse/features/profile/domain/entity/profile_update_entity.dart';
import 'package:pulse/features/profile/domain/use_case/save_interests_use_case.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late MockInterestsDatasource interests;
  late MockProfileRepository profiles;
  late SaveInterestsUseCase useCase;

  setUpAll(() => registerFallbackValue(const ProfileUpdateEntity()));

  setUp(() {
    interests = MockInterestsDatasource();
    profiles = MockProfileRepository();
    useCase = SaveInterestsUseCase(interests, profiles);
    when(() => interests.saveInterests(any<List<int>>()))
        .thenAnswer((_) async => const Right(unit));
    when(() => profiles.updateProfile(any()))
        .thenAnswer((_) async => const Right(ProfileEntity()));
  });

  const toFollow = ProfileUpdateEntity(signupStep: SignupStep.follow);

  test(
    'saves the picked topics, then moves the resume point to Follow',
    () async {
      final result = await useCase([1, 4]);

      expect(result.isRight, isTrue);
      verifyInOrder([
        () => interests.saveInterests([1, 4]),
        () => profiles.updateProfile(toFollow),
      ]);
    },
  );

  test('an empty pick (Skip) sends no topics and only moves on', () async {
    await useCase(const []);

    verifyNever(() => interests.saveInterests(any<List<int>>()));
    verify(() => profiles.updateProfile(toFollow)).called(1);
  });

  test('a failed save is returned and the resume point stays', () async {
    when(() => interests.saveInterests(any<List<int>>()))
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await useCase([1]);

    expect(result.fold((f) => f, (_) => null), const NetworkFailure());
    verifyNever(() => profiles.updateProfile(any()));
  });
}
