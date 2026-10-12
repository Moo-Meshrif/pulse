import 'package:injectable/injectable.dart';

import '../../data/repository/profile_repository.dart';
import '../entity/last_account_entity.dart';

/// `profile`'s public answer to "who was signed in on this device?", for Sign in after a session ended.
/// Null when no account is saved (or it has no username).
@injectable
class GetLastAccountUseCase {
  GetLastAccountUseCase(this._profiles);

  final ProfileRepository _profiles;

  LastAccountEntity? call() => _profiles.lastAccount();
}
