import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public way to end this device's session, for other features (the splash, when the signed-in
/// account no longer exists).
@injectable
class SignOutUseCase {
  SignOutUseCase(this._auth);

  final AuthDatasource _auth;

  Future<void> call() => _auth.signOut();
}
