import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/media_picker_service.dart';
import '../../../../shared/content/data/datasource/pending_content_datasource.dart';
import '../../../../shared/content/data/enums/content_kind.dart';
import '../../../../shared/content/data/enums/media_upload_status.dart';
import '../../../../shared/content/data/repository/content_discard_repository.dart';
import '../../../../shared/content/data/repository/content_media_repository.dart';
import '../../../../shared/content/data/repository/media_upload_queue.dart';
import '../../domain/entity/new_post_entity.dart';
import '../datasource/post_draft_datasource.dart';
import '../model/post_draft_model.dart';
import 'post_publishing_repository.dart';

/// The New post draft while it is written: saved on the device, with each file uploaded as soon as it is
/// read. One per New post screen. Uploads are known by the file's path on the device.
abstract class PostDraftRepository {
  Stream<(String, MediaUploadStatus)> get uploadChanges;

  PostDraftModel? read();

  /// A draft left open when the app was killed: it is opened again at start.
  bool get hasOpenDraft;

  /// Saves [draft] after a short pause; null (nothing in it) forgets it.
  void saveSoon(PostDraftModel? draft);

  /// Saves [draft] at once; null (nothing in it) forgets it. [isOpen] false: the screen is being closed
  /// by the person, so the draft is not opened again at start. Never throws: the draft stays as last
  /// saved.
  Future<void> saveNow(PostDraftModel? draft, {bool isOpen = true});

  /// [picked] moved into the folder of [draftId]. A file that cannot be moved stays where it is, so it can
  /// still be shared (it is only missing from the draft after a restart).
  Future<List<PickedMedia>> keepPicked(
    String draftId,
    List<PickedMedia> picked,
  );

  /// A video's frame moved into the folder of [draftId]; null when it could not be moved.
  Future<String?> keepPoster(String draftId, String poster);

  /// Starts uploading [media], already read, as [mediaId] of [draftId]; [poster] is a video's frame. The
  /// first upload opens the draft on the server.
  void upload(
    String draftId,
    String mediaId,
    PickedMedia media, {
    String? poster,
  });

  void retry(String path);

  /// Takes a file off the draft: its upload stops, and the file and its [poster] are deleted.
  void remove(String path, {String? poster});

  /// A frame kept for a file that was taken off meanwhile.
  void deleteFile(String path);

  /// Stops the uploads and forgets the draft. When it may have reached the server, the discard is kept
  /// and sent later if offline; local files are deleted without waiting.
  Future<void> discard(String draftId);

  /// Hands [draft] to the background sender, which builds the post with [build] and waits for uploads
  /// still going. The uploads go on after the screen closes. False (nothing done) while another post goes
  /// out.
  bool share(
    PostDraftModel draft, {
    required Future<NewPostEntity> Function() build,
    String? previewPath,
  });

  /// Saves a pending change. Without Share the uploads stop; missing files go when the draft reopens.
  void close();
}

@Injectable(as: PostDraftRepository)
class PostDraftRepositoryImpl implements PostDraftRepository {
  /// Typing does not write on every key.
  static const _saveDelay = Duration(milliseconds: 400);

  PostDraftRepositoryImpl(
    this._local,
    this._uploads,
    this._server,
    this._shared,
    this._discards,
  ) {
    _uploaded = _uploads.changes.listen(_uploadChanged);
  }

  final PostDraftDatasource _local;
  final MediaUploadQueue _uploads;
  final PendingContentDatasource _server;
  final PostPublishingRepository _shared;
  final ContentDiscardRepository _discards;

  /// Opening the draft on the server; null again after a failure, so the next upload asks again.
  Future<void>? _serverDraft;
  bool _isOpeningServerDraft = false;

  /// Kept in the saved draft, so a discard after a restart still tells the server.
  bool _isOnServer = false;

  /// The screen is open: if the app is killed now, the draft opens again at the next start.
  bool _isOpen = true;
  StreamSubscription<(String, MediaUploadStatus)>? _uploaded;

  /// Shared: the uploads keep going after the screen closes, for the sender.
  bool _isHandedOver = false;

  /// Shared or discarded: nothing is saved any more.
  bool _isDone = false;

  Timer? _saveTimer;
  PostDraftModel? _lastDraft;

  @override
  Stream<(String, MediaUploadStatus)> get uploadChanges => _uploads.changes;

  @override
  PostDraftModel? read() {
    final draft = _local.read();
    _isOnServer = draft?.isOnServer ?? false;
    return draft;
  }

  @override
  bool get hasOpenDraft => _local.read()?.isOpen ?? false;

  @override
  void saveSoon(PostDraftModel? draft) {
    if (_isDone) return;
    _saveTimer?.cancel();
    _lastDraft = draft;
    _saveTimer = Timer(_saveDelay, () => unawaited(saveNow(draft)));
  }

  @override
  Future<void> saveNow(PostDraftModel? draft, {bool isOpen = true}) async {
    _saveTimer?.cancel();
    if (_isDone) return;
    _isOpen = isOpen;
    _lastDraft = draft;
    try {
      await (draft == null ? _local.forget() : _local.save(_stamped(draft)));
    } on Failure {
      // kept as last saved
    }
  }

  @override
  Future<List<PickedMedia>> keepPicked(
    String draftId,
    List<PickedMedia> picked,
  ) => Future.wait(picked.map((item) => _keepPicked(draftId, item)));

  @override
  Future<String?> keepPoster(String draftId, String poster) =>
      _keepOrNull(draftId, poster);

  @override
  void upload(
    String draftId,
    String mediaId,
    PickedMedia media, {
    String? poster,
  }) {
    unawaited(_serverDraft ??= _openServerDraft(draftId));
    _uploads.add(
      media.path,
      MediaToSend(
        filePath: media.path,
        isVideo: media.isVideo,
        thumbFilePath: poster,
        width: media.width,
        height: media.height,
        durationMs: media.durationMs,
        sizeBytes: media.sizeBytes,
      ),
      kind: ContentKind.post,
      contentId: draftId,
      stem: mediaId,
    );
  }

  @override
  void retry(String path) => _uploads.retry(path);

  @override
  void remove(String path, {String? poster}) {
    unawaited(_uploads.remove(path));
    unawaited(_local.deleteFile(path));
    if (poster != null) unawaited(_local.deleteFile(poster));
  }

  @override
  void deleteFile(String path) => unawaited(_local.deleteFile(path));

  @override
  Future<void> discard(String draftId) async {
    final mayBeOnServer =
        _isOnServer || _isOpeningServerDraft || _uploads.isUploading;
    _stop();
    _uploads.stop();
    await _local.forget();
    if (mayBeOnServer) await _discards.save(draftId, ContentKind.post);
    unawaited(_local.deleteFiles(draftId));
    if (mayBeOnServer) unawaited(_discards.send(draftId, ContentKind.post));
  }

  @override
  bool share(
    PostDraftModel draft, {
    required Future<NewPostEntity> Function() build,
    String? previewPath,
  }) {
    final isStarted = _shared.send(
      _stamped(draft),
      build: build,
      beforeUpload: _uploads.settled,
      onStop: _uploads.stop,
      previewPath: previewPath,
    );
    if (isStarted) {
      _stop();
      _isHandedOver = true;
    }
    return isStarted;
  }

  @override
  void close() {
    if (_saveTimer?.isActive ?? false) {
      unawaited(saveNow(_lastDraft, isOpen: _isOpen));
    }
    if (!_isHandedOver) _uploads.stop();
    unawaited(_uploaded?.cancel());
  }

  PostDraftModel _stamped(PostDraftModel draft) =>
      draft.withState(isOpen: _isOpen, isOnServer: _isOnServer);

  void _uploadChanged((String, MediaUploadStatus) change) {
    if (change.$2 == MediaUploadStatus.uploaded) _markOnServer();
  }

  void _markOnServer() {
    if (_isOnServer) return;
    _isOnServer = true;
    final draft = _lastDraft;
    if (draft != null && !_isDone) unawaited(saveNow(draft, isOpen: _isOpen));
  }

  void _stop() {
    _isDone = true;
    _saveTimer?.cancel();
  }

  Future<PickedMedia> _keepPicked(String draftId, PickedMedia item) async {
    final path = await _keepOrNull(draftId, item.path);
    if (path == null) return item;
    return PickedMedia(
      path: path,
      isVideo: item.isVideo,
      durationMs: item.durationMs,
      width: item.width,
      height: item.height,
      sizeBytes: item.sizeBytes,
      blurhash: item.blurhash,
    );
  }

  Future<String?> _keepOrNull(String draftId, String path) async {
    try {
      return await _local.keep(draftId, path);
    } on Failure {
      return null;
    }
  }

  /// Best effort: uploads work without it.
  Future<void> _openServerDraft(String draftId) async {
    _isOpeningServerDraft = true;
    try {
      await _server.openDraft(draftId, ContentKind.post);
      _markOnServer();
    } on Failure {
      _serverDraft = null;
    } finally {
      _isOpeningServerDraft = false;
    }
  }
}
