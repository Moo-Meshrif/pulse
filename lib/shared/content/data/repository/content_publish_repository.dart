import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entity/content_publish_line.dart';
import '../../domain/entity/content_publish_status.dart';
import '../enums/content_kind.dart';
import '../enums/pending_content_state.dart';
import 'content_discard_repository.dart';

/// Sends a job's work, telling how far it got (0..1).
typedef PublishWork = Future<void> Function(void Function(double) report);

/// Sends posts, shorts and stories in the background. Each kind has its own line, so a story does not
/// wait behind a post: up to 3 posts wait together and go out one at a time in the order they were
/// shared; a short or story is alone in its line. A failed one does not stop the next. It is a
/// repository because it holds state across screens: Home shows how it goes while the composer has
/// already closed. The one going out is sent on the `EventBus` as `ContentPublishStatus` and the whole
/// line as `ContentPublishLine`; a screen that starts later reads [current] and [line].
abstract interface class ContentPublishRepository {
  /// Adds [send] to the line of [kind] and returns true; false (and nothing done) while the line is full
  /// (3 posts, 1 of any other kind). A failed one keeps its place until Retry or Discard, unless
  /// [replacesFailed] drops it for this one.
  /// [previewPath] is a picked file to show while it goes out. [pendingId] is the id the server knows it
  /// by before it is posted: discarding a failed one discards it there too, for good. [onDiscard] runs
  /// when a failed one is discarded, for the device side (it must not throw).
  bool enqueue({
    required ContentKind kind,
    required PublishWork send,
    String? pendingId,
    Future<void> Function()? onDiscard,
    bool isEdit = false,
    String? previewPath,
    String? previewUrl,
    String? previewCacheKey,
    bool replacesFailed = false,
  });

  /// Sends the failed one of [kind] again ([id] names it, else the first failed one); it goes out after
  /// the one going now. Does nothing in any other state, or when it was rejected.
  void retry(ContentKind kind, {String? id});

  /// Drops the failed one of [kind] ([id] names it, else the first failed one). When it had already gone
  /// out, `ContentDiscardRefused` is announced.
  void discard(ContentKind kind, {String? id});

  /// Sends again every failed one that failed only for the connection.
  void retryLost();

  /// The job known on the server as [pendingId] is being sent or waits for Retry.
  bool hasJob(String pendingId);

  /// [userId] is signed in now. When another user was, their jobs are dropped without a word, so the new
  /// one never sees them; whatever they still send is ignored (their own saved copy resumes it later).
  void useAccount(String? userId);

  /// The status of the one going out in [kind]'s line (else the first failed, else the first waiting).
  ContentPublishStatus current(ContentKind kind);

  /// Everything in [kind]'s line; the finished posts stay until the next post starts.
  ContentPublishLine line(ContentKind kind);
}

@LazySingleton(as: ContentPublishRepository)
final class ContentPublishRepositoryImpl implements ContentPublishRepository {
  ContentPublishRepositoryImpl(
    this._events,
    this._discards,
    this._connectivity,
  );

  static const _postLimit = 3;

  final EventBus _events;
  final ContentDiscardRepository _discards;
  final ConnectivityService _connectivity;

  /// Listens for the connection coming back while a post waits for it.
  StreamSubscription<void>? _hints;

  /// Who the jobs belong to; null until [useAccount] is first called.
  String? _userId;

  /// The jobs of each kind that are not done, in the order they were shared.
  final _jobs = <ContentKind, List<_Job>>{};

  /// Posts that are out, kept in the line until the next post starts.
  final _done = <ContentKind, List<ContentLineItem>>{};
  var _nextKey = 0;

  @override
  ContentPublishStatus current(ContentKind kind) {
    final jobs = _live(kind);
    final job =
        jobs
            .where((job) => job.state == ContentLineState.sending)
            .firstOrNull ??
        jobs.where((job) => job.state == ContentLineState.failed).firstOrNull ??
        jobs.firstOrNull;
    if (job == null) return ContentPublishIdle(kind);
    return job.state == ContentLineState.failed
        ? job.failed()
        : job.publishing();
  }

  @override
  ContentPublishLine line(ContentKind kind) => ContentPublishLine(kind, [
    ...?_done[kind],
    for (final job in _live(kind)) job.item,
  ]);

  @override
  bool enqueue({
    required ContentKind kind,
    required PublishWork send,
    String? pendingId,
    Future<void> Function()? onDiscard,
    bool isEdit = false,
    String? previewPath,
    String? previewUrl,
    String? previewCacheKey,
    bool replacesFailed = false,
  }) {
    final jobs = _live(kind);
    if (replacesFailed) {
      jobs.removeWhere((job) => job.state == ContentLineState.failed);
    }
    if (jobs.length >= _limit(kind)) return false;
    if (jobs.isEmpty) _done.remove(kind);
    jobs.add(
      _Job(
        key: pendingId ?? 'job-${_nextKey++}',
        kind: kind,
        isEdit: isEdit,
        pendingId: pendingId,
        previewPath: previewPath,
        previewUrl: previewUrl,
        previewCacheKey: previewCacheKey,
        send: send,
        onDiscard: onDiscard,
      ),
    );
    if (!_pump(kind)) _changed(kind);
    return true;
  }

  @override
  void retry(ContentKind kind, {String? id}) {
    final job = _failed(kind, id);
    if (job == null || job.failure is RejectedFailure) return;
    _again(job);
    if (!_pump(kind)) _changed(kind);
  }

  @override
  void discard(ContentKind kind, {String? id}) {
    final job = _failed(kind, id);
    if (job == null) return;
    _live(kind).remove(job);
    _changed(kind);
    unawaited(_discard(job));
  }

  @override
  void retryLost() {
    for (final kind in _jobs.keys.toList()) {
      final lost = _live(kind).where((job) => job.isOffline).toList();
      if (lost.isEmpty) continue;
      lost.forEach(_again);
      if (!_pump(kind)) _changed(kind);
    }
  }

  @override
  bool hasJob(String pendingId) =>
      _jobs.values.any((jobs) => jobs.any((job) => job.pendingId == pendingId));

  @override
  void useAccount(String? userId) {
    final before = _userId;
    _userId = userId;
    if (before == null || before == userId) return;
    final kinds = {..._jobs.keys, ..._done.keys};
    _jobs.clear();
    _done.clear();
    kinds.forEach(_changed);
  }

  List<_Job> _live(ContentKind kind) => _jobs.putIfAbsent(kind, () => []);

  int _limit(ContentKind kind) => kind == ContentKind.post ? _postLimit : 1;

  /// The failed job named [id], else the first failed one.
  _Job? _failed(ContentKind kind, String? id) => _live(kind)
      .where(
        (job) =>
            job.state == ContentLineState.failed &&
            (id == null || job.key == id),
      )
      .firstOrNull;

  void _again(_Job job) {
    job.state = ContentLineState.waiting;
    job.failure = null;
  }

  /// Saved first, then the device side, then the server.
  Future<void> _discard(_Job job) async {
    final id = job.pendingId;
    if (id != null) await _discards.save(id, job.kind);
    await job.onDiscard?.call();
    if (id == null) return;
    final state = await _discards.send(id, job.kind);
    if (state != PendingContentState.published) return;
    _events.fire(ContentDiscardRefused(job.kind));
    _events.fire(current(job.kind));
  }

  void _changed(ContentKind kind) {
    _events.fire(current(kind));
    _events.fire(line(kind));
    _watchConnection();
  }

  /// While something failed only for the connection, it goes again by itself when the connection is back.
  void _watchConnection() {
    final isWaiting = _jobs.values.any(
      (jobs) => jobs.any((job) => job.isOffline),
    );
    if (!isWaiting) {
      unawaited(_hints?.cancel());
      _hints = null;
      return;
    }
    _hints ??= _connectivity.connectionHints.listen((_) => retryLost());
  }

  /// Starts the first waiting job of [kind] unless one is going; true when one started.
  bool _pump(ContentKind kind) {
    final jobs = _live(kind);
    if (jobs.any((job) => job.state == ContentLineState.sending)) return false;
    final next = jobs
        .where((job) => job.state == ContentLineState.waiting)
        .firstOrNull;
    if (next == null) return false;
    next
      ..state = ContentLineState.sending
      ..progress = 0;
    _changed(kind);
    unawaited(_run(next));
    return true;
  }

  Future<void> _run(_Job job) async {
    void report(double value) {
      // A retried file counts again from zero; the bar keeps its place.
      final next = value.clamp(0.0, 1.0);
      if (next <= job.progress || !_isCurrent(job)) return;
      job.progress = next;
      _changed(job.kind);
    }

    try {
      await job.send(report);
    } on Failure catch (failure) {
      _fail(job, failure);
      return;
    } catch (error, stackTrace) {
      _fail(job, Guard.toFailure(error, stackTrace));
      return;
    }
    if (!_isCurrent(job)) return; // dropped when the account changed
    final kind = job.kind;
    _live(kind).remove(job);
    if (kind == ContentKind.post) {
      (_done[kind] ??= []).add(job.item.done());
    }
    _events.fire(ContentPublishDone(kind, isEdit: job.isEdit));
    _changed(kind);
    _pump(kind);
  }

  bool _isCurrent(_Job job) => _live(job.kind).contains(job);

  void _fail(_Job job, Failure failure) {
    if (!_isCurrent(job)) return;
    job
      ..state = ContentLineState.failed
      ..failure = failure;
    _changed(job.kind);
    _pump(job.kind);
  }
}

class _Job {
  _Job({
    required this.key,
    required this.kind,
    required this.isEdit,
    required this.send,
    this.pendingId,
    this.onDiscard,
    this.previewPath,
    this.previewUrl,
    this.previewCacheKey,
  });

  /// Names the job in the line: the server's id when it has one.
  final String key;
  final ContentKind kind;
  final bool isEdit;
  final String? previewPath;
  final String? previewUrl;
  final String? previewCacheKey;
  final PublishWork send;
  final String? pendingId;
  final Future<void> Function()? onDiscard;

  ContentLineState state = ContentLineState.waiting;
  double progress = 0;
  Failure? failure;

  bool get isOffline =>
      state == ContentLineState.failed &&
      (failure is NetworkFailure || failure is TimeoutFailure);

  ContentPublishing publishing() => ContentPublishing(
    kind,
    progress: progress,
    isEdit: isEdit,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );

  ContentPublishFailed failed() => ContentPublishFailed(
    kind,
    failure: failure!,
    isEdit: isEdit,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );

  ContentLineItem get item => ContentLineItem(
    id: key,
    state: state,
    progress: progress,
    isEdit: isEdit,
    failure: failure,
    previewPath: previewPath,
    previewUrl: previewUrl,
    previewCacheKey: previewCacheKey,
  );
}
