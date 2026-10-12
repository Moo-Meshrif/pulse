import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/splash/presentation/cubit/splash_state.dart';
import 'package:pulse/features/splash/presentation/utils/enums/splash_problem.dart';
import 'package:pulse/features/splash/presentation/view/splash_view.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Future<void> pumpView(
    WidgetTester tester,
    SplashState state, {
    Locale locale = const Locale('en'),
    VoidCallback? onRetry,
    bool isRetrying = false,
  }) => tester.pumpApp(
    SplashView(state: state, onRetry: onRetry ?? () {}, isRetrying: isRetrying),
    locale: locale,
    settle: false,
  );

  group('loading', () {
    testView(
      'the 72 tile and its wordmark are centered, the heartbeat line is under them',
      (tester) async {
        await pumpView(tester, const SplashState.deciding());

        expect(tester.getSize(find.byType(LogoTile)), const Size(72, 72));
        final tile = tester.getCenter(find.byType(LogoTile));
        final wordmark = tester.getCenter(find.text('pulse'));
        expect(tile.dx, 195);
        expect(wordmark.dx, 195);
        expect(wordmark.dy, greaterThan(tile.dy));

        final line = tester.getCenter(find.byType(PulseLineLoader));
        expect(line.dx, 195);
        expect(line.dy, greaterThan(wordmark.dy));
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(PrimaryButton), findsNothing);
      },
    );

    testView('the tile and wordmark stay in the middle of the screen', (
      tester,
    ) async {
      await pumpView(tester, const SplashState.deciding());
      final tile = tester.getRect(find.byType(LogoTile));
      final wordmark = tester.getRect(find.text('pulse'));
      final group = tile.expandToInclude(wordmark);
      // The middle of the screen between the notch (47) and the home indicator (34) insets.
      expect(group.center.dy, closeTo((47 + 844 - 34) / 2, 1));
    });

    testView('it is announced as Loading', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpView(tester, const SplashState.deciding());
      expect(find.bySemanticsLabel(l10nEn.loading), findsOneWidget);
      handle.dispose();
    });
  });

  for (final problem in SplashProblem.values) {
    group(problem.name, () {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        final l10n = locale.languageCode == 'en' ? l10nEn : l10nAr;
        String title() => switch (problem) {
          SplashProblem.offline => l10n.offlineTitle,
          SplashProblem.noInternet => l10n.noInternetTitle,
          SplashProblem.weakConnection => l10n.weakConnectionTitle,
          SplashProblem.cantReach => l10n.cantReachTitle,
        };
        String body() => switch (problem) {
          SplashProblem.offline => l10n.offlineBody,
          SplashProblem.noInternet => l10n.noInternetBody,
          SplashProblem.weakConnection => l10n.weakConnectionBody,
          SplashProblem.cantReach => l10n.cantReachBody,
        };

        testView(
          '${locale.languageCode}: header, circle, copy and a pinned button',
          (tester) async {
            var retried = 0;
            await pumpView(
              tester,
              SplashState.failed(problem),
              locale: locale,
              onRetry: () => retried++,
            );

            expect(find.text(title()), findsOneWidget);
            expect(find.text(body()), findsOneWidget);
            expect(find.text(l10n.tryAgain), findsOneWidget);
            expect(find.byType(LogoLockup), findsOneWidget);
            expect(find.byType(CircularProgressIndicator), findsNothing);
            final circle = tester.getSize(
              find
                  .ancestor(
                    of: find.byType(AppSvgIcon),
                    matching: find.byType(SizedBox),
                  )
                  .first,
            );
            expect(circle, const Size(96, 96));
            // Centered layout: the copy sits on the middle line in both directions.
            expect(tester.getCenter(find.text(title())).dx, 195);
            // The button is pinned near the bottom edge, 24 side padding.
            final button = tester.getRect(find.byType(PrimaryButton));
            expect(button.left, 24);
            expect(button.right, 366);
            expect(button.bottom, lessThan(844));
            expect(button.bottom, greaterThan(740));
            expect(
              tester.getTopLeft(find.byType(LogoLockup)).dy,
              lessThan(tester.getTopLeft(find.text(title())).dy),
            );

            await tester.tap(find.text(l10n.tryAgain));
            expect(retried, 1);
          },
        );
      }

      testView('the title is a header and the logo mark is read as one label', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpView(tester, SplashState.failed(problem));
        final title = switch (problem) {
          SplashProblem.offline => l10nEn.offlineTitle,
          SplashProblem.noInternet => l10nEn.noInternetTitle,
          SplashProblem.weakConnection => l10nEn.weakConnectionTitle,
          SplashProblem.cantReach => l10nEn.cantReachTitle,
        };
        expect(
          tester.getSemantics(find.text(title)),
          matchesSemantics(label: title, isHeader: true),
        );
        expect(find.bySemanticsLabel(l10nEn.appTitle), findsOneWidget);
        handle.dispose();
      });

      for (final (size, scale) in [
        (const Size(390, 844), 1.0),
        (const Size(320, 480), 1.0),
        (const Size(320, 480), 2.0),
        (const Size(390, 844), 2.0),
      ]) {
        testWidgets('fits and scrolls at $size, text x$scale', (tester) async {
          setUpView(tester, size: size, textScale: scale);
          await pumpView(tester, SplashState.failed(problem));

          expect(tester.takeException(), isNull); // no overflow
          // Every piece can be reached: scroll to the end and the button is on screen.
          expect(find.byType(PrimaryButton), findsOneWidget);
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -2000),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          final button = tester.getRect(find.byType(PrimaryButton));
          expect(button.top, greaterThanOrEqualTo(0));
          expect(button.bottom, lessThanOrEqualTo(size.height));
        });
      }
    });
  }
}
