import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pulse/core/utils/post_time.dart';

import '../../helpers/pump_app.dart';

void main() {
  final now = DateTime(2026, 10, 14, 12);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('ar');
  });

  String en(Duration ago) => postTime(l10nEn, now.subtract(ago), now);

  test('under a minute is now, a future time too', () {
    expect(en(const Duration(seconds: 20)), 'now');
    expect(postTime(l10nEn, now.add(const Duration(minutes: 5)), now), 'now');
  });

  test('minutes, hours, days, weeks', () {
    expect(en(const Duration(minutes: 5)), '5m');
    expect(en(const Duration(minutes: 59)), '59m');
    expect(en(const Duration(hours: 2)), '2h');
    expect(en(const Duration(hours: 23)), '23h');
    expect(en(const Duration(days: 1)), '1d');
    expect(en(const Duration(days: 6)), '6d');
    expect(en(const Duration(days: 7)), '1w');
    expect(en(const Duration(days: 21)), '3w');
  });

  test('four weeks or more is the date', () {
    expect(postTime(l10nEn, DateTime(2026, 3, 12), now), '12 Mar');
  });

  test('Arabic uses the Arabic letters and month', () {
    expect(
      postTime(l10nAr, now.subtract(const Duration(minutes: 5)), now),
      l10nAr.postTimeMinutes(5),
    );
    final date = postTime(l10nAr, DateTime(2026, 3, 12), now);
    expect(date, contains('12'));
    expect(date, isNot(contains('Mar')));
  });
}
