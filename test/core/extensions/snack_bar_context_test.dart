import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/extensions/snack_bar_context.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    void Function(BuildContext context) action,
  ) async {
    await tester.pumpApp(
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => action(context),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a plain notice has no action', (tester) async {
    await show(tester, (c) => c.showSnackBar('Saved'));
    expect(find.text('Saved'), findsOneWidget);
    expect(find.byType(SnackBarAction), findsNothing);
  });

  testWidgets('an action shows its label and runs its callback', (
    tester,
  ) async {
    var undone = 0;
    await show(
      tester,
      (c) => c.showSnackBar(
        'Muted',
        actionLabel: 'Undo',
        onAction: () => undone++,
      ),
    );
    expect(find.text('Muted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    expect(undone, 1);
  });

  testWidgets('a label without a callback shows no action', (tester) async {
    await show(tester, (c) => c.showSnackBar('Muted', actionLabel: 'Undo'));
    expect(find.byType(SnackBarAction), findsNothing);
  });

  testWidgets('a null message shows nothing', (tester) async {
    await show(tester, (c) => c.showSnackBar(null));
    expect(find.byType(SnackBar), findsNothing);
  });
}
