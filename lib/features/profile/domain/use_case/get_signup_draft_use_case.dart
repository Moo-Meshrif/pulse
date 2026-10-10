import 'package:injectable/injectable.dart';

import '../../../../core/error/result.dart';
import '../../data/repository/profile_repository.dart';
import '../entity/profile_entity.dart';

/// What this user already entered during sign-up (name, username, birthday, bio, photo…), so a resumed
/// sign-up shows it again. The entry point the sign-up flow calls.
@injectable
class GetSignupDraftUseCase {
  GetSignupDraftUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<Result<ProfileEntity>> call() => _profiles.getProfile();
}
