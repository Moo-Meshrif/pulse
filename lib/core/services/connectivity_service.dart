import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

import '../constants/app_config.dart';
import '../enums/connection_problem.dart';
import '../error/failures.dart';

/// What the connection looks like from this device. Tests mock it.
abstract interface class ConnectivityService {
  /// Whether the device has no Wi-Fi and no mobile data. Quick (no request), so it can run before
  /// every request. A plugin failure counts as not offline: the request decides.
  Future<bool> isOffline();

  /// Finds why [failure] (a [NetworkFailure] or [TimeoutFailure]) happened. Run it only after a
  /// failure, so a working connection costs nothing. Never throws.
  Future<ConnectionProblem> diagnose(Failure failure);

  /// Fires when the connection may be back: a network appeared, the backend answered after failing,
  /// or the app returned to the foreground. Only watches while someone listens.
  Stream<void> get connectionHints;
}

/// How the backend answers a TLS connection.
enum BackendReach {
  /// The connection failed or timed out.
  none,

  /// It opened, but slowly.
  slow,

  /// It opened quickly.
  fast,
}

/// [ConnectivityService] over `connectivity_plus` and a TLS connection to the Supabase host.
@LazySingleton(as: ConnectivityService)
class PlusConnectivityService
    with WidgetsBindingObserver
    implements ConnectivityService {
  PlusConnectivityService(this._connectivity) {
    _hints = StreamController<void>.broadcast(
      onListen: _startWatching,
      onCancel: _stopWatching,
    );
  }

  /// A slower TLS handshake than this counts as a weak connection.
  static const _slowAfter = Duration(milliseconds: 1500);

  /// The longest a probe waits for the backend.
  static const _giveUpAfter = Duration(seconds: 5);

  /// How often a listener re-probes the backend.
  static const _probeEvery = Duration(seconds: 6);

  final Connectivity _connectivity;
  late final StreamController<void> _hints;
  StreamSubscription<List<ConnectivityResult>>? _networkChanges;
  Timer? _probeTimer;
  bool _probing = false;

  // --- Offline check ---

  @override
  Future<bool> isOffline() async {
    try {
      return !_hasNetwork(await _connectivity.checkConnectivity());
    } on Object {
      return false;
    }
  }

  bool _hasNetwork(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  // --- Diagnosis ---

  /// No network is offline; a network that reaches nothing is no internet; a slow answer, or a
  /// timeout on a good connection, is weak; any other failure on a good connection is on our side.
  @override
  Future<ConnectionProblem> diagnose(Failure failure) async {
    if (await isOffline()) return ConnectionProblem.offline;
    return switch (await probe()) {
      BackendReach.none => ConnectionProblem.noInternet,
      BackendReach.slow => ConnectionProblem.weak,
      BackendReach.fast =>
        failure is TimeoutFailure
            ? ConnectionProblem.weak
            : ConnectionProblem.cantReach,
    };
  }

  /// Opens a TLS connection to the backend and times it.
  @visibleForTesting
  Future<BackendReach> probe() async {
    final clock = Stopwatch()..start();
    try {
      final socket = await SecureSocket.connect(
        Uri.parse(AppConfig.supabaseUrl).host,
        443,
        timeout: _giveUpAfter,
      );
      socket.destroy();
    } on Object {
      return BackendReach.none;
    }
    return clock.elapsed > _slowAfter ? BackendReach.slow : BackendReach.fast;
  }

  // --- Hints: the connection may be back ---

  @override
  Stream<void> get connectionHints => _hints.stream;

  void _startWatching() {
    WidgetsBinding.instance.addObserver(this);
    _networkChanges = _connectivity.onConnectivityChanged.listen((results) {
      if (_hasNetwork(results)) _hint();
    });
    _probeTimer = Timer.periodic(_probeEvery, (_) => _hintIfBackendAnswers());
  }

  void _stopWatching() {
    WidgetsBinding.instance.removeObserver(this);
    _networkChanges?.cancel();
    _networkChanges = null;
    _probeTimer?.cancel();
    _probeTimer = null;
  }

  Future<void> _hintIfBackendAnswers() async {
    if (_probing) return;
    _probing = true;
    try {
      if (await probe() == BackendReach.fast) _hint();
    } finally {
      _probing = false;
    }
  }

  void _hint() {
    if (!_hints.isClosed) _hints.add(null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _hint();
  }
}
