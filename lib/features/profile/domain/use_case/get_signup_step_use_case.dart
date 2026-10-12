import 'package:injectable/injectable.dart';

import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';

/// Where this user's sign-up resumes: the one thing other features may know about the profile. An unknown
/// step counts as the first, because the database does not let sign-up skip it. Offline, the saved copy
/// is trusted only when it says sign-up is finished (so the app opens), never to resume an unfinished
/// sign-up, whose steps all need the network: that is a connection failure for the splash to show.
@injectable
class GetSignupStepUseCase {
  GetSignupStepUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<SignupStep> call() async {
    final profile = await _profiles.getProfile(savedOnlyWhenSignupDone: true);
    return profile.signupStep ?? SignupStep.aboutYou;
  }
}
