import 'package:injectable/injectable.dart';

import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public way to end every session except this device's (Password & security).
@injectable
class SignOutOthersUseCase {
  SignOutOthersUseCase(this._auth);

  final AuthDatasource _auth;

  Future<void> call() => _auth.signOut(others: true);
}
