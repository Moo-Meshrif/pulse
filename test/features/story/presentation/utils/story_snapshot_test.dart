import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/story/presentation/utils/story_snapshot.dart';

void main() {
  testWidgets(
    'the overlay picture has the video shape and a clear background',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      final render = renderStoryOverlay(
      context,
      overlays: const [],
      width: 800,
      height: 1600,
    );
    await tester.pump();
    final bytes = (await tester.runAsync(() => render))!;
    final image = await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
        return (await codec.getNextFrame()).image;
      });
      expect(image!.height / image.width, closeTo(2, 0.01));
      final raw = (await tester.runAsync(
        () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      expect(raw.getUint8(3), 0); // the first pixel is fully transparent
    },
  );
}
