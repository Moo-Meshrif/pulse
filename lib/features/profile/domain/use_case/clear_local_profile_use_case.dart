import 'package:injectable/injectable.dart';

import '../../data/repository/profile_repository.dart';

/// Forgets the saved copy of the profile; a sign-out calls it first.
@injectable
class ClearLocalProfileUseCase {
  ClearLocalProfileUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<void> call() => _profiles.clearLocalProfile();
}
