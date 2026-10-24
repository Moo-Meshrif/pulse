import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/services/storage/app_folders.dart';
import '../../../../core/services/storage/backup_exclusion.dart';
import '../../../../core/services/storage/local_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../../../../core/utils/uuid_v4.dart';
import '../model/post_draft_media_model.dart';
import '../model/post_draft_model.dart';

/// The New post draft of the signed-in user, kept on this device: the record in local storage and its
/// photos, videos and video frames in `post_drafts/{uid}/{draftId}/` (left out of phone backups). It also
/// keeps the posts shared from it until they are out, so a post survives the app closing. Each user has
/// their own, so another account on the phone never sees them.
abstract interface class PostDraftDatasource {
  /// The draft with full file paths; a photo or video whose file is gone is left out. Null when there is
  /// none, it cannot be read, or no one is signed in.
  PostDraftModel? read();

  /// Saves [draft], replacing the last one; its files must be in its folder ([keep]).
  Future<void> save(PostDraftModel draft);

  /// Puts the file at [path] in the folder of draft [draftId] and returns its new path. The app's own
  /// temporary copy (the picker's, a video frame) is moved; any other file is copied, never moved.
  Future<String> keep(String draftId, String path);

  /// Forgets the record; the files stay, because a shared post may still be sending them.
  Future<void> forget();

  /// Deletes the folder of draft [draftId]. Never throws.
  Future<void> deleteFiles(String draftId);

  /// Deletes one file of a draft. Never throws, and touches nothing outside the drafts folder.
  Future<void> deleteFile(String path);

  /// The shared posts not out yet, oldest first, with full file paths (a file that is gone is kept: the
  /// server may have it). Empty when there are none or no one is signed in; null when the list cannot be
  /// read.
  List<PostDraftModel>? readShared();

  /// Saves [post] in the shared list, replacing the one with its id.
  Future<void> saveShared(PostDraftModel post);

  /// Takes [id] off the shared list; its files stay.
  Future<void> forgetShared(String id);

  /// Deletes the signed-in user's draft folders except those of [ids]. Never throws.
  Future<void> deleteFoldersExcept(Set<String> ids);
}

@LazySingleton(as: PostDraftDatasource)
final class LocalPostDraftDatasource implements PostDraftDatasource {
  LocalPostDraftDatasource(
    this._storage,
    this._folders,
    this._backup,
    this._client,
  );

  static const _rootName = 'post_drafts';

  final LocalStorageService _storage;
  final AppFolders _folders;
  final BackupExclusionService _backup;
  final SupabaseClient _client;

  /// The drafts folder was left out of backups during this run.
  bool _isExcluded = false;

  String? get _uid => _client.auth.currentUser?.id;

  String get _root => '${_folders.support}/$_rootName';

  String _folder(String uid, String draftId) => '$_root/$uid/$draftId';

  @override
  PostDraftModel? read() {
    final uid = _uid;
    if (uid == null) return null;
    final draft = _storage.getValue<PostDraftModel>(
      StorageKeys.postDraft(uid),
      decode: PostDraftModel.fromJson,
    );
    final id = draft?.id;
    if (draft == null || id == null) return null;
    final folder = _folder(uid, id);
    return draft.withMedia([
      for (final item in draft.media ?? const <PostDraftMediaModel>[])
        ?_onDevice(folder, item),
    ]);
  }

  @override
  Future<void> save(PostDraftModel draft) => Guard.run(() async {
    final uid = _uid;
    if (uid == null || draft.id == null) return;
    await _storage.setValue<PostDraftModel>(
      StorageKeys.postDraft(uid),
      _stored(draft),
      encode: (value) => value.toJson(),
    );
  }, checkOffline: false);

  @override
  List<PostDraftModel>? readShared() {
    final uid = _uid;
    if (uid == null) return const [];
    final key = StorageKeys.postShared(uid);
    if (!_storage.containsKey(key)) return const [];
    final shared = _storage.getValue<List<PostDraftModel>>(
      key,
      decode: _decodeShared,
    );
    return shared
        ?.map((post) => _withPaths(_folder(uid, post.id!), post))
        .toList();
  }

  @override
  Future<void> saveShared(PostDraftModel post) => Guard.run(() async {
    final id = post.id;
    if (id == null) return;
    final others = (readShared() ?? const <PostDraftModel>[]).where(
      (item) => item.id != id,
    );
    await _writeShared([...others, post]);
  }, checkOffline: false);

  @override
  Future<void> forgetShared(String id) => Guard.run(() async {
    final shared = readShared() ?? const <PostDraftModel>[];
    if (!shared.any((item) => item.id == id)) return;
    await _writeShared([
      for (final item in shared)
        if (item.id != id) item,
    ]);
  }, checkOffline: false);

  @override
  Future<void> deleteFoldersExcept(Set<String> ids) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final root = Directory('$_root/$uid');
      if (!root.existsSync()) return;
      await for (final entry in root.list()) {
        final name = _nameOf(entry.path)!;
        if (entry is Directory && !ids.contains(name)) {
          await entry.delete(recursive: true);
        }
      }
    } on FileSystemException {
      // tried again at the next start
    }
  }

  Future<void> _writeShared(List<PostDraftModel> shared) async {
    final uid = _uid;
    if (uid == null) return;
    final key = StorageKeys.postShared(uid);
    if (shared.isEmpty) {
      await _storage.remove(key);
      return;
    }
    await _storage.setValue<List<PostDraftModel>>(key, [
      for (final post in shared) _stored(post),
    ], encode: (value) => [for (final post in value) post.toJson()]);
  }

  /// A list of another version, or with a post without id, cannot be read.
  static List<PostDraftModel>? _decodeShared(Object? json) {
    if (json is! List) return null;
    final shared = json.map(PostDraftModel.fromJson).toList();
    if (shared.any((post) => post?.id == null)) return null;
    return shared.cast<PostDraftModel>();
  }

  /// [draft] as stored: file names inside its folder.
  PostDraftModel _stored(PostDraftModel draft) => draft.withMedia([
    for (final item in draft.media ?? const <PostDraftMediaModel>[])
      item.withFiles(_nameOf(item.path), _nameOf(item.poster)),
  ]);

  /// [post] as stored, with full paths in [folder].
  PostDraftModel _withPaths(String folder, PostDraftModel post) =>
      post.withMedia([
        for (final item in post.media ?? const <PostDraftMediaModel>[])
          item.withFiles(
            item.path == null ? null : '$folder/${item.path}',
            item.poster == null ? null : '$folder/${item.poster}',
          ),
      ]);

  @override
  Future<String> keep(String draftId, String path) => Guard.run(() async {
    final uid = _uid;
    if (uid == null) return path;
    final folder = await Directory(_folder(uid, draftId))
        .create(recursive: true);
    await _excludeFromBackup();
    final target = '${folder.path}/${uuidV4()}${_extensionOf(path)}';
    if (_folders.isTemporary(path)) {
      await _move(File(path), target);
    } else {
      await File(path).copy(target);
    }
    return target;
  }, checkOffline: false);

  @override
  Future<void> forget() => Guard.run(() async {
    final uid = _uid;
    if (uid == null) return;
    await _storage.remove(StorageKeys.postDraft(uid));
  }, checkOffline: false);

  @override
  Future<void> deleteFiles(String draftId) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await Directory(_folder(uid, draftId)).delete(recursive: true);
    } on FileSystemException {
      // already gone
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    if (!path.startsWith('$_root/')) return;
    try {
      await File(path).delete();
    } on FileSystemException {
      // already gone
    }
  }

  /// [item] with full paths, or null when its file is gone; a missing frame is dropped alone.
  PostDraftMediaModel? _onDevice(String folder, PostDraftMediaModel item) {
    final name = item.path;
    if (name == null || !File('$folder/$name').existsSync()) return null;
    final poster = item.poster;
    final hasPoster = poster != null && File('$folder/$poster').existsSync();
    return item.withFiles(
      '$folder/$name',
      hasPoster ? '$folder/$poster' : null,
    );
  }

  String? _nameOf(String? path) {
    if (path == null) return null;
    final slash = path.lastIndexOf('/');
    return slash < 0 ? path : path.substring(slash + 1);
  }

  String _extensionOf(String path) {
    final name = _nameOf(path)!;
    final dot = name.lastIndexOf('.');
    return dot < 0 ? '' : name.substring(dot).toLowerCase();
  }

  /// A rename, or a copy and delete when the file is on another volume.
  Future<void> _move(File file, String target) async {
    try {
      await file.rename(target);
    } on FileSystemException {
      await file.copy(target);
      await file.delete();
    }
  }

  /// Best effort: a draft is kept even if the folder could not be left out of backups.
  Future<void> _excludeFromBackup() async {
    if (_isExcluded) return;
    try {
      await _backup.exclude(_root);
      _isExcluded = true;
    } on Failure {
      // tried again with the next file
    }
  }
}
