import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entity/post_publish_status.dart';

/// Sends one post at a time in the background and tells how it is going. It is a repository because it
/// holds state across screens: Home shows [status] while the composer has already closed.
abstract interface class PostPublishRepository {
  /// Idle, publishing, failed or done. A new listener gets the current status first.
  Stream<PostPublishStatus> get status;

  /// Starts [send]; returns false (and does nothing) while another post is publishing or has failed and
  /// waits for Retry or Discard. [previewPath] is a picked file to show while it goes out.
  bool enqueue({
    required bool isEdit,
    String? previewPath,
    required Future<void> Function() send,
  });

  /// Sends the failed post again; does nothing in any other state.
  void retry();

  /// Drops the failed post.
  void discard();
}

@LazySingleton(as: PostPublishRepository)
final class PostPublishRepositoryImpl implements PostPublishRepository {
  final _changes = StreamController<PostPublishStatus>.broadcast();
  PostPublishStatus _current = const PostPublishIdle();
  _Job? _job;

  @override
  Stream<PostPublishStatus> get status async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  bool enqueue({
    required bool isEdit,
    String? previewPath,
    required Future<void> Function() send,
  }) {
    if (_current is! PostPublishIdle) return false;
    _job = _Job(isEdit: isEdit, previewPath: previewPath, send: send);
    _start();
    return true;
  }

  @override
  void retry() {
    if (_current is PostPublishFailed && _job != null) _start();
  }

  @override
  void discard() {
    if (_current is! PostPublishFailed) return;
    _job = null;
    _emit(const PostPublishIdle());
  }

  void _emit(PostPublishStatus status) {
    _current = status;
    _changes.add(status);
  }

  void _start() {
    final job = _job!;
    _emit(PostPublishing(isEdit: job.isEdit, previewPath: job.previewPath));
    unawaited(_run(job));
  }

  Future<void> _run(_Job job) async {
    try {
      await job.send();
    } on Failure catch (failure) {
      _fail(job, failure);
      return;
    } catch (error, stackTrace) {
      _fail(job, Guard.toFailure(error, stackTrace));
      return;
    }
    _job = null;
    _emit(PostPublishDone(isEdit: job.isEdit));
    _emit(const PostPublishIdle());
  }

  void _fail(_Job job, Failure failure) => _emit(
    PostPublishFailed(
      failure: failure,
      isEdit: job.isEdit,
      previewPath: job.previewPath,
    ),
  );
}

class _Job {
  const _Job({required this.isEdit, this.previewPath, required this.send});

  final bool isEdit;
  final String? previewPath;
  final Future<void> Function() send;
}
