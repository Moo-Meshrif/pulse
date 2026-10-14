/// A count for a button: 1.2K, 7.5K, 2.1M. One decimal under 10 of a unit, none above; a trailing ".0" is
/// dropped; 0 is an empty string (the button shows no number). It never rounds up: 999999 is 999K.
String compactCount(int count) {
  if (count <= 0) return '';
  if (count < 1000) return '$count';
  if (count < 1000000) return '${_scaled(count, 1000)}K';
  if (count < 1000000000) return '${_scaled(count, 1000000)}M';
  return '${_scaled(count, 1000000000)}B';
}

String _scaled(int count, int unit) {
  final tenths = count * 10 ~/ unit;
  if (tenths >= 100) return '${tenths ~/ 10}';
  final whole = tenths ~/ 10;
  final fraction = tenths % 10;
  return fraction == 0 ? '$whole' : '$whole.$fraction';
}
