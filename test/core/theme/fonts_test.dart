import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Sora, Noto Sans and Noto Sans Arabic are bundled with the weights AppTextStyles uses', () async {
    final manifest = jsonDecode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List<dynamic>;
    final weights = {
      for (final entry in manifest.cast<Map<String, dynamic>>())
        entry['family'] as String: {
          for (final font
              in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>())
            (font['weight'] as int?) ?? 400,
        },
    };

    expect(weights['Sora'], {600, 700});
    expect(weights['NotoSans'], {400, 500, 600, 700});
    expect(weights['NotoSansArabic'], {400, 500, 600, 700});
  });
}
