import 'package:injectable/injectable.dart';

import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';

/// Whether the profile saved on this phone says sign-up is finished, so start-up can skip the server.
/// False with no saved copy or no session.
@injectable
class IsSignupDoneOnDeviceUseCase {
  IsSignupDoneOnDeviceUseCase(this._profiles);

  final ProfileRepository _profiles;

  bool call() => _profiles.savedSignupStep() == SignupStep.complete;
}
