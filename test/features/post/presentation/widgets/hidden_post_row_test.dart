import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_dimens.dart';
import 'package:pulse/features/post/presentation/widgets/hidden_post_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late int undone;

  Future<void> show(WidgetTester tester, {double textScale = 1}) async {
    undone = 0;
    setUpView(tester, textScale: textScale);
    await tester.pumpApp(
      Scaffold(body: HiddenPostRow(onUndo: () => undone++)),
      locale: const Locale('en'),
    );
  }

  testWidgets('shows the hint and Undo', (tester) async {
    await show(tester);
    expect(find.text(l10nEn.postHidden), findsOneWidget);
    expect(find.text(l10nEn.postHiddenHint), findsOneWidget);
    expect(find.text(l10nEn.undo), findsOneWidget);
  });

  testWidgets('Undo inside the window calls back', (tester) async {
    await show(tester);
    await tester.pump(PostMotion.undoWindow - const Duration(seconds: 1));
    await tester.tap(find.text(l10nEn.undo));
    expect(undone, 1);
  });

  testWidgets('Undo goes away when the window ends, the row stays', (
    tester,
  ) async {
    await show(tester);
    await tester.pump(PostMotion.undoWindow + const Duration(milliseconds: 1));
    expect(find.text(l10nEn.undo), findsNothing);
    expect(find.text(l10nEn.postHidden), findsOneWidget);
  });

  testWidgets('leaving before the window ends leaves no timer behind', (
    tester,
  ) async {
    await show(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(PostMotion.undoWindow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1.5x text does not overflow', (tester) async {
    await show(tester, textScale: 1.5);
    expect(tester.takeException(), isNull);
  });
}
