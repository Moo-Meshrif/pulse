import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _Mode { light, dark }

class _Item {
  const _Item(this.id);

  final int id;

  static _Item? fromJson(Map<String, dynamic> json) =>
      json['id'] is int ? _Item(json['id'] as int) : null;
  Map<String, dynamic> toJson() => {'id': id};
}

void main() {
  late SharedPrefsStorageService storage;

  Future<void> create([Map<String, Object> values = const {}]) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(values);
    storage = SharedPrefsStorageService(await SharedPreferences.getInstance());
  }

  setUp(create);
  tearDown(() => storage.dispose());

  group('primitives', () {
    test('a missing key reads as null', () {
      expect(storage.getValue<String>('k'), isNull);
      expect(storage.getValue<bool>('k'), isNull);
      expect(storage.getValue<int>('k'), isNull);
      expect(storage.getValue<double>('k'), isNull);
      expect(storage.getValue<List<String>>('k'), isNull);
    });

    test('every type is written and read back', () async {
      await storage.setValue('s', 'a');
      await storage.setValue('b', true);
      await storage.setValue('i', 3);
      await storage.setValue('d', 1.5);
      await storage.setValue('l', ['x', 'y']);

      expect(storage.getValue<String>('s'), 'a');
      expect(storage.getValue<bool>('b'), isTrue);
      expect(storage.getValue<int>('i'), 3);
      expect(storage.getValue<double>('d'), 1.5);
      expect(storage.getValue<List<String>>('l'), ['x', 'y']);
    });

    test('a value of another type reads as null instead of throwing', () async {
      await create({'k': 'text'});
      expect(storage.getValue<int>('k'), isNull);
    });

    test('the type comes from the type argument, so one key can be read as any supported type', () async {
      await storage.setValue('n', 7);
      expect(storage.getValue<int>('n'), 7);
      expect(storage.getValue<String>('n'), isNull);
    });

    test('an unsupported type is a programming error', () async {
      expect(() => storage.getValue<_Mode>('k'), throwsArgumentError);
      expect(() => storage.getValue('k'), throwsArgumentError);
      await expectLater(storage.setValue('k', _Mode.dark), throwsArgumentError);
      expect(storage.containsKey('k'), isFalse);
    });
  });

  group('DateTime', () {
    test('round-trips as UTC', () async {
      final value = DateTime.utc(2026, 10, 7, 12, 30);
      await storage.setValue('t', value.toLocal());
      expect(storage.getValue<DateTime>('t'), value);
      expect(storage.getValue<String>('t'), '2026-10-07T12:30:00.000Z');
    });

    test('a malformed value reads as null', () async {
      await create({'t': 'not a date'});
      expect(storage.getValue<DateTime>('t'), isNull);
    });
  });

  group('custom types with decode / encode', () {
    _Mode? decodeMode(Object? json) => _Mode.values.asNameMap()[json];
    _Item? decodeItem(Object? json) =>
        json is Map<String, dynamic> ? _Item.fromJson(json) : null;
    List<_Item> decodeItems(Object? json) => [
      for (final element in json as List) ?decodeItem(element),
    ];

    test('an enum is stored by name; an unknown name reads as null', () async {
      await storage.setValue('m', _Mode.dark, encode: (mode) => mode.name);
      expect(storage.getValue<_Mode>('m', decode: decodeMode), _Mode.dark);

      await storage.setValue('m', 'sepia');
      expect(storage.getValue<_Mode>('m', decode: decodeMode), isNull);
    });

    test('an object round-trips', () async {
      await storage.setValue(
        'o',
        const _Item(1),
        encode: (item) => item.toJson(),
      );
      expect(storage.getValue<_Item>('o', decode: decodeItem)?.id, 1);
    });

    test(
      'a list of objects round-trips and skips elements that do not convert',
      () async {
        await storage.setValue('ol', const [
          _Item(1),
          _Item(2),
        ], encode: (items) => [for (final i in items) i.toJson()]);
        expect(
          storage
              .getValue<List<_Item>>('ol', decode: decodeItems)
              ?.map((item) => item.id),
          [1, 2],
        );

        await create({'ol': '[{"id":1},{"id":"x"},3,{"id":2}]'});
        expect(
          storage
              .getValue<List<_Item>>('ol', decode: decodeItems)
              ?.map((item) => item.id),
          [1, 2],
        );
      },
    );

    test(
      'corrupt JSON, a missing key and a decode that throws all read as null',
      () async {
        await create({'o': '{broken', 'l': '{"id":1}'});
        expect(storage.getValue<_Item>('o', decode: decodeItem), isNull);
        expect(storage.getValue<_Item>('missing', decode: decodeItem), isNull);
        expect(storage.getValue<List<_Item>>('l', decode: decodeItems), isNull);
      },
    );
  });

  group('keys', () {
    test('containsKey, keys, remove and removeAll', () async {
      await storage.setValue('a', '1');
      await storage.setValue('b', '2');
      await storage.setValue('c', '3');

      expect(storage.containsKey('a'), isTrue);
      expect(storage.keys, {'a', 'b', 'c'});

      await storage.remove('a');
      expect(storage.containsKey('a'), isFalse);

      expect(await storage.removeAll(['b', 'c']), isTrue);
      expect(storage.keys, isEmpty);
    });

    test('clear deletes every key', () async {
      await storage.setValue('a', '1');
      await storage.clear();
      expect(storage.keys, isEmpty);
    });
  });

  group('watch', () {
    test('emits for its own key only, on write and on remove', () async {
      var emitted = 0;
      final subscription = storage.watch('a').listen((_) => emitted++);

      await storage.setValue('a', '1');
      await storage.setValue('other', '1');
      await storage.remove('a');
      await pumpEventQueue();

      expect(emitted, 2);
      await subscription.cancel();
    });

    test('clear notifies every watcher', () async {
      var emitted = 0;
      final subscription = storage.watch('a').listen((_) => emitted++);

      await storage.clear();
      await pumpEventQueue();

      expect(emitted, 1);
      await subscription.cancel();
    });

    test('writing after dispose still stores and does not throw', () async {
      await storage.dispose();
      expect(await storage.setValue('a', '1'), isTrue);
      expect(storage.getValue<String>('a'), '1');
    });
  });
}
