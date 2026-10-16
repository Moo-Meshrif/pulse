import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/events/event_bus.dart';
import '../../domain/entity/content_publish_status.dart';
import '../enums/content_kind.dart';

/// Sends a job's work, telling how far it got (0..1).
typedef PublishWork = Future<void> Function(void Function(double) report);

/// Sends posts, shorts and stories in the background, one at a time per kind, so a story does not wait
/// behind a post. It is a repository because it holds state across screens: Home shows how it goes while
/// the composer has already closed. Each status is sent on the `EventBus` as `ContentPublishStatus`; a
/// screen that starts later reads [current].
abstract interface class ContentPublishRepository {
  /// Starts [send] for [kind]; returns false (and does nothing) while another one of [kind] is going
  /// out. A failed one waits for Retry or Discard, unless [replacesFailed] drops it for this one.
  /// [previewPath] is a picked file to show while it goes out.
  bool enqueue({
    required ContentKind kind,
    required PublishWork send,
    bool isEdit = false,
    String? previewPath,
    bool replacesFailed = false,
  });

  /// Sends the failed one of [kind] again; does nothing in any other state.
  void retry(ContentKind kind);

  /// Drops the failed one of [kind].
  void discard(ContentKind kind);

  ContentPublishStatus current(ContentKind kind);
}

@LazySingleton(as: ContentPublishRepository)
final class ContentPublishRepositoryImpl implements ContentPublishRepository {
  ContentPublishRepositoryImpl(this._events);

  final EventBus _events;
  final _current = <ContentKind, ContentPublishStatus>{};
  final _jobs = <ContentKind, _Job>{};

  @override
  ContentPublishStatus current(ContentKind kind) =>
      _current[kind] ?? ContentPublishIdle(kind);

  @override
  bool enqueue({
    required ContentKind kind,
    required PublishWork send,
    bool isEdit = false,
    String? previewPath,
    bool replacesFailed = false,
  }) {
    final status = current(kind);
    final isFree =
        status is ContentPublishIdle ||
        (replacesFailed && status is ContentPublishFailed);
    if (!isFree) return false;
    _jobs[kind] = _Job(
      kind: kind,
      isEdit: isEdit,
      previewPath: previewPath,
      send: send,
    );
    _start(kind);
    return true;
  }

  @override
  void retry(ContentKind kind) {
    if (current(kind) is ContentPublishFailed && _jobs[kind] != null) {
      _start(kind);
    }
  }

  @override
  void discard(ContentKind kind) {
    if (current(kind) is! ContentPublishFailed) return;
    _jobs.remove(kind);
    _emit(ContentPublishIdle(kind));
  }

  void _emit(ContentPublishStatus status) {
    _current[status.kind] = status;
    _events.fire(status);
  }

  void _start(ContentKind kind) {
    final job = _jobs[kind]!;
    _emit(job.publishing(0));
    unawaited(_run(job));
  }

  Future<void> _run(_Job job) async {
    var progress = 0.0;
    void report(double value) {
      // A retried file counts again from zero; the bar keeps its place.
      final next = value.clamp(0.0, 1.0);
      if (next <= progress || !identical(_jobs[job.kind], job)) return;
      progress = next;
      _emit(job.publishing(progress));
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
    _jobs.remove(job.kind);
    _emit(ContentPublishDone(job.kind, isEdit: job.isEdit));
    _emit(ContentPublishIdle(job.kind));
  }

  void _fail(_Job job, Failure failure) => _emit(
    ContentPublishFailed(
      job.kind,
      failure: failure,
      isEdit: job.isEdit,
      previewPath: job.previewPath,
    ),
  );
}

class _Job {
  const _Job({
    required this.kind,
    required this.isEdit,
    required this.send,
    this.previewPath,
  });

  final ContentKind kind;
  final bool isEdit;
  final String? previewPath;
  final PublishWork send;

  ContentPublishing publishing(double progress) => ContentPublishing(
    kind,
    progress: progress,
    isEdit: isEdit,
    previewPath: previewPath,
  );
}
