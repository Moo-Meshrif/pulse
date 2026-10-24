import 'dart:io';

import 'package:hive_ce/hive_ce.dart';

import '../../error/error_reporter.dart';
import 'app_folders.dart';

/// The saved Home (lists that grow) on the device, as key to JSON string. Small flags stay in
/// `LocalStorageService`. Never store signed media links here: they expire. Nothing outside the adapter
/// below knows which database holds it.
abstract interface class SnapshotStorage {
  String? read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  /// Removes everything (sign-out).
  Future<void> clear();

  Future<void> close();
}

/// Hive adapter: one box in the cache folder.
final class HiveSnapshotStorage implements SnapshotStorage {
  HiveSnapshotStorage._(this._box);

  static const _boxName = 'feed_cache';

  final Box<String> _box;

  /// Opens the box in `<cache>/hive`. A box that cannot be opened is deleted and opened empty.
  static Future<HiveSnapshotStorage> openIn(AppFolders folders) =>
      open('${folders.cache}${Platform.pathSeparator}hive');

  static Future<HiveSnapshotStorage> open(String path) async {
    Hive.init(path);
    try {
      return HiveSnapshotStorage._(await Hive.openBox<String>(_boxName));
    } catch (error, stack) {
      ErrorReporter.report(error, stack);
      await Hive.deleteBoxFromDisk(_boxName);
      return HiveSnapshotStorage._(await Hive.openBox<String>(_boxName));
    }
  }

  @override
  String? read(String key) => _box.get(key);

  @override
  Future<void> write(String key, String value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  Future<void> close() => _box.close();
}
