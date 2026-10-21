import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/widgets/widgets.dart';

void main() {
  void goToBackground(WidgetTester tester) => tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);

  void comeBack(WidgetTester tester) => tester.binding
    ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
    ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);

  testWidgets('calls onHide each time the app goes to the background', (
    tester,
  ) async {
    var hidden = 0;
    await tester.pumpWidget(
      OnAppVisibility(onHide: () => hidden++, child: const SizedBox()),
    );

    goToBackground(tester);
    expect(hidden, 1);
    comeBack(tester);
    goToBackground(tester);
    expect(hidden, 2);
    comeBack(tester);
  });

  testWidgets('uses the latest callback after a rebuild', (tester) async {
    final calls = <String>[];
    await tester.pumpWidget(
      OnAppVisibility(
        onHide: () => calls.add('first'),
        child: const SizedBox(),
      ),
    );
    await tester.pumpWidget(
      OnAppVisibility(
        onHide: () => calls.add('second'),
        child: const SizedBox(),
      ),
    );

    goToBackground(tester);
    expect(calls, ['second']);
    comeBack(tester);
  });

  testWidgets('stops listening once it is gone', (tester) async {
    var hidden = 0;
    await tester.pumpWidget(
      OnAppVisibility(onHide: () => hidden++, child: const SizedBox()),
    );
    await tester.pumpWidget(const SizedBox());

    goToBackground(tester);
    expect(hidden, 0);
    comeBack(tester);
  });

  testWidgets('calls onShow when the app comes back, not onHide', (
    tester,
  ) async {
    var shown = 0;
    var hidden = 0;
    await tester.pumpWidget(
      OnAppVisibility(
        onShow: () => shown++,
        onHide: () => hidden++,
        child: const SizedBox(),
      ),
    );

    goToBackground(tester);
    expect((shown, hidden), (0, 1));
    comeBack(tester);
    expect((shown, hidden), (1, 1));
  });
}
