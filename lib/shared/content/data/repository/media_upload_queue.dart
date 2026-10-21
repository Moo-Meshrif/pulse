import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/cancel_signal.dart';
import '../enums/content_kind.dart';
import '../enums/media_upload_status.dart';
import 'content_media_repository.dart';

/// One file of a [MediaUploadQueue].
class _Upload {
  _Upload({
    required this.item,
    required this.kind,
    required this.contentId,
    required this.stem,
  });

  final MediaToSend item;
  final ContentKind kind;
  final String contentId;
  final String stem;

  MediaUploadStatus status = MediaUploadStatus.waiting;
  CancelSignal cancel = CancelSignal();

  /// The send in progress; it never throws.
  Future<void>? running;

  bool get isActive =>
      status == MediaUploadStatus.waiting ||
      status == MediaUploadStatus.uploading;
}

/// Uploads the files of one piece of content while it is being written, so they are on the server by the
/// time it is shared. Files go out in the order they were added, at most [_maxRunning] at a time (a video
/// is shrunk first, and the encoder takes one at a time). A file is named by its `stem`, so moving it in
/// the post never uploads it again; a file already in its folder is not sent again. Each file is known by
/// a `key` the caller chooses.
@injectable
class MediaUploadQueue {
  static const _maxRunning = 2;

  MediaUploadQueue(this._media);

  final ContentMediaRepository _media;
  final _uploads = <String, _Upload>{};
  final _changes = StreamController<(String, MediaUploadStatus)>.broadcast();

  /// The names already in each folder, read once and kept up to date as files go out.
  final _existing = <String, Future<Set<String>>>{};

  /// A file is being sent now.
  bool get isUploading => _uploads.values.any(
    (upload) => upload.status == MediaUploadStatus.uploading,
  );

  /// Every change of a file's status, by key.
  Stream<(String, MediaUploadStatus)> get changes => _changes.stream;

  /// Adds a file of the content [contentId] to upload as `{stem}.{ext}` in its folder; a key already added
  /// is ignored.
  void add(
    String key,
    MediaToSend item, {
    required ContentKind kind,
    required String contentId,
    required String stem,
  }) {
    if (_uploads.containsKey(key)) return;
    _uploads[key] = _Upload(
      item: item,
      kind: kind,
      contentId: contentId,
      stem: stem,
    );
    _setStatus(key, MediaUploadStatus.waiting);
    _startNext();
  }

  /// Tries a failed file again.
  void retry(String key) {
    final upload = _uploads[key];
    if (upload == null || upload.status != MediaUploadStatus.failed) return;
    upload.cancel = CancelSignal();
    _setStatus(key, MediaUploadStatus.waiting);
    _startNext();
  }

  /// Stops the file's upload and deletes whatever of it reached the server, including an upload that
  /// finished after it was stopped.
  Future<void> remove(String key) async {
    final upload = _uploads.remove(key);
    if (upload == null) return;
    upload.cancel.cancel();
    final wasStarted = upload.status != MediaUploadStatus.waiting;
    await upload.running;
    _startNext();
    if (wasStarted) await _deleteFromServer(upload);
  }

  /// Completes when no file is waiting or uploading; failed files stay failed.
  Future<void> settled() async {
    while (true) {
      final running = [
        for (final upload in _uploads.values)
          if (upload.isActive) ?upload.running,
      ];
      if (running.isEmpty) return;
      await Future.wait(running);
    }
  }

  /// Stops every upload and forgets them; what reached the server stays there.
  void stop() {
    for (final upload in _uploads.values) {
      upload.cancel.cancel();
    }
    _uploads.clear();
    unawaited(_changes.close());
  }

  void _startNext() {
    final uploads = _uploads.values;
    var running = uploads
        .where((upload) => upload.status == MediaUploadStatus.uploading)
        .length;
    for (final entry in _uploads.entries) {
      if (running >= _maxRunning) return;
      if (entry.value.status != MediaUploadStatus.waiting) continue;
      _start(entry.key, entry.value);
      running++;
    }
  }

  void _start(String key, _Upload upload) {
    _setStatus(key, MediaUploadStatus.uploading);
    upload.running = _send(key, upload);
  }

  Future<void> _send(String key, _Upload upload) async {
    final cancel = upload.cancel;
    final result = await _uploadOnce(upload);
    if (cancel.isCancelled || _uploads[key] != upload) return;
    _setStatus(key, result);
    _startNext();
  }

  /// Never throws: anything that goes wrong is a failed upload the person can retry.
  Future<MediaUploadStatus> _uploadOnce(_Upload upload) async {
    try {
      final folder = _media.folderOf(upload.contentId);
      await _media.send(
        upload.kind,
        upload.item,
        folder: folder,
        stem: upload.stem,
        existing: await _existingIn(folder),
        cancel: upload.cancel,
      );
      return MediaUploadStatus.uploaded;
    } on Object {
      return MediaUploadStatus.failed;
    }
  }

  Future<Set<String>> _existingIn(String folder) =>
      _existing[folder] ??= _listOrEmpty(folder);

  /// An empty set when [folder] cannot be listed (a file there is then sent again); it is listed again
  /// next time.
  Future<Set<String>> _listOrEmpty(String folder) async {
    try {
      return await _media.existing(folder);
    } on Failure {
      _existing.remove(folder)?.ignore(); // the future being completed here
      return <String>{};
    }
  }

  /// Looks again, so an upload that ended after it was stopped is found too.
  Future<void> _deleteFromServer(_Upload upload) async {
    final folder = _folderOrNull(upload.contentId);
    final names = folder == null ? null : await _namesOrNull(folder);
    // Not listed: the cleanup after a discard catches it (plan Phase 5).
    if (folder == null || names == null) return;
    final ours = names.where((name) => _isFileOf(upload.stem, name)).toList();
    if (ours.isEmpty) return;
    (await _existingIn(folder)).removeAll(ours);
    await _media.removeQuietly([for (final name in ours) '$folder/$name']);
  }

  /// Null when no one is signed in any more.
  String? _folderOrNull(String contentId) {
    try {
      return _media.folderOf(contentId);
    } on Object {
      return null;
    }
  }

  Future<Set<String>?> _namesOrNull(String folder) async {
    try {
      return await _media.existing(folder);
    } on Failure {
      return null;
    }
  }

  bool _isFileOf(String stem, String name) =>
      name.startsWith('$stem.') || name.startsWith('${stem}_thumb.');

  void _setStatus(String key, MediaUploadStatus status) {
    final upload = _uploads[key];
    if (upload == null) return;
    upload.status = status;
    if (!_changes.isClosed) _changes.add((key, status));
  }
}
