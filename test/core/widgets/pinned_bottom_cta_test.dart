import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget screen({bool divider = false}) => Scaffold(
    body: SafeArea(
      child: PinnedBottomCta(
        showTopDivider: divider,
        body: ListView(
          children: [
            for (var i = 0; i < 30; i++)
              SizedBox(height: 60, child: Text('row $i')),
          ],
        ),
        cta: const SizedBox(
          height: 56,
          width: double.infinity,
          child: Text('Continue'),
        ),
      ),
    ),
  );

  testView(
    'the call to action is pinned 24 above the bottom with 24 side padding',
    (tester) async {
      await tester.pumpApp(screen());
      final cta = tester.getRect(find.text('Continue'));
      expect(cta.left, 24);
      expect(390 - cta.right, closeTo(24, 0.5));
      expect(844 - 34 - cta.bottom, closeTo(24, 0.5)); // 34 = the bottom inset
    },
  );

  testView('the body scrolls above it and does not overlap', (tester) async {
    await tester.pumpApp(screen());
    final list = tester.getRect(find.byType(ListView));
    final cta = tester.getRect(find.text('Continue'));
    expect(list.bottom, lessThanOrEqualTo(cta.top));
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();
    expect(find.text('row 0'), findsNothing); // scrolled out of the body
  });

  testView(
    'with the keyboard open the call to action rises and the body shrinks',
    (tester) async {
      await tester.pumpApp(screen());
      final before = tester.getRect(find.text('Continue')).top;
      final listBefore = tester.getRect(find.byType(ListView)).height;
      // With the keyboard open the system reports no bottom safe-area padding.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding(top: 47);
      await tester.pump();
      final after = tester.getRect(find.text('Continue')).top;
      expect(after, lessThan(before));
      expect(before - after, closeTo(300 - 34, 2));
      expect(
        tester.getRect(find.byType(ListView)).height,
        lessThan(listBefore),
      );
    },
  );

  testView('the bar variant has a top hairline and a white fill', (
    tester,
  ) async {
    await tester.pumpApp(screen(divider: true));
    final bar = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('Continue'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = bar.decoration as BoxDecoration;
    expect(decoration.color, AppColors.light.surface);
    expect((decoration.border! as Border).top.color, AppColors.light.divider);
    expect((decoration.border! as Border).top.width, 1);
  });

  testView('the plain variant has no bar', (tester) async {
    await tester.pumpApp(screen());
    final bar = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('Continue'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((bar.decoration as BoxDecoration).border, isNull);
    expect((bar.decoration as BoxDecoration).color, isNull);
  });
}
