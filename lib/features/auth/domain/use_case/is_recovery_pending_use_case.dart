import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public answer to "was a password reset started on this device and not finished?", for the
/// splash: such a session must lead back to the reset screen, never to Home.
@injectable
class IsRecoveryPendingUseCase {
  IsRecoveryPendingUseCase(this._auth);

  final AuthDatasource _auth;

  bool call() => _auth.recoveryActive;
}
