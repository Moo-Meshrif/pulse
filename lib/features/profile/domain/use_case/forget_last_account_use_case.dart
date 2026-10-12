import 'package:injectable/injectable.dart';

import '../../data/repository/profile_repository.dart';

/// "Not you?" on Sign in: forgets the saved account on this device.
@injectable
class ForgetLastAccountUseCase {
  ForgetLastAccountUseCase(this._profiles);

  final ProfileRepository _profiles;

  Future<void> call() => _profiles.forgetLastAccount();
}
