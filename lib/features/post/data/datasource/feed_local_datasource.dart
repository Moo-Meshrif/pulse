import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/snapshot_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../../../../core/utils/json_mapper.dart';
import '../model/feed_page_model.dart';

/// One user's Home feed saved on this device: the pages loaded so far, kept for [keepFor] after the last
/// save. Posts hold storage paths only: a signed media link expires and is never written.
@lazySingleton
class FeedLocalDatasource {
  FeedLocalDatasource(this._storage);

  final SnapshotStorage _storage;

  static const _savedAt = 'saved_at';

  static const keepFor = Duration(days: 1);

  /// Null when nothing is saved, it is older than [keepFor], or the saved data cannot be read.
  FeedPageModel? read(String userId) {
    final raw = _storage.read(StorageKeys.feed(userId));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) return null;
      final savedAt = JsonMapper.date(json[_savedAt]);
      if (savedAt == null || clock.now().difference(savedAt) > keepFor) {
        return null;
      }
      return FeedPageModel.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  /// A failed write is reported and never fails the caller: the feed on screen is already right.
  Future<void> write(String userId, FeedPageModel feed) async {
    try {
      await _storage.write(
        StorageKeys.feed(userId),
        jsonEncode({
          ...feed.toJson(),
          _savedAt: clock.now().toUtc().toIso8601String(),
        }),
      );
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
