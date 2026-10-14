import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/compact_count.dart';

void main() {
  test('zero and negative show no number', () {
    expect(compactCount(0), '');
    expect(compactCount(-3), '');
  });

  test('under a thousand is the plain number', () {
    expect(compactCount(1), '1');
    expect(compactCount(425), '425');
    expect(compactCount(999), '999');
  });

  test('thousands: one decimal under 10K, none above, ".0" dropped', () {
    expect(compactCount(1000), '1K');
    expect(compactCount(1200), '1.2K');
    expect(compactCount(7500), '7.5K');
    expect(compactCount(9999), '9.9K');
    expect(compactCount(10000), '10K');
    expect(compactCount(125000), '125K');
  });

  test('it never rounds up into the next unit', () {
    expect(compactCount(999999), '999K');
  });

  test('millions and billions', () {
    expect(compactCount(1000000), '1M');
    expect(compactCount(2100000), '2.1M');
    expect(compactCount(48000000), '48M');
    expect(compactCount(3200000000), '3.2B');
  });
}
