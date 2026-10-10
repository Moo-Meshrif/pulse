import 'package:injectable/injectable.dart';

import '../../data/datasource/interests_datasource.dart';
import '../../data/enums/signup_step.dart';
import '../../data/repository/profile_repository.dart';
import '../entity/profile_update_entity.dart';

/// Sign-up step "Interests": saves the picked topics (nothing is sent for an empty pick, i.e. Skip) and
/// moves the resume point to Follow.
@injectable
class SaveInterestsUseCase {
  SaveInterestsUseCase(this._interests, this._profiles);

  final InterestsDatasource _interests;
  final ProfileRepository _profiles;

  Future<void> call(List<int> interestIds) async {
    if (interestIds.isNotEmpty) {
      await _interests.saveInterests(interestIds);
    }
    await _profiles.updateProfile(
      const ProfileUpdateEntity(signupStep: SignupStep.follow),
    );
  }
}
