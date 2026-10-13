import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/hex_color.dart';

void main() {
  test('parseHexColor reads #RRGGBB and RRGGBB, else null', () {
    expect(parseHexColor('#FFFFFF'), const Color(0xFFFFFFFF));
    expect(parseHexColor('2e6b63'), const Color(0xFF2E6B63));
    expect(parseHexColor('#FFF'), isNull);
    expect(parseHexColor('#GGGGGG'), isNull);
    expect(parseHexColor(null), isNull);
  });
}
