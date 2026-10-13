import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> openSheet(
    WidgetTester tester, {
    String? title = 'Create',
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () => AppBottomSheet.show<void>(
            context,
            title: title,
            child: const SizedBox(height: 120, child: Text('content')),
          ),
          child: const Text('open'),
        ),
      ),
      locale: locale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  final closeButton = find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == 'Close',
  );

  testWidgets('shows the title, the content and a labelled close button', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text('Create'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
    expect(closeButton, findsOneWidget);
  });

  testWidgets('the close button is a 44 x 44 tap target', (tester) async {
    await openSheet(tester);
    final size = tester.getSize(closeButton);
    expect(size.width, greaterThanOrEqualTo(44));
    expect(size.height, greaterThanOrEqualTo(44));
  });

  testWidgets('without a title there is no title row and no close button', (
    tester,
  ) async {
    await openSheet(tester, title: null);
    expect(find.text('content'), findsOneWidget);
    expect(closeButton, findsNothing);
  });

  testWidgets('the close button dismisses the sheet', (tester) async {
    await openSheet(tester);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetShell), findsNothing);
  });

  testWidgets('a tap on the scrim dismisses the sheet', (tester) async {
    await openSheet(tester);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetShell), findsNothing);
  });

  testWidgets('dragging the sheet down dismisses it', (tester) async {
    await openSheet(tester);
    await tester.drag(find.text('content'), const Offset(0, 600));
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetShell), findsNothing);
  });

  testWidgets('system back dismisses the sheet', (tester) async {
    await openSheet(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AppBottomSheetShell), findsNothing);
  });

  testWidgets('English: the close button sits at the right of the title', (
    tester,
  ) async {
    await openSheet(tester);
    expect(
      tester.getCenter(closeButton).dx,
      greaterThan(tester.getCenter(find.text('Create')).dx),
    );
  });

  testWidgets('Arabic: the close button sits at the left of the title', (
    tester,
  ) async {
    await openSheet(tester, title: 'إنشاء', locale: const Locale('ar'));
    final close = find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == 'إغلاق',
    );
    expect(
      tester.getCenter(close).dx,
      lessThan(tester.getCenter(find.text('إنشاء')).dx),
    );
  });

  testWidgets('on a wide window the sheet stays at the shared max width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openSheet(tester);
    final box = tester.getRect(find.byType(AppBottomSheetShell));
    expect(box.width, lessThanOrEqualTo(AppBreakpoints.maxContentWidth));
    expect(box.center.dx, closeTo(800, 1));
  });
}
