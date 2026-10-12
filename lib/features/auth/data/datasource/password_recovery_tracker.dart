import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/storage_keys.dart';
import '../enums/recovery_signal.dart';

/// Remembers an unfinished password reset and relays when the emailed link was opened. Backend-agnostic:
/// an `AuthDatasource` adapter calls [linkOpened], [linkRefused] and [end] from its own SDK events.
///
/// [isPending] survives a restart, so a closed reset screen does not leave a signed-in session behind.
/// [signals] is broadcast. A signal sent while nobody listens (the link started the app) is held for the
/// next listener only; [end] drops a held `started`, so an old reset is never replayed.
@LazySingleton()
class PasswordRecoveryTracker {
  PasswordRecoveryTracker(this._storage);

  final LocalStorageService _storage;

  late final StreamController<RecoverySignal> _controller =
      StreamController<RecoverySignal>.broadcast(onListen: _deliverUndelivered);

  RecoverySignal? _undelivered;

  /// A reset was started here and its new password is not set yet.
  bool get isPending =>
      _storage.getValue<bool>(StorageKeys.recoveryPending) ?? false;

  Stream<RecoverySignal> get signals => _controller.stream;

  Future<void> linkOpened() async {
    await _storage.setValue<bool>(StorageKeys.recoveryPending, true);
    _publish(RecoverySignal.started);
  }

  void linkRefused() => _publish(RecoverySignal.linkFailed);

  /// The reset ended: password changed, sign-in or sign-out, or the session is gone.
  Future<void> end() async {
    if (_undelivered == RecoverySignal.started) _undelivered = null;
    await _storage.remove(StorageKeys.recoveryPending);
  }

  void _publish(RecoverySignal signal) {
    if (_controller.isClosed) return;
    if (_controller.hasListener) {
      _undelivered = null; // a newer signal replaces a held one
      _controller.add(signal);
    } else {
      _undelivered = signal;
    }
  }

  // Deferred to a microtask: the new listener is still inside `listen` and must be attached first.
  void _deliverUndelivered() {
    if (_undelivered == null) return;
    scheduleMicrotask(() {
      final signal = _undelivered;
      if (signal == null || !_controller.hasListener) return;
      _undelivered = null;
      _controller.add(signal);
    });
  }

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
