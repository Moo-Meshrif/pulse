import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
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

  Future<void> call({
    required String fullName,
    required String username,
    required DateTime birthday,
    Gender? gender,
  }) async {
    final name = username.trim().toLowerCase();
    if (!await _profiles.isUsernameAvailable(name)) {
      throw const ConflictFailure();
    }
    await _profiles.updateProfile(
      ProfileUpdateEntity(
        fullName: fullName.trim(),
        username: name,
        birthday: birthday,
        gender: gender,
        signupStep: SignupStep.profile,
      ),
    );
  }
}
