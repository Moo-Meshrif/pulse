import 'package:injectable/injectable.dart';

import '../../../../core/enums/signed_out_reason.dart';
import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public signal that the session ended by itself (not by the app's own sign-out), for the app
/// shell to open Sign in with the reason.
@injectable
class WatchSessionEndedUseCase {
  WatchSessionEndedUseCase(this._auth);

  final AuthDatasource _auth;

  Stream<SignedOutReason> call() => _auth.sessionEnded;
}
