import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/json_mapper.dart';

void main() {
  test('string', () {
    expect(JsonMapper.string('a'), 'a');
    expect(JsonMapper.string(1), isNull);
    expect(JsonMapper.string(null), isNull);
  });

  test('integer accepts whole numbers only', () {
    expect(JsonMapper.integer(3), 3);
    expect(JsonMapper.integer(3.0), 3);
    expect(JsonMapper.integer(3.5), isNull);
    expect(JsonMapper.integer('4'), 4);
    expect(JsonMapper.integer('x'), isNull);
    expect(JsonMapper.integer(double.nan), isNull);
  });

  test('boolean', () {
    expect(JsonMapper.boolean(true), isTrue);
    expect(JsonMapper.boolean('true'), isNull);
  });

  test('date parses ISO strings to UTC', () {
    expect(JsonMapper.date('2000-05-17'), DateTime.utc(2000, 5, 17));
    expect(
      JsonMapper.date('2000-05-17T10:00:00+02:00'),
      DateTime.utc(2000, 5, 17, 8),
    );
    expect(JsonMapper.date('nope'), isNull);
    expect(JsonMapper.date('2000-02-31'), isNull); // not a day that exists
    expect(JsonMapper.date(5), isNull);
  });

  test(
    'a date without a time is that day in UTC, whatever the machine zone',
    () {
      final date = JsonMapper.date('1999-02-03')!;
      expect(date.isUtc, isTrue);
      expect((date.year, date.month, date.day), (1999, 2, 3));
      expect((date.hour, date.minute), (0, 0));
    },
  );

  test('list drops items that do not convert and is unmodifiable', () {
    final list = JsonMapper.list<int>([1, 'x', 2], JsonMapper.integer);
    expect(list, [1, 2]);
    expect(() => list!.add(3), throwsUnsupportedError);
    expect(JsonMapper.list<int>('not a list', JsonMapper.integer), isNull);
  });
}
