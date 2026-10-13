import 'dart:ui';

/// `#RRGGBB` (or `RRGGBB`) to an opaque color; null when it is not one.
Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  final digits = hex.startsWith('#') ? hex.substring(1) : hex;
  if (digits.length != 6) return null;
  final value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
