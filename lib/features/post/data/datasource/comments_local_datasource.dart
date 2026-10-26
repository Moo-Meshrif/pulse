import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/snapshot_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../enums/comment_sort.dart';
import '../model/comment_page_model.dart';

/// The first page of a post's comments, one per sort, saved on this device for each user. A page is
/// kept for [keepFor] after it was saved; an older one is not read and is deleted on the next save.
@lazySingleton
class CommentsLocalDatasource {
  CommentsLocalDatasource(this._storage);

  final SnapshotStorage _storage;

  static const keepFor = Duration(days: 1);

  /// Null when nothing is saved, it is older than [keepFor], or the saved data cannot be read.
  CommentPageModel? read(String userId, String postId, CommentSort sort) {
    final key = StorageKeys.comments(userId, postId, sort.wire);
    final saved = _readIndex(StorageKeys.commentsIndex(userId))[key];
    if (saved == null || _expired(saved)) return null;
    final raw = _storage.read(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic>
          ? CommentPageModel.fromJson(json)
          : null;
    } on FormatException {
      return null;
    }
  }

  /// A failed write is reported and never fails the caller: the comments on screen are already right.
  Future<void> write(
    String userId,
    String postId,
    CommentSort sort,
    CommentPageModel page,
  ) async {
    try {
      final key = StorageKeys.comments(userId, postId, sort.wire);
      await _storage.write(key, jsonEncode(page.toJson()));
      await _remember(userId, key);
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }

  /// Notes when [key] was saved and deletes the pages that are too old.
  Future<void> _remember(String userId, String key) async {
    final indexKey = StorageKeys.commentsIndex(userId);
    final saved = _readIndex(indexKey);
    for (final entry in saved.entries.toList()) {
      if (!_expired(entry.value)) continue;
      saved.remove(entry.key);
      await _storage.delete(entry.key);
    }
    saved[key] = clock.now().millisecondsSinceEpoch;
    await _storage.write(indexKey, jsonEncode(saved));
  }

  bool _expired(int savedAt) =>
      clock.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAt)) >
      keepFor;

  /// Key to the time it was saved, in milliseconds.
  Map<String, int> _readIndex(String indexKey) {
    final raw = _storage.read(indexKey);
    if (raw == null) return {};
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return {};
      return {
        for (final entry in json.entries)
          if (entry.value is int) entry.key: entry.value as int,
      };
    } on FormatException {
      return {};
    }
  }
}
