import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public way to change the signed-in person's password: checks the current one first. Throws
/// `AuthFailure(invalidCredentials)` when it is wrong.
@injectable
class ChangePasswordUseCase {
  ChangePasswordUseCase(this._auth);

  final AuthDatasource _auth;

  Future<void> call({required String current, required String next}) async {
    await _auth.verifyPassword(current);
    await _auth.updatePassword(next);
  }
}
