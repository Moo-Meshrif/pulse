import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/format_countdown.dart';

void main() {
  test('formats m:ss', () {
    expect(formatCountdown(const Duration(seconds: 30)), '0:30');
    expect(formatCountdown(const Duration(seconds: 5)), '0:05');
    expect(formatCountdown(const Duration(minutes: 14, seconds: 59)), '14:59');
  });

  test('rounds a part of a second up and never goes below zero', () {
    expect(formatCountdown(const Duration(milliseconds: 400)), '0:01');
    expect(formatCountdown(Duration.zero), '0:00');
    expect(formatCountdown(const Duration(seconds: -3)), '0:00');
  });
}
