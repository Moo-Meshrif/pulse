import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/story/domain/entity/story_viewer_args.dart';
import 'package:pulse/features/story/presentation/utils/story_page_route.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> open(
    WidgetTester tester, {
    Offset? origin,
    bool reduceMotion = false,
  }) async {
    setUpView(tester, size: const Size(400, 800));
    if (reduceMotion) {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              StoryPageRoute<void>(
                origin: origin,
                builder: (_) => const Text('viewer'),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
  }

  Finder viewer() => find.text('viewer', skipOffstage: false);

  Finder grow() => find.ancestor(
    of: viewer(),
    matching: find.byType(ScaleTransition, skipOffstage: false),
  );

  testWidgets('the story route is its own route: /story/:id grows from the '
      'tapped point', (tester) async {
    final route = AppRouter.onGenerateRoute(
      RouteSettings(
        name: AppRoutes.storyOf('a'),
        arguments: const StoryViewerArgs(origin: Offset(40, 120)),
      ),
    );
    expect(route, isA<StoryPageRoute<dynamic>>());
    expect((route as StoryPageRoute<dynamic>).origin, const Offset(40, 120));
  });

  testWidgets('it grows from the origin while fading in, over 280 ms', (
    tester,
  ) async {
    await open(tester, origin: const Offset(40, 120));
    final scale = tester.widget<ScaleTransition>(grow().first);
    expect(scale.scale.value, lessThan(0.5));
    expect(scale.alignment.x, lessThan(-0.5)); // near the left edge
    expect(scale.alignment.y, lessThan(-0.5)); // near the top

    await tester.pump(const Duration(milliseconds: 140));
    final mid = tester.widget<ScaleTransition>(grow().first);
    expect(mid.scale.value, inExclusiveRange(0.1, 1.0));

    await tester.pump(const Duration(milliseconds: 160));
    final done = tester.widget<ScaleTransition>(grow().first);
    expect(done.scale.value, 1.0);
    expect(viewer(), findsOneWidget);
  });

  testWidgets('without an origin it grows from the centre', (tester) async {
    await open(tester);
    final scale = tester.widget<ScaleTransition>(grow().first);
    expect(scale.alignment, Alignment.center);
  });

  testWidgets('closing shrinks back into the origin within 200 ms', (
    tester,
  ) async {
    await open(tester, origin: const Offset(40, 120));
    await tester.pump(const Duration(milliseconds: 300));
    Navigator.of(tester.element(viewer())).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = tester.widget<ScaleTransition>(grow().first);
    expect(mid.scale.value, lessThan(1.0));
    await tester.pump(const Duration(milliseconds: 150));
    expect(viewer(), findsNothing);
  });

  testWidgets('reduce motion: a plain fade, no grow', (tester) async {
    await open(tester, origin: const Offset(40, 120), reduceMotion: true);
    expect(grow(), findsNothing);
    expect(
      find.ancestor(
        of: viewer(),
        matching: find.byType(FadeTransition, skipOffstage: false),
      ),
      findsWidgets,
    );
    await tester.pump(const Duration(milliseconds: 160));
    expect(viewer(), findsOneWidget);
  });
}
