import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/utils/either.dart';
import '../../data/enums/gender.dart';
import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';
import '../entity/profile_update_entity.dart';

/// Sign-up step "About you": checks the username is free, saves the four fields and moves the resume
/// point to the Profile step. A taken username is `ConflictFailure`, found before or while saving.
@injectable
class SaveAboutYouUseCase {
  SaveAboutYouUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<Unit>> call({
    required String fullName,
    required String username,
    required DateTime birthday,
    Gender? gender,
  }) async {
    final name = username.trim().toLowerCase();
    final available = await _profiles.isUsernameAvailable(name);
    switch (available) {
      case Left(:final value):
        return Left(value);
      case Right(value: false):
        return const Left(ConflictFailure());
      case Right():
        break;
    }
    final saved = await _profiles.updateProfile(
      ProfileUpdateEntity(
        fullName: fullName.trim(),
        username: name,
        birthday: birthday,
        gender: gender,
        signupStep: SignupStep.profile,
      ),
    );
    return saved.map((_) => unit);
  }
}
