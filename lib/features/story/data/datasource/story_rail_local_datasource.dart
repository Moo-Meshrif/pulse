import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/error/error_reporter.dart';
import '../../../../core/services/storage/snapshot_storage.dart';
import '../../../../core/services/storage/storage_keys.dart';
import '../model/story_rail_item_model.dart';

/// The Stories rail of one user saved on this device. The only link in it is the public avatar.
@lazySingleton
class StoryRailLocalDatasource {
  StoryRailLocalDatasource(this._storage);

  final SnapshotStorage _storage;

  /// Null when nothing is saved or the saved data cannot be read; an empty list is a saved rail with no
  /// one on it.
  List<StoryRailItemModel>? read(String userId) {
    final raw = _storage.read(StorageKeys.storyRail(userId));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! List) return null;
      return [
        for (final item in json)
          if (item is Map<String, dynamic>) StoryRailItemModel.fromJson(item),
      ];
    } on FormatException {
      return null;
    }
  }

  /// A failed write is reported and never fails the caller.
  Future<void> write(String userId, List<StoryRailItemModel> items) async {
    try {
      await _storage.write(
        StorageKeys.storyRail(userId),
        jsonEncode(items.map((item) => item.toJson()).toList()),
      );
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
