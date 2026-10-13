import 'package:injectable/injectable.dart';

import '../../../../core/enums/recovery_signal.dart';
import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public signal that the app was opened from a password-recovery link, for the app shell to
/// open the reset screen (also when the link was refused, so the screen can say so).
@injectable
class WatchPasswordRecoveryUseCase {
  WatchPasswordRecoveryUseCase(this._auth);

  final AuthDatasource _auth;

  Stream<RecoverySignal> call() => _auth.recoverySignals;
}
