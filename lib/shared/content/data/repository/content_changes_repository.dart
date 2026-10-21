import 'dart:async';

import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../domain/event/content_changed.dart';
import '../../domain/event/content_ping.dart';
import '../datasource/content_changes_datasource.dart';
import '../datasource/content_changes_point_datasource.dart';
import '../datasource/content_live_datasource.dart';
import '../enums/content_change_op.dart';
import '../enums/content_kind.dart';
import '../model/content_changes_model.dart';
import '../model/content_changes_point_model.dart';
import '../model/post_count_model.dart';

/// Finds what changed in posts, shorts and stories since the last check and tells the app with a
/// [ContentChanged] event. A repository because it combines the server with the point kept on this
/// device, and moves the point forward only after the event was sent.
abstract interface class ContentChangesRepository {
  /// Asks the server for the changes of [kind] since the saved point and sends them, a page at a time.
  /// With no point yet it only saves one (the screen just loaded). Away longer than
  /// `AppConfig.contentChangesMaxAge`, or too far behind, it sends `mustReload`. Offline or failing, it
  /// does nothing and tries again next time. Never throws; two calls for one kind share one check.
  Future<void> check(ContentKind kind);

  /// The current counts of the posts [ids] on screen. Throws a `Failure` on error.
  Future<List<PostCountModel>> postCounts(List<String> ids);

  /// Starts listening to the server. Each burst of changes sends one `ContentPing` per kind. A second
  /// call while listening does nothing. A missed ping loses nothing: the next check uses the saved point.
  void startLive();

  /// Stops listening (the app went to the background, or the person signed out).
  void stopLive();
}

@LazySingleton(as: ContentChangesRepository)
final class ContentChangesRepositoryImpl implements ContentChangesRepository {
  ContentChangesRepositoryImpl(
    this._server,
    this._points,
    this._events,
    this._live,
  );

  static const _maxPages = 10;

  /// Changes that come close together (a burst of likes) send one ping.
  static const _pingQuiet = Duration(seconds: 1);

  final ContentChangesDatasource _server;
  final ContentChangesPointDatasource _points;
  final EventBus _events;
  final ContentLiveDatasource _live;

  // ignore: cancel_subscriptions, cancelled in stopLive.
  StreamSubscription<ContentKind>? _liveSub;
  final _pingTimers = <ContentKind, Timer>{};
  final _running = <ContentKind, Future<void>>{};

  @override
  Future<void> check(ContentKind kind) =>
      _running[kind] ??= _run(kind).whenComplete(() {
        _running.remove(kind);
      });

  @override
  Future<List<PostCountModel>> postCounts(List<String> ids) =>
      ids.isEmpty ? Future.value(const []) : _server.postCounts(ids);

  @override
  void startLive() {
    // An error on the connection is not shown: the next open or return still catches up.
    _liveSub ??= _live.pings().listen(_ping, onError: (Object _) {});
  }

  @override
  void stopLive() {
    final sub = _liveSub;
    _liveSub = null;
    if (sub != null) unawaited(sub.cancel());
    for (final timer in _pingTimers.values) {
      timer.cancel();
    }
    _pingTimers.clear();
  }

  void _ping(ContentKind kind) {
    _pingTimers[kind]?.cancel();
    _pingTimers[kind] = Timer(_pingQuiet, () {
      _pingTimers.remove(kind);
      _events.fire(ContentPing(kind));
    });
  }

  Future<void> _run(ContentKind kind) async {
    try {
      final point = _points.read(kind);
      final at = point?.at;
      if (at == null) return await _startPoint(kind);
      if (clock.now().difference(at) > AppConfig.contentChangesMaxAge) {
        return await _reload(kind);
      }
      await _follow(kind, point!);
    } on Failure {
      // Offline or the server failed: nothing changes on screen, the next check tries again.
    }
  }

  /// First check on this device: the screen just loaded, so only the starting point is kept.
  Future<void> _startPoint(ContentKind kind) async {
    final start = await _server.changesSince(kind);
    await _save(kind, start);
  }

  Future<void> _reload(ContentKind kind) async {
    final start = await _server.changesSince(kind);
    _events.fire(ContentChanged(kind, mustReload: true));
    await _save(kind, start);
  }

  Future<void> _follow(ContentKind kind, ContentChangesPointModel from) async {
    var point = from;
    for (var page = 0; page < _maxPages; page++) {
      final answer = await _server.changesSince(
        kind,
        afterAt: point.at,
        afterId: point.id,
      );
      if (answer.reset ?? false) {
        _events.fire(ContentChanged(kind, mustReload: true));
        await _save(kind, answer);
        return;
      }
      _send(kind, answer.ops ?? const []);
      if (answer.nextAt == null) return;
      point = ContentChangesPointModel(at: answer.nextAt, id: answer.nextId);
      await _points.write(kind, point);
      if (!(answer.hasMore ?? false)) return;
    }
  }

  /// One event for a page. An id seen twice keeps its last change.
  void _send(ContentKind kind, List<ContentChangeModel> changes) {
    final last = <String, ContentChangeOp>{};
    for (final change in changes) {
      final id = change.id;
      final op = change.op;
      if (id != null && op != null) last[id] = op;
    }
    if (last.isEmpty) return;
    _events.fire(
      ContentChanged(
        kind,
        upsertedIds: [
          for (final e in last.entries)
            if (e.value == ContentChangeOp.upsert) e.key,
        ],
        removedIds: [
          for (final e in last.entries)
            if (e.value != ContentChangeOp.upsert) e.key,
        ],
      ),
    );
  }

  Future<void> _save(ContentKind kind, ContentChangesModel answer) async {
    final at = answer.nextAt;
    if (at == null) return;
    await _points.write(
      kind,
      ContentChangesPointModel(at: at, id: answer.nextId),
    );
  }
}
