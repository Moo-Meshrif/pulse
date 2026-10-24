import 'package:pulse/core/services/storage/snapshot_storage.dart';

/// [SnapshotStorage] in memory, for tests that do not need Hive.
class MemorySnapshotStorage implements SnapshotStorage {
  final values = <String, String>{};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<void> close() async {}
}
