import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  // The icon floats forever, so these pump with settle: false.
  Future<void> show(WidgetTester tester, Widget page) async {
    await tester.pumpApp(Scaffold(body: page), settle: false);
  }

  testWidgets('empty: shows the copy, runs the primary action', (tester) async {
    var taps = 0;
    await show(
      tester,
      AppEmpty(
        icon: AppAssets.inbox,
        title: 'Nothing here yet',
        message: 'Save posts you love.',
        primaryLabel: 'Explore posts',
        onPrimary: () => taps++,
      ),
    );
    expect(find.text('Nothing here yet'), findsOneWidget);
    expect(find.text('Save posts you love.'), findsOneWidget);
    await tester.tap(find.text('Explore posts'));
    expect(taps, 1);
  });

  testWidgets('failed: retry and Go to Home, no link without onGoHome', (
    tester,
  ) async {
    var retries = 0;
    var homes = 0;
    await show(
      tester,
      AppEmpty.failed(onRetry: () => retries++, onGoHome: () => homes++),
    );
    await tester.tap(find.text(l10nEn.tryAgain));
    await tester.tap(find.text(l10nEn.goToHome));
    expect((retries, homes), (1, 1));

    await show(tester, AppEmpty.failed(onRetry: () {}));
    expect(find.text(l10nEn.goToHome), findsNothing);
  });

  testWidgets('notFound: the primary action goes home', (tester) async {
    var homes = 0;
    await show(tester, AppEmpty.notFound(onGoHome: () => homes++));
    expect(find.text(l10nEn.notFoundPageTitle), findsOneWidget);
    await tester.tap(find.text(l10nEn.goToHome));
    expect(homes, 1);
  });

  testWidgets('offline: amber button, loading hides the label', (tester) async {
    await show(tester, AppEmpty.offline(onRetry: () {}));
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.style!.backgroundColor!.resolve({}),
      AppColors.light.warningSoft,
    );

    await show(tester, AppEmpty.offline(onRetry: () {}, loading: true));
    expect(find.byType(PulseLineLoader), findsOneWidget);
    expect(find.text(l10nEn.tryAgain), findsNothing);
  });
}
