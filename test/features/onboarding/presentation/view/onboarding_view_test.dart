import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/theme/app_dimens.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/onboarding/presentation/utils/enums/onboarding_top_bar_leading.dart';
import 'package:pulse/features/onboarding/presentation/view/onboarding_view.dart';
import 'package:pulse/features/onboarding/presentation/widgets/onboarding_panel.dart';
import 'package:pulse/features/onboarding/presentation/widgets/onboarding_top_bar.dart';
import 'package:pulse/features/onboarding/presentation/widgets/page_dots.dart';
import 'package:pulse/features/onboarding/presentation/widgets/sign_in_link.dart';

import '../../../../helpers/pump_app.dart';

class _Calls {
  final log = <String>[];
  Widget view() => OnboardingView(
    onSkip: () => log.add('skip'),
    onGetStarted: () => log.add('getStarted'),
    onSignIn: () => log.add('signIn'),
  );
}

int _dotIndex(WidgetTester t) =>
    t.widget<PageDots>(find.byType(PageDots)).index;
OnboardingTopBar _topBar(WidgetTester t) =>
    t.widget<OnboardingTopBar>(find.byType(OnboardingTopBar));

/// The footer is part of each page's scroll view and is built lazily: scroll until it exists and is visible.
Future<void> _reveal(WidgetTester t, Finder finder) async {
  await t.scrollUntilVisible(
    finder,
    200,
    scrollable: find
        .descendant(
          of: find.byType(CustomScrollView),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await t.pumpAndSettle();
}

Future<void> _next(WidgetTester t) async {
  await _reveal(t, find.byType(PrimaryButton));
  await t.tap(find.byType(PrimaryButton));
  await t.pumpAndSettle();
}

/// True when [finder]'s icon sits under a horizontal flip.
bool _isFlipped(WidgetTester t, Finder finder) {
  var flipped = false;
  t.element(finder).visitAncestorElements((e) {
    final w = e.widget;
    if (w is Transform && w.transform.storage[0] < 0) flipped = true;
    return true;
  });
  return flipped;
}

Finder get _topBarIcon => find.descendant(
  of: find.byType(OnboardingTopBar),
  matching: find.byType(SvgPicture),
);
Finder get _nextIcon => find.descendant(
  of: find.byType(PrimaryButton),
  matching: find.byType(SvgPicture),
);

void main() {
  group('pages and top bar', () {
    testWidgets(
      'S1: logo + Skip, no back, first dot active, Next in the footer',
      (t) async {
        setUpView(t);
        await t.pumpApp(_Calls().view());

        expect(_topBar(t).leading, OnboardingTopBarLeading.logo);
        expect(find.text(l10nEn.skip), findsOneWidget);
        expect(find.bySemanticsLabel(l10nEn.back), findsNothing);
        expect(_dotIndex(t), 0);
        expect(find.text(l10nEn.onboarding1Title), findsOneWidget);
        expect(find.text(l10nEn.next), findsOneWidget);
        expect(find.byType(SignInLink), findsNothing);
        expect(find.text(l10nEn.getStarted), findsNothing);
      },
    );

    testWidgets('S2: back + Skip, second dot active', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());
      await _next(t);

      expect(_topBar(t).leading, OnboardingTopBarLeading.back);
      expect(find.text(l10nEn.skip), findsOneWidget);
      expect(_dotIndex(t), 1);
      expect(find.text(l10nEn.onboarding2Title), findsOneWidget);
      expect(find.byType(SignInLink), findsNothing);
    });

    testWidgets('S3: back only, third dot, Get started and the Sign in link', (
      t,
    ) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());
      await _next(t);
      await _next(t);

      expect(_topBar(t).leading, OnboardingTopBarLeading.back);
      expect(find.text(l10nEn.skip), findsNothing);
      expect(_dotIndex(t), 2);
      expect(find.text(l10nEn.onboarding3Title), findsOneWidget);
      expect(find.text(l10nEn.getStarted), findsOneWidget);
      expect(find.byType(SignInLink), findsOneWidget);
      expect(find.text(l10nEn.next), findsNothing);
      expect(t.getSize(find.byType(PrimaryButton)).width, 390 - 48);
    });
  });

  group('moving between pages', () {
    testWidgets('Next and Back step through the pages', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());

      await _next(t);
      expect(_dotIndex(t), 1);
      await _next(t);
      expect(_dotIndex(t), 2);
      await t.tap(
        find
            .descendant(
              of: find.byType(OnboardingTopBar),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      await t.pumpAndSettle();
      expect(_dotIndex(t), 1);
      await t.tap(
        find
            .descendant(
              of: find.byType(OnboardingTopBar),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      await t.pumpAndSettle();
      expect(_dotIndex(t), 0);
    });

    testWidgets('swiping moves the pages and the dots follow (LTR)', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());

      await t.drag(find.byType(PageView), const Offset(-300, 0));
      await t.pumpAndSettle();
      expect(_dotIndex(t), 1);
      await t.drag(find.byType(PageView), const Offset(-300, 0));
      await t.pumpAndSettle();
      expect(_dotIndex(t), 2);
      await t.drag(find.byType(PageView), const Offset(300, 0));
      await t.pumpAndSettle();
      expect(_dotIndex(t), 1);
    });

    testWidgets('swipe order reverses in RTL', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view(), locale: const Locale('ar'));

      await t.drag(find.byType(PageView), const Offset(300, 0));
      await t.pumpAndSettle();
      expect(_dotIndex(t), 1);
      await t.drag(find.byType(PageView), const Offset(-300, 0));
      await t.pumpAndSettle();
      expect(_dotIndex(t), 0);
    });

    testWidgets(
      'system back steps to the previous page, and leaves the app on the first page',
      (t) async {
        setUpView(t);
        await t.pumpApp(_Calls().view());
        await _next(t);
        await _next(t);

        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(_dotIndex(t), 1);
        await t.binding.handlePopRoute();
        await t.pumpAndSettle();
        expect(_dotIndex(t), 0);
      },
    );

    testWidgets('the page slide takes 250 ms with an ease-in-out curve', (
      t,
    ) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());
      final controller = t.widget<PageView>(find.byType(PageView)).controller!;

      await _reveal(t, find.byType(PrimaryButton));
      await t.tap(find.byType(PrimaryButton));
      await t.pump();
      await t.pump(const Duration(milliseconds: 125));
      expect(controller.page, inExclusiveRange(0.3, 0.7));
      await t.pump(const Duration(milliseconds: 130));
      expect(controller.page, closeTo(1, 0.001));
      await t.pumpAndSettle();
    });

    testWidgets('with reduce motion the page changes at once', (t) async {
      setUpView(t);
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await t.pumpApp(_Calls().view());

      await _reveal(t, find.byType(PrimaryButton));
      await t.tap(find.byType(PrimaryButton));
      await t.pump();
      expect(
        t.widget<PageView>(find.byType(PageView)).controller!.page,
        closeTo(1, 0.001),
      );
      expect(t.takeException(), isNull);
      await t.pumpAndSettle();
      expect(_dotIndex(t), 1);
    });
  });

  group('callbacks', () {
    testWidgets('Skip fires on S1 and on S2', (t) async {
      setUpView(t);
      final calls = _Calls();
      await t.pumpApp(calls.view());

      await t.tap(find.text(l10nEn.skip));
      await _next(t);
      await t.tap(find.text(l10nEn.skip));

      expect(calls.log, ['skip', 'skip']);
    });

    testWidgets('Get started and the Sign in link fire their own callbacks', (
      t,
    ) async {
      setUpView(t);
      final calls = _Calls();
      await t.pumpApp(calls.view());
      await _next(t);
      await _next(t);

      await _reveal(t, find.text(l10nEn.getStarted));

      await t.tap(find.text(l10nEn.getStarted));
      await t.tap(find.byType(SignInLink));

      expect(calls.log, ['getStarted', 'signIn']);
    });
  });

  group('RTL', () {
    testWidgets(
      'S1: the logo group is on the right and not flipped, "pulse" stays Latin, Skip is on the left',
      (t) async {
        setUpView(t);
        await t.pumpApp(_Calls().view(), locale: const Locale('ar'));
        final width = t.getSize(find.byType(Scaffold)).width;

        expect(_isFlipped(t, _topBarIcon), isFalse);
        expect(t.getCenter(_topBarIcon).dx, greaterThan(width / 2));
        expect(find.text('pulse'), findsOneWidget);
        expect(t.getCenter(find.text(l10nAr.skip)).dx, lessThan(width / 2));
      },
    );

    testWidgets(
      'the Next arrow flips; Next sits at the end and the dots at the start',
      (t) async {
        setUpView(t);
        await t.pumpApp(_Calls().view(), locale: const Locale('ar'));
        final width = t.getSize(find.byType(Scaffold)).width;

        expect(_isFlipped(t, _nextIcon), isTrue);
        expect(t.getCenter(find.byType(PrimaryButton)).dx, lessThan(width / 2));
        expect(t.getCenter(find.byType(PageDots)).dx, greaterThan(width / 2));
      },
    );

    testWidgets('the back arrow flips and sits at the start', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view(), locale: const Locale('ar'));
      await _next(t);
      final width = t.getSize(find.byType(Scaffold)).width;

      expect(_isFlipped(t, _topBarIcon), isTrue);
      expect(t.getCenter(_topBarIcon).dx, greaterThan(width / 2));
    });

    testWidgets('in LTR the arrows are not flipped', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());
      expect(_isFlipped(t, _nextIcon), isFalse);
      await _next(t);
      expect(_isFlipped(t, _topBarIcon), isFalse);
    });

    testWidgets(
      'Arabic title and body styles: Noto Sans Arabic, letterSpacing 0, line height +0.1',
      (t) async {
        setUpView(t);
        await t.pumpApp(_Calls().view(), locale: const Locale('ar'));

        final title = t.widget<Text>(find.text(l10nAr.onboarding1Title)).style!;
        final body = t.widget<Text>(find.text(l10nAr.onboarding1Body)).style!;
        expect(title.fontFamily, 'NotoSansArabic');
        expect(title.letterSpacing, 0);
        expect(title.height, 1.3);
        expect(body.fontFamily, 'NotoSansArabic');
        expect(body.letterSpacing, 0);
        expect(body.height, 1.65);
      },
    );

    testWidgets('Latin title style keeps Sora 28/700 with -0.6 tracking', (
      t,
    ) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());

      final title = t.widget<Text>(find.text(l10nEn.onboarding1Title)).style!;
      expect(title.fontFamily, 'Sora');
      expect(title.fontSize, 28);
      expect(title.fontWeight, FontWeight.w700);
      expect(title.letterSpacing, -0.6);
      expect(title.height, 1.2);
    });
  });

  group('accessibility', () {
    testWidgets(
      'labels: Back, Skip and "Page N of 3"; the illustration is not in the semantics tree',
      (t) async {
        final handle = t.ensureSemantics();
        setUpView(t);
        await t.pumpApp(_Calls().view());

        expect(
          find.bySemanticsLabel(l10nEn.onboardingPageIndicator(1, 3)),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel(l10nEn.skip), findsOneWidget);
        expect(t.getSemantics(find.byType(Image)).label, isEmpty);
        await _next(t);
        expect(find.bySemanticsLabel(l10nEn.back), findsOneWidget);
        expect(
          find.bySemanticsLabel(l10nEn.onboardingPageIndicator(2, 3)),
          findsOneWidget,
        );
        handle.dispose();
      },
    );

    testWidgets('tap targets are at least 44 dp', (t) async {
      setUpView(t);
      await t.pumpApp(_Calls().view());
      final skip = t.getSize(
        find
            .ancestor(
              of: find.text(l10nEn.skip),
              matching: find.byType(InkResponse),
            )
            .first,
      );
      expect(skip.height, greaterThanOrEqualTo(44));
      expect(skip.width, greaterThanOrEqualTo(44));
      expect(
        t.getSize(find.byType(PrimaryButton)).height,
        greaterThanOrEqualTo(56),
      );

      await _next(t);
      expect(
        t.getSize(
          find
              .ancestor(of: _topBarIcon, matching: find.byType(InkResponse))
              .first,
        ),
        const Size(44, 44),
      );
      await _next(t);
      expect(
        t.getSize(find.byType(SignInLink)).height,
        greaterThanOrEqualTo(44),
      );
    });
  });

  group('text scale 1.5 causes no overflow', () {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final size in [const Size(390, 844), const Size(360, 640)]) {
        testWidgets('${locale.languageCode} on $size, all pages', (t) async {
          setUpView(t, size: size, textScale: 1.5);
          await t.pumpApp(_Calls().view(), locale: locale);

          for (var page = 0; page < 3; page++) {
            expect(t.takeException(), isNull, reason: 'page ${page + 1}');
            if (page < 2) await _next(t);
          }
          expect(t.takeException(), isNull);
          // The footer scrolls with the page: once revealed it is inside the safe area (bottom inset 34).
          await _reveal(t, find.byType(SignInLink));
          expect(
            t.getBottomLeft(find.byType(SignInLink)).dy,
            lessThanOrEqualTo(size.height - 34 + 0.5),
          );
        });
      }
    }
  });

  group('responsive layout', () {
    for (final size in const [
      Size(320, 640),
      Size(390, 844),
      Size(700, 1000),
      Size(1280, 800),
    ]) {
      testWidgets('lays out at ${size.width.toInt()} wide at 200% text', (
        t,
      ) async {
        t.view.physicalSize = size;
        t.view.devicePixelRatio = 1.0;
        t.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(t.view.reset);
        addTearDown(t.platformDispatcher.clearAllTestValues);

        await t.pumpApp(_Calls().view());

        expect(t.takeException(), isNull);
        await _reveal(t, find.byType(PrimaryButton));
        expect(
          t.getSize(find.byType(PrimaryButton)).width,
          lessThanOrEqualTo(840),
        );
      });
    }
  });

  group('live window resize', () {
    testWidgets('dimensions follow the window, state is kept', (t) async {
      addTearDown(t.view.reset);
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(390, 844);
      await t.pumpApp(_Calls().view());
      await _next(t);
      double panelHeight() => t
          .getSize(
            find.descendant(
              of: find.byType(OnboardingPanel),
              matching: find.byType(ClipRRect),
            ),
          )
          .height;
      final atDesign = panelHeight();

      t.view.physicalSize = const Size(
        1280,
        1000,
      ); // browser window dragged wide
      await t.pumpAndSettle();
      expect(panelHeight(), greaterThan(atDesign));

      t.view.physicalSize = const Size(320, 480);
      await t.pumpAndSettle();
      expect(panelHeight(), lessThan(atDesign));
      expect(t.takeException(), isNull);
      await _reveal(t, find.byType(PageDots));
      expect(_dotIndex(t), 1); // still on page 2
    });
  });

  group('panel on odd windows', () {
    testWidgets(
      'keeps the art aspect and leaves room for the text on a short, wide window',
      (t) async {
        addTearDown(t.view.reset);
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = const Size(1280, 600);
        await t.pumpApp(_Calls().view());
        final panel = t.getSize(
          find.descendant(
            of: find.byType(OnboardingPanel),
            matching: find.byType(ClipRRect),
          ),
        );
        expect(panel.height, lessThanOrEqualTo(600 * 0.5));
        expect(
          panel.width,
          lessThan(panel.height),
        ); // portrait art, centered: not stretched across the window
        expect(t.takeException(), isNull);
      },
    );
  });

  group('footer position', () {
    testWidgets(
      'on a tall window the footer sits at the bottom, one footer padding above the edge',
      (t) async {
        addTearDown(t.view.reset);
        t.view.devicePixelRatio = 1;
        t.view.physicalSize = const Size(412, 1000);
        await t.pumpApp(_Calls().view());
        final scrollBottom = t.getRect(find.byType(CustomScrollView)).bottom;
        final buttonBottom = t.getRect(find.byType(PrimaryButton)).bottom;
        expect(
          scrollBottom - buttonBottom,
          closeTo(OnboardingDimens.footerPadding.bottom, 0.5),
        );
      },
    );
  });

  group('scrolls only when needed', () {
    testWidgets('a tall window has nothing to scroll; a short one scrolls', (
      t,
    ) async {
      addTearDown(t.view.reset);
      t.view.devicePixelRatio = 1;
      double maxExtent() => t
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(CustomScrollView),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position
          .maxScrollExtent;

      t.view.physicalSize = const Size(412, 1000);
      await t.pumpApp(_Calls().view());
      expect(maxExtent(), 0);

      t.view.physicalSize = const Size(320, 400);
      await t.pumpAndSettle();
      expect(maxExtent(), greaterThan(0));
    });
  });
}
