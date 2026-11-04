import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public way to check the signed-in person's password again before a sensitive step (deleting
/// the account). Throws `AuthFailure(invalidCredentials)` when it is wrong.
@injectable
class VerifyPasswordUseCase {
  VerifyPasswordUseCase(this._auth);

  final AuthDatasource _auth;

  Future<void> call(String password) => _auth.verifyPassword(password);
}
