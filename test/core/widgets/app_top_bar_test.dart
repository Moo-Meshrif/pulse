import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  Future<void> pushPage(WidgetTester tester, Widget page) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => page)),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('the first page has no top bar', (tester) async {
    await tester.pumpApp(const AppPage(child: SizedBox.expand()));
    expect(find.byType(AppTopBar), findsNothing);
  });

  testWidgets('a pushed page gets the top bar on the body color, back pops', (
    tester,
  ) async {
    await pushPage(tester, const AppPage(child: Text('page')));
    expect(find.byType(AppTopBar), findsOneWidget);
    final bar = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(AppTopBar),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(bar.color, AppColors.light.background);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.text('page'), findsNothing);
  });

  testWidgets('showTopBar: false keeps a pushed page free of it', (
    tester,
  ) async {
    await pushPage(
      tester,
      const AppPage(showTopBar: false, child: SizedBox.expand()),
    );
    expect(find.byType(AppTopBar), findsNothing);
  });

  testWidgets('an explicit appBar shows its title', (tester) async {
    await pushPage(
      tester,
      const AppPage(
        appBar: AppTopBar(title: 'Title'),
        child: SizedBox(),
      ),
    );
    expect(find.text('Title'), findsOneWidget);
  });
}
