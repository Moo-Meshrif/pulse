import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/features/story/data/enums/story_overlay_type.dart';
import 'package:pulse/features/story/data/model/story_overlay_model.dart';
import 'package:pulse/features/story/presentation/widgets/story_overlays_layer.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('a sticker is centred at its fractions of the frame', (
    tester,
  ) async {
    setUpView(tester, size: const Size(400, 800));
    await tester.pumpApp(
      const Material(
        child: StoryOverlaysLayer(
          overlays: [
            StoryOverlayModel(
              type: StoryOverlayType.text,
              text: 'Centre',
              x: 0.25,
              y: 0.75,
              scale: 1,
              rotation: 0,
              color: '#FFFFFF',
            ),
          ],
        ),
      ),
    );
    final centre = tester.getCenter(find.text('Centre'));
    expect(centre.dx, closeTo(100, 1));
    expect(centre.dy, closeTo(600, 1));
  });

  testWidgets('x and y outside the frame are held inside it', (tester) async {
    setUpView(tester, size: const Size(400, 800));
    await tester.pumpApp(
      const Material(
        child: StoryOverlaysLayer(
          overlays: [
            StoryOverlayModel(
              type: StoryOverlayType.text,
              text: 'Edge',
              x: 3,
              y: -2,
            ),
          ],
        ),
      ),
    );
    final centre = tester.getCenter(find.text('Edge'));
    expect(centre.dx, closeTo(400, 1));
    expect(centre.dy, closeTo(0, 1));
  });
}
