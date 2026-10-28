import 'package:injectable/injectable.dart';

import '../../../../core/enums/auth_failure_reason.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public way to email the signed-in person a password reset link (Forgot password? on
/// Password & security).
@injectable
class SendOwnPasswordResetUseCase {
  SendOwnPasswordResetUseCase(this._auth);

  final AuthDatasource _auth;

  Future<void> call() {
    final email = _auth.currentEmail;
    if (email == null) {
      throw const AuthFailure(AuthFailureReason.sessionExpired);
    }
    return _auth.sendPasswordReset(email);
  }
}
