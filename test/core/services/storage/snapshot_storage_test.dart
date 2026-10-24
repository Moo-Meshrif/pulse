import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:pulse/core/services/storage/snapshot_storage.dart';

void main() {
  late Directory dir;
  HiveSnapshotStorage? storage;

  setUp(() => dir = Directory.systemTemp.createTempSync('pulse_hive_test'));

  tearDown(() async {
    await storage?.close();
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  test('writes, reads, deletes and clears', () async {
    storage = await HiveSnapshotStorage.open(dir.path);

    expect(storage!.read('a'), isNull);
    await storage!.write('a', '1');
    await storage!.write('b', '2');
    expect(storage!.read('a'), '1');

    await storage!.delete('a');
    expect(storage!.read('a'), isNull);
    expect(storage!.read('b'), '2');

    await storage!.clear();
    expect(storage!.read('b'), isNull);
  });

  test('keeps values after the box is reopened', () async {
    storage = await HiveSnapshotStorage.open(dir.path);
    await storage!.write('a', '1');
    await storage!.close();
    await Hive.close();

    storage = await HiveSnapshotStorage.open(dir.path);

    expect(storage!.read('a'), '1');
  });

  test('a corrupt box file reopens empty', () async {
    storage = await HiveSnapshotStorage.open(dir.path);
    await storage!.write('a', '1');
    await storage!.close();
    await Hive.close();
    File('${dir.path}/feed_cache.hive').writeAsBytesSync(List.filled(64, 7));

    storage = await HiveSnapshotStorage.open(dir.path);

    expect(storage!.read('a'), isNull);
    await storage!.write('b', '2');
    expect(storage!.read('b'), '2');
  });
}
