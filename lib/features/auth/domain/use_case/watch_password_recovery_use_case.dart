import 'package:injectable/injectable.dart';

import '../../../../core/utils/either.dart';
import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public signal that the app was opened from a password-recovery link, for the app shell to
/// open the reset screen.
@injectable
class WatchPasswordRecoveryUseCase {
  WatchPasswordRecoveryUseCase(this._auth);

  final AuthDatasource _auth;

  Stream<Unit> call() => _auth.passwordRecovery;
}
