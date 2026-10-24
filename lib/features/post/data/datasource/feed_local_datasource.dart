import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/snapshot_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../model/feed_page_model.dart';

/// The first page of one user's Home feed saved on this device. Posts hold storage paths only: a signed
/// media link expires and is never written.
@lazySingleton
class FeedLocalDatasource {
  FeedLocalDatasource(this._storage);

  final SnapshotStorage _storage;

  /// Null when nothing is saved or the saved data cannot be read.
  FeedPageModel? read(String userId) {
    final raw = _storage.read(StorageKeys.feed(userId));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      return json is Map<String, dynamic> ? FeedPageModel.fromJson(json) : null;
    } on FormatException {
      return null;
    }
  }

  /// A failed write is reported and never fails the caller: the feed on screen is already right.
  Future<void> write(String userId, FeedPageModel feed) async {
    try {
      await _storage.write(StorageKeys.feed(userId), jsonEncode(feed.toJson()));
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
