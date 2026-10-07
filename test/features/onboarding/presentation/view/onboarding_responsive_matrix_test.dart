import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:pulse/features/onboarding/presentation/widgets/onboarding_panel.dart';
import 'package:pulse/features/onboarding/presentation/widgets/sign_in_link.dart';

import '../../../../helpers/pump_app.dart';

/// Every window the app can meet (small phone, phone, landscape phone, tablet, desktop, ultra-wide) x
/// system text scale x language x page: no overflow, the footer control is reachable by scrolling
/// and big enough to tap, and the illustration stays visible.
void main() {
  const sizes = [
    Size(280, 500), // Galaxy Z Fold outer screen
    Size(320, 568), // smallest common phone
    Size(320, 300), // tiny split-screen window
    Size(390, 844),
    Size(844, 390), // phone in landscape
    Size(768, 1024), // tablet portrait
    Size(1280, 800), // desktop / web
    Size(2560, 1440), // ultra-wide
  ];
  final scrollable = find
      .descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      )
      .first;

  group('window x text scale x language x page', () {
    for (final size in sizes) {
      for (final scale in const [1.0, 2.0, 3.0]) {
        for (final locale in const [Locale('en'), Locale('ar')]) {
          testWidgets(
            '${size.width.toInt()}x${size.height.toInt()}, text $scale, ${locale.languageCode}',
            (t) async {
              t.view.physicalSize = size;
              t.view.devicePixelRatio = 1;
              t.platformDispatcher.textScaleFactorTestValue = scale;
              addTearDown(t.view.reset);
              addTearDown(t.platformDispatcher.clearAllTestValues);

              await t.pumpApp(
                OnboardingView(
                  onSkip: () {},
                  onGetStarted: () {},
                  onSignIn: () {},
                ),
                locale: locale,
              );

              for (var page = 0; page < 3; page++) {
                final reason = 'page ${page + 1}';
                expect(t.takeException(), isNull, reason: reason);
                expect(
                  t
                      .getSize(
                        find.descendant(
                          of: find.byType(OnboardingPanel),
                          matching: find.byType(ClipRRect),
                        ),
                      )
                      .height,
                  greaterThan(100),
                  reason: '$reason: illustration visible',
                );

                final control = page < 2
                    ? find.byType(PrimaryButton)
                    : find.byType(SignInLink);
                await t.scrollUntilVisible(
                  control,
                  150,
                  scrollable: scrollable,
                  maxScrolls: 60,
                );
                await t.pumpAndSettle();
                final rect = t.getRect(control);
                final screen = Offset.zero & size;
                expect(
                  screen.contains(rect.topLeft) &&
                      screen.contains(
                        rect.bottomRight - const Offset(0.01, 0.01),
                      ),
                  isTrue,
                  reason: '$reason: footer control $rect on screen $size',
                );
                expect(
                  rect.height,
                  greaterThanOrEqualTo(43.99),
                  reason: '$reason: tap target height',
                );
                expect(
                  rect.width,
                  greaterThanOrEqualTo(43.99),
                  reason: '$reason: tap target width',
                );
                if (page < 2) {
                  await t.tap(control);
                  await t.pumpAndSettle();
                }
              }
              expect(t.takeException(), isNull);
            },
          );
        }
      }
    }
  });

  group('pointer and keyboard (web / desktop)', () {
    Future<PageController> pump(WidgetTester t, Locale locale) async {
      t.view.physicalSize = const Size(1280, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpApp(
        OnboardingView(onSkip: () {}, onGetStarted: () {}, onSignIn: () {}),
        locale: locale,
      );
      return t.widget<PageView>(find.byType(PageView)).controller!;
    }

    testWidgets('a mouse can drag between pages', (t) async {
      final pages = await pump(t, const Locale('en'));
      final g = await t.startGesture(
        const Offset(640, 400),
        kind: PointerDeviceKind.mouse,
      );
      await g.moveBy(
        const Offset(-600, 0),
      ); // past half of the 840 dp content width;
      await g.up();
      await t.pumpAndSettle();
      expect(pages.page, 1);
    });

    testWidgets('arrow keys step through the pages: Right is next in English', (
      t,
    ) async {
      final pages = await pump(t, const Locale('en'));
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(pages.page, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pumpAndSettle();
      expect(pages.page, 0);
    });

    testWidgets('arrow keys are mirrored in Arabic: Left is next', (t) async {
      final pages = await pump(t, const Locale('ar'));
      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pumpAndSettle();
      expect(pages.page, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(pages.page, 0);
    });
  });
}
