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
  }) => tester.pumpApp(
    SplashView(state: state, onRetry: onRetry ?? () {}),
    locale: locale,
    settle: false,
  );

  group('loading', () {
    testView(
      'the 72 tile and its wordmark are centered, the spinner is at the bottom',
      (tester) async {
        await pumpView(tester, const SplashState.deciding());

        expect(tester.getSize(find.byType(LogoTile)), const Size(72, 72));
        final tile = tester.getCenter(find.byType(LogoTile));
        final wordmark = tester.getCenter(find.text('pulse'));
        expect(tile.dx, 195);
        expect(wordmark.dx, 195);
        expect(wordmark.dy, greaterThan(tile.dy));
        final spinner = tester.getCenter(
          find.byType(CircularProgressIndicator),
        );
        expect(spinner.dx, 195);
        expect(spinner.dy, greaterThan(700));
        expect(
          tester.getSize(find.byType(CircularProgressIndicator)),
          const Size(28, 28),
        );
        final indicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(indicator.backgroundColor, isNotNull); // the grey track
        expect(find.byType(PrimaryButton), findsNothing);
      },
    );

    testView('the spinner is announced as Loading', (tester) async {
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
          SplashProblem.cantReach => l10n.cantReachTitle,
        };
        String body() => switch (problem) {
          SplashProblem.offline => l10n.offlineBody,
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
          // Every piece can be reached: scroll to the end of the body, the button stays pinned.
          expect(find.byType(PrimaryButton), findsOneWidget);
          final button = tester.getRect(find.byType(PrimaryButton));
          expect(button.bottom, lessThanOrEqualTo(size.height));
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -2000),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(tester.getRect(find.byType(PrimaryButton)), button);
        });
      }
    });
  }
}
