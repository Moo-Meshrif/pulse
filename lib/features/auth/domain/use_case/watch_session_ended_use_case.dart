import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/enums/signed_out_reason.dart';
import '../../../../core/services/session_events.dart';
import '../../data/datasource/auth_datasource.dart';

/// `auth`'s public signal that the session ended by itself (not by the app's own sign-out), for the app
/// shell to open Sign in with the reason.
///
/// Two sources, combined into one stream so the app shell listens to a single place:
/// - the auth SDK, which reports every ending as `expired` (it cannot tell why the session ended);
/// - [SessionEvents], fed by a failed request, which is the only way to learn a session was `revoked`
///   (ended on another device, or by a password change).
@injectable
class WatchSessionEndedUseCase {
  WatchSessionEndedUseCase(this._auth, this._events);

  final AuthDatasource _auth;
  final SessionEvents _events;

  /// Listening starts both sources and cancelling stops both. Each ending is passed on as it arrives.
  Stream<SignedOutReason> call() => Stream<SignedOutReason>.multi((controller) {
    final subscriptions = [
      _auth.sessionEnded.listen(controller.addSync),
      _events.ended.listen(controller.addSync),
    ];
    controller.onCancel = () =>
        Future.wait(subscriptions.map((subscription) => subscription.cancel()));
  });
}
