import 'dart:async';

import 'package:injectable/injectable.dart';

import '../enums/signed_out_reason.dart';

/// Session endings learned from a failed request rather than from the auth SDK. The SDK reports every
/// non-user sign-out as [SignedOutReason.expired]; only a request that fails with `sessionRevoked` knows
/// the session was ended elsewhere. `Guard` feeds it, `WatchSessionEndedUseCase` merges it with the SDK.
@LazySingleton()
class SessionEvents {
  final StreamController<SignedOutReason> _controller =
      StreamController<SignedOutReason>.broadcast();

  Stream<SignedOutReason> get ended => _controller.stream;

  void revoked() {
    if (_controller.isClosed) return;
    _controller.add(SignedOutReason.revoked);
  }

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
