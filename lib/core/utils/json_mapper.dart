/// Raw JSON value -> typed field, or `null`. Pure Dart. Every method accepts any value and returns
/// `null` when it is missing or not convertible; none throws and none supplies a default.
abstract final class JsonMapper {
  static String? string(Object? value) => value is String ? value : null;

  /// A whole number: `10` or `10.0` -> `10`. `10.5` -> `null`, never silently truncated.
  static int? integer(Object? value) => switch (value) {
    int() => value,
    double() when value.isFinite && value == value.truncateToDouble() =>
      value.toInt(),
    String() => int.tryParse(value),
    _ => null,
  };

  static bool? boolean(Object? value) => value is bool ? value : null;

  static final _dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// ISO-8601 string (or a `DateTime`) -> UTC. A date without a time (`1999-02-03`) is that day at 00:00
  /// UTC, not local midnight, which would shift it to the previous day east of Greenwich.
  static DateTime? date(Object? value) => switch (value) {
    DateTime() => value.toUtc(),
    String() => _parseDate(value),
    _ => null,
  };

  static DateTime? _parseDate(String value) {
    final dateOnly = _dateOnly.firstMatch(value);
    if (dateOnly != null) {
      final parsed = DateTime.utc(
        int.parse(dateOnly[1]!),
        int.parse(dateOnly[2]!),
        int.parse(dateOnly[3]!),
      );
      // DateTime.utc rolls 2000-02-31 over to March: reject that.
      return parsed.month == int.parse(dateOnly[2]!) ? parsed : null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  /// An unmodifiable list whose items are converted by [parse]; items that don't convert are dropped.
  static List<T>? list<T>(Object? value, T? Function(Object? item) parse) =>
      value is List ? List.unmodifiable(value.map(parse).whereType<T>()) : null;
}
