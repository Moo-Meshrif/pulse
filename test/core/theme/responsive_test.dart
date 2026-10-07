import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/extensions/context_extensions.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/core/theme/app_scale.dart';

void _setView(WidgetTester t, Size size) {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

void main() {
  test('WindowSize.of follows the Material 600 / 840 breakpoints', () {
    expect(WindowSize.of(599), WindowSize.compact);
    expect(WindowSize.of(600), WindowSize.medium);
    expect(WindowSize.of(839), WindowSize.medium);
    expect(WindowSize.of(840), WindowSize.expanded);
  });

  testWidgets('context.windowSize reads the window', (t) async {
    WindowSize? seen;
    _setView(t, const Size(700, 1000));
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            seen = context.windowSize;
            return const SizedBox();
          },
        ),
      ),
    );
    expect(seen, WindowSize.medium);
  });

  group('AppScale', () {
    for (final (size, factor, systemCap) in [
      (const Size(320, 640), 0.85, 2.353),
      (const Size(390, 844), 1.0, 2.0),
      (const Size(844, 390), 1.0, 2.0), // landscape phone does not grow
      (const Size(1280, 800), 1.25, 1.6),
    ]) {
      testWidgets(
        '${size.width.toInt()}x${size.height.toInt()}: factor $factor, system text cap $systemCap',
        (t) async {
          _setView(t, size);
          expect(AppScale.factor, closeTo(factor, 0.001));
          expect(AppScale.maxSystemTextScale, closeTo(systemCap, 0.001));
          // The combined text scale never exceeds the target, except a small phone at the user's own 1x.
          expect(
            AppScale.factor * AppScale.maxSystemTextScale,
            lessThanOrEqualTo(2.0 + 0.001),
          );
        },
      );
    }
  });
}
