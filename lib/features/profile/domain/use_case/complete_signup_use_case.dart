import 'package:injectable/injectable.dart';

import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';
import '../entity/profile_update_entity.dart';

/// Marks sign-up as finished, so the next launch goes straight to Home.
@injectable
class CompleteSignupUseCase {
  CompleteSignupUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<void> call() => _profiles.updateProfile(
    const ProfileUpdateEntity(signupStep: SignupStep.complete),
  );
}
