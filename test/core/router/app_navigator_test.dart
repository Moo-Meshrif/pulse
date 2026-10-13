import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/router/app_navigator.dart';

/// A Navigator inside a Navigator, like a tab of the main shell inside the app.
void main() {
  final rootKey = GlobalKey<NavigatorState>();
  final tabKey = GlobalKey<NavigatorState>();

  Future<void> pumpNested(
    WidgetTester tester,
    Widget Function(BuildContext) tabRoot,
  ) => tester.pumpWidget(
    MaterialApp(
      navigatorKey: rootKey,
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => settings.name == '/'
            ? Navigator(
                key: tabKey,
                onGenerateRoute: (s) => MaterialPageRoute<void>(
                  settings: s,
                  builder: (context) => s.name == '/'
                      ? tabRoot(context)
                      : Text('tab page ${s.name}'),
                ),
              )
            : Text('app page ${settings.name}'),
      ),
    ),
  );

  testWidgets('push opens inside the nearest (tab) Navigator', (tester) async {
    await pumpNested(
      tester,
      (context) => TextButton(
        onPressed: () => AppNavigator.push<void>(context, '/inside'),
        child: const Text('go'),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('tab page /inside'), findsOneWidget);
    expect(tabKey.currentState!.canPop(), isTrue);
    expect(rootKey.currentState!.canPop(), isFalse);
  });

  testWidgets(
    'push with rootNavigator opens on the root Navigator, over the tab',
    (tester) async {
      await pumpNested(
        tester,
        (context) => TextButton(
          onPressed: () =>
              AppNavigator.push<void>(context, '/over', rootNavigator: true),
          child: const Text('go'),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('app page /over'), findsOneWidget);
      expect(rootKey.currentState!.canPop(), isTrue);
      expect(tabKey.currentState!.canPop(), isFalse);
    },
  );
}
