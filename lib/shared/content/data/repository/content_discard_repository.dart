import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/connectivity_service.dart';
import '../datasource/content_discards_datasource.dart';
import '../datasource/media_files_datasource.dart';
import '../datasource/pending_content_datasource.dart';
import '../enums/content_kind.dart';
import '../enums/pending_content_state.dart';
import '../model/content_discard_model.dart';

/// Discards posts, shorts and stories for good, also offline: each discard is saved on this device
/// first and sent when the server can be reached. After the server marks an item discarded, the files it
/// lists are deleted from storage and the server checks that they are gone. A repository because it
/// combines the device list, the server and storage, and keeps retrying across screens.
abstract interface class ContentDiscardRepository {
  /// Saves the discard of [id] on this device, so it is finished even if the app closes. Never throws:
  /// [send] still tries when it could not be saved.
  Future<void> save(String id, ContentKind kind);

  /// Tells the server to discard [id], then deletes the files of discarded items. Returns the server's
  /// answer: discarded, or published when it had already gone out (nothing is deleted then). Null when
  /// the server could not be reached: it is sent again when the connection is back. Never throws.
  Future<PendingContentState?> send(String id, ContentKind kind);

  /// Sends every saved discard, then deletes the files of discarded items. Never throws.
  Future<void> sendSaved();

  /// A saved discard of [kind] could not reach the server and waits for the connection.
  bool isWaiting(ContentKind kind);

  /// The kind whose [isWaiting] changed.
  Stream<ContentKind> get changes;

  /// [userId] is signed in now. When another user was, nothing waits any more: the new user's saved
  /// discards are sent by the next [sendSaved].
  void useAccount(String? userId);
}

@LazySingleton(as: ContentDiscardRepository)
final class ContentDiscardRepositoryImpl implements ContentDiscardRepository {
  ContentDiscardRepositoryImpl(
    this._local,
    this._server,
    this._files,
    this._connectivity,
  );

  final ContentDiscardsDatasource _local;
  final PendingContentDatasource _server;
  final MediaFilesDatasource _files;
  final ConnectivityService _connectivity;

  final _waiting = <ContentKind>{};
  final _changes = StreamController<ContentKind>.broadcast();

  /// Listens for the connection coming back while a discard waits.
  StreamSubscription<void>? _hints;

  /// The [sendSaved] running now; a second call joins it.
  Future<void>? _sweep;

  /// Who the waiting discards belong to; null until [useAccount] is first called.
  String? _userId;

  @override
  Stream<ContentKind> get changes => _changes.stream;

  @override
  bool isWaiting(ContentKind kind) => _waiting.contains(kind);

  @override
  void useAccount(String? userId) {
    final before = _userId;
    _userId = userId;
    if (before == null || before == userId) return;
    for (final kind in _waiting.toList()) {
      _setWaiting(kind, isWaiting: false);
    }
  }

  @override
  Future<void> save(String id, ContentKind kind) async {
    try {
      await _local.add(ContentDiscardModel(id: id, kind: kind));
    } on Failure {
      // sent now all the same; only an offline discard is lost if the app closes
    }
  }

  @override
  Future<PendingContentState?> send(String id, ContentKind kind) async {
    final state = await _tell(id, kind);
    if (state != null) unawaited(sendSaved());
    return state;
  }

  @override
  Future<void> sendSaved() =>
      _sweep ??= _sendAll().whenComplete(() => _sweep = null);

  Future<void> _sendAll() async {
    for (final saved in _local.read()) {
      final id = saved.id;
      final kind = saved.kind;
      if (id == null || kind == null) continue;
      // Still offline: the rest waits for the connection too.
      if (await _tell(id, kind) == null) return;
    }
    // Nothing saved is left (a discard that could not be saved waits for nothing).
    for (final kind in _waiting.toList()) {
      _setWaiting(kind, isWaiting: false);
    }
    await _clean();
  }

  /// The server's answer, or null when it could not be told (the discard stays saved and waits).
  Future<PendingContentState?> _tell(String id, ContentKind kind) async {
    try {
      final state = await _server.discard(id, kind);
      await _forget(id, kind);
      return state ?? PendingContentState.discarded;
    } on Failure {
      _setWaiting(kind, isWaiting: true);
      return null;
    }
  }

  /// Deletes the files the server lists, then has it count what is left; whatever fails is listed
  /// again next time.
  Future<void> _clean() async {
    try {
      for (final item in await _server.cleanupList()) {
        final id = item.id;
        if (id == null) continue;
        await _files.remove(item.paths ?? const []);
        await _server.confirmCleanup(id);
      }
    } on Failure {
      // tried again with the next discard or start
    }
  }

  Future<void> _forget(String id, ContentKind kind) async {
    try {
      await _local.remove(id);
    } on Failure {
      // told again next time; the server answers the same
    }
    final isStillSaved = _local.read().any(
      (item) => item.kind == kind && item.id != id,
    );
    if (!isStillSaved) _setWaiting(kind, isWaiting: false);
  }

  void _setWaiting(ContentKind kind, {required bool isWaiting}) {
    final changed = isWaiting ? _waiting.add(kind) : _waiting.remove(kind);
    if (!changed) return;
    _changes.add(kind);
    if (_waiting.isEmpty) {
      unawaited(_hints?.cancel());
      _hints = null;
    } else {
      _hints ??= _connectivity.connectionHints.listen(
        (_) => unawaited(sendSaved()),
      );
    }
  }
}
