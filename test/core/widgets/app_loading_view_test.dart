import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  Widget screen([Widget view = const AppLoadingView()]) => Scaffold(body: view);

  PulseLineLoader line(WidgetTester tester) =>
      tester.widget<PulseLineLoader>(find.byType(PulseLineLoader));

  testView('first load: a primary line, 100 wide, centered', (tester) async {
    await tester.pumpApp(screen(), settle: false);

    expect(line(tester).color, colors.primary);
    expect(tester.getSize(find.byType(PulseLineLoader)).width, 100);
    final center = tester.getCenter(find.byType(PulseLineLoader));
    final body = tester.getCenter(find.byType(Scaffold));
    expect(center.dx, closeTo(body.dx, 0.5));
    expect(center.dy, closeTo(body.dy, 0.5));
  });

  testView('first load takes an optional label under the line', (tester) async {
    await tester.pumpApp(
      screen(const AppLoadingView(label: 'Loading your feed...')),
      settle: false,
    );

    final label = find.text('Loading your feed...');
    expect(label, findsOneWidget);
    expect(
      tester.getTopLeft(label).dy,
      greaterThan(tester.getBottomLeft(find.byType(PulseLineLoader)).dy),
    );
  });

  testView('it is announced as Loading, in English and Arabic', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpApp(screen(), settle: false);
    expect(find.bySemanticsLabel(l10nEn.loading), findsOneWidget);

    await tester.pumpApp(screen(), locale: const Locale('ar'), settle: false);
    expect(find.bySemanticsLabel(l10nAr.loading), findsOneWidget);
    handle.dispose();
  });

  testView('it fills a small window without overflow', (tester) async {
    setUpView(tester, size: const Size(320, 480));
    await tester.pumpApp(screen(), settle: false);
    expect(tester.takeException(), isNull);
  });

  testView('inline: refresh is a 64 band with a 56 line', (tester) async {
    await tester.pumpApp(
      const Center(child: AppInlineLoading.refresh()),
      settle: false,
    );
    expect(tester.getSize(find.byType(AppInlineLoading)).height, 64);
    expect(tester.getSize(find.byType(PulseLineLoader)).width, 56);
  });

  testView('inline: load more is a 72 band with a 44 line', (tester) async {
    await tester.pumpApp(
      const Center(child: AppInlineLoading.loadMore()),
      settle: false,
    );
    expect(tester.getSize(find.byType(AppInlineLoading)).height, 72);
    expect(tester.getSize(find.byType(PulseLineLoader)).width, 44);
  });

  testView('PrimaryButton loading shows the white heartbeat line', (
    tester,
  ) async {
    await tester.pumpApp(
      Center(
        child: PrimaryButton(
          label: 'Continue',
          onPressed: () {},
          loading: true,
        ),
      ),
      settle: false,
    );

    expect(line(tester).color, colors.textOnPrimary);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testView('an outline PillButton in loading shows the primary line', (
    tester,
  ) async {
    await tester.pumpApp(
      Center(
        child: PillButton.outline(
          label: 'Cancel',
          onPressed: () {},
          loading: true,
        ),
      ),
      settle: false,
    );

    expect(line(tester).color, colors.primary);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
}
