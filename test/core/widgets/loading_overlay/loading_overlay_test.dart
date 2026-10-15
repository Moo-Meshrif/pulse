import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/theme/colors/app_colors.dart';
import 'package:pulse/core/widgets/widgets.dart';

import '../../../helpers/pump_app.dart';

void main() {
  const colors = AppColors.light;

  /// A button that runs [task] under the overlay.
  Widget host(
    Future<void> Function() task, {
    String? label,
    ValueNotifier<double>? progress,
    LoadingTone tone = LoadingTone.light,
  }) => Scaffold(
    body: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () => runWithLoadingOverlay(
            context,
            task,
            label: label,
            progress: progress,
            tone: tone,
          ),
          child: const Text('go'),
        ),
      ),
    ),
  );

  Future<void> tick(WidgetTester tester, int ms) =>
      tester.pump(Duration(milliseconds: ms));

  group('runWithLoadingOverlay', () {
    testView('it shows at once and comes down the moment the task ends', (
      tester,
    ) async {
      final running = Completer<void>();
      await tester.pumpApp(host(() => running.future));
      expect(find.byType(LoadingOverlay), findsNothing);

      await tester.tap(find.text('go'));
      await tick(tester, 16);
      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(find.byType(PulseLineLoader), findsOneWidget);

      // However long the wait, it stays.
      await tick(tester, 5000);
      expect(find.byType(LoadingOverlay), findsOneWidget);

      running.complete();
      // It fades out (160 ms) instead of vanishing, then it is gone.
      await tick(tester, 16);
      expect(find.byType(LoadingOverlay), findsOneWidget);
      await tick(tester, 250);
      expect(find.byType(LoadingOverlay), findsNothing);
    });

    testView('the line fades in, and fades out as it lifts', (tester) async {
      final running = Completer<void>();
      await tester.pumpApp(host(() => running.future));
      await tester.tap(find.text('go'));
      await tick(tester, 16);

      double opacity() => tester
          .widget<Opacity>(
            find.descendant(
              of: find.byType(LoadingOverlay),
              matching: find.byType(Opacity),
            ),
          )
          .opacity;

      expect(opacity(), lessThan(0.5));
      await tick(tester, 300);
      expect(opacity(), 1);

      running.complete();
      await tick(tester, 16);
      await tick(tester, 60);
      expect(opacity(), allOf(greaterThan(0), lessThan(1)));
      await tick(tester, 250);
    });

    testView('the blur is not inside an opacity, or it would blur nothing', (
      tester,
    ) async {
      final running = Completer<void>();
      await tester.pumpApp(host(() => running.future));
      await tester.tap(find.text('go'));
      await tick(tester, 16);
      await tick(tester, 300);

      expect(find.byType(BackdropFilter), findsOneWidget);
      for (final faded in [Opacity, FadeTransition]) {
        expect(
          find.ancestor(
            of: find.byType(BackdropFilter),
            matching: find.byType(faded),
          ),
          findsNothing,
          reason: '\$faded around the BackdropFilter',
        );
      }

      running.complete();
      await tick(tester, 300);
    });

    testView('a task that fails takes it down too, and the error passes on', (
      tester,
    ) async {
      await tester.pumpApp(host(() async {}));
      final context = tester.element(find.text('go'));

      final result = runWithLoadingOverlay<void>(
        context,
        () async => throw StateError('no answer'),
      );
      await expectLater(result, throwsStateError);
      await tick(tester, 300);
      expect(find.byType(LoadingOverlay), findsNothing);
    });

    testView('it blocks taps on the screen under it', (tester) async {
      final running = Completer<void>();
      var taps = 0;
      await tester.pumpApp(
        Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                TextButton(
                  onPressed: () =>
                      runWithLoadingOverlay(context, () => running.future),
                  child: const Text('go'),
                ),
                TextButton(onPressed: () => taps++, child: const Text('under')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tick(tester, 16);
      await tester.tap(find.text('under'), warnIfMissed: false);
      expect(taps, 0);

      running.complete();
      await tick(tester, 300);
      await tester.tap(find.text('under'));
      expect(taps, 1);
    });

    testView('the task result passes through, and so does an error', (
      tester,
    ) async {
      await tester.pumpApp(host(() async {}));
      final context = tester.element(find.text('go'));
      expect(await runWithLoadingOverlay(context, () async => 7), 7);
      await expectLater(
        runWithLoadingOverlay<void>(context, () async => throw StateError('x')),
        throwsStateError,
      );
      await tick(tester, 300); // both overlays finish lifting
    });
  });

  group('LoadingOverlay', () {
    Future<void> show(
      WidgetTester tester, {
      String? label,
      ValueNotifier<double>? progress,
      LoadingTone tone = LoadingTone.light,
      Locale locale = const Locale('en'),
    }) => tester.pumpApp(
      Scaffold(
        body: LoadingOverlay(label: label, progress: progress, tone: tone),
      ),
      locale: locale,
      settle: false,
    );

    testView('announces Loading, or its label, as a live region', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await show(tester);
      expect(find.bySemanticsLabel(l10nEn.loading), findsOneWidget);

      await show(tester, label: 'Saving...');
      expect(find.bySemanticsLabel('Saving...'), findsWidgets);
      handle.dispose();
    });

    testView('a label shows under the line, in textPrimary on light', (
      tester,
    ) async {
      await show(tester, label: 'Saving...');
      await tick(tester, 300);
      final text = tester.widget<Text>(find.text('Saving...'));
      expect(text.style!.color, colors.textPrimary);
      expect(text.style!.fontSize, 17);
      expect(text.style!.fontWeight, FontWeight.w600);
    });

    testView('progress shows a track and the percentage', (tester) async {
      final progress = ValueNotifier<double>(0.64);
      await show(tester, label: 'Uploading photo...', progress: progress);
      await tick(tester, 300);
      expect(find.text('64%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      progress.value = 0.9;
      await tick(tester, 50);
      expect(find.text('90%'), findsOneWidget);
    });

    testView('the dark tone writes in white', (tester) async {
      await show(tester, label: 'Posting short...', tone: LoadingTone.dark);
      await tick(tester, 300);
      final text = tester.widget<Text>(find.text('Posting short...'));
      expect(text.style!.color, colors.surface);
    });

    testView('it is in Arabic too, and the line does not mirror', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await show(tester, locale: const Locale('ar'));
      expect(find.bySemanticsLabel(l10nAr.loading), findsOneWidget);
      final line = tester.getRect(find.byType(PulseLineLoader));
      final screen = tester.getRect(find.byType(Scaffold));
      expect(line.center.dx, closeTo(screen.center.dx, 0.5));
      handle.dispose();
    });
  });

  group('PulseLineLoader', () {
    testView('plays the Lottie file in a 184 : 88 frame and is decorative', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpApp(
        const Scaffold(
          body: Center(child: PulseLineLoader(color: Colors.black, width: 168)),
        ),
        settle: false,
      );
      await tick(tester, 100);

      expect(find.byType(LottieBuilder), findsOneWidget);
      final size = tester.getSize(find.byType(PulseLineLoader));
      expect(size.width, 168);
      expect(size.height, closeTo(168 * 88 / 184, 0.01));
      expect(find.bySemanticsLabel(RegExp('.+')), findsNothing);
      handle.dispose();
    });

    testView('a white line uses the dark file, any other the light one', (
      tester,
    ) async {
      Future<String> fileFor(Color color) async {
        await tester.pumpApp(
          Scaffold(
            body: Center(child: PulseLineLoader(color: color)),
          ),
          settle: false,
        );
        await tick(tester, 100);
        final provider =
            tester.widget<LottieBuilder>(find.byType(LottieBuilder)).lottie
                as AssetLottie;
        return provider.assetName;
      }

      expect(await fileFor(Colors.white), AppAssets.loaderDark);
      expect(await fileFor(const Color(0xFF2E6B63)), AppAssets.loaderLight);
    });

    testView('with reduced motion it is the still line, no animation', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpApp(
        const Scaffold(
          body: Center(child: PulseLineLoader(color: Colors.black)),
        ),
        settle: false,
      );
      await tick(tester, 800);

      expect(find.byType(LottieBuilder), findsNothing);
      expect(find.byType(AppSvgIcon), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
