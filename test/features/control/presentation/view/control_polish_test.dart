import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/core/theme/app_dimens.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/control/presentation/cubit/control_cubit.dart';
import 'package:pulse/features/control/presentation/view/control_view.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/glass_nav_bar.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/nav_badge.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/nav_item.dart';
import 'package:pulse/features/control/presentation/widgets/tab_placeholder.dart';

import '../../../../helpers/feed_refresh_mocks.dart';
import '../../../../helpers/pump_app.dart';

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

/// The shell on a phone frame with a notch and a gesture bar, in both languages, at large text, with
/// reduced motion and on a wide window: the checks of the polish phase (docs/plans/control-page-plan.md).
void main() {
  late ControlCubit cubit;

  setUp(() {
    final recovery = MockIsRecoveryPending();
    when(() => recovery()).thenReturn(false);
    cubit = ControlCubit(recovery, MockRequestFeedRefresh());
  });

  tearDown(() => cubit.close());

  Future<void> pumpShell(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
  }) => tester.pumpApp(
    Builder(
      // Keeps the window's insets and text scale; only the motion setting changes.
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: BlocProvider.value(
          value: cubit,
          child: ControlView(
            rootBuilder: (context, tab) => TabPlaceholder(tab: tab),
          ),
        ),
      ),
    ),
    locale: locale,
  );

  /// The nav item read by a screen reader, not the tab page's own title.
  Finder inBar(String label) => find.descendant(
    of: find.byType(GlassNavBar),
    matching: find.bySemanticsLabel(label),
  );

  Finder item(String label) =>
      find.byWidgetPredicate((w) => w is NavItem && w.label == label);

  group('a phone frame with a notch and a gesture bar', () {
    testWidgets('the bar floats 16 / 16 / 18 above the system inset, 68 high', (
      tester,
    ) async {
      setUpView(tester);
      await pumpShell(tester);
      final bar = tester.getRect(
        find.descendant(
          of: find.byType(GlassNavBar),
          matching: find.byType(BackdropFilter),
        ),
      );
      expect(bar.left, NavDimens.sideInset);
      expect(bar.right, 390 - NavDimens.sideInset);
      expect(bar.height, NavDimens.height);
      expect(bar.bottom, 844 - (NavDimens.bottomInset + 34));
    });

    testWidgets('every item is at least 56 x 56 to tap', (tester) async {
      setUpView(tester);
      await pumpShell(tester);
      for (final label in ['Home', 'Shorts', 'Create', 'Chat', 'Profile']) {
        final size = tester.getSize(item(label));
        expect(size.height, greaterThanOrEqualTo(56), reason: label);
        expect(size.width, greaterThanOrEqualTo(56), reason: label);
      }
    });

    testWidgets('a tab page keeps clear of the bar and the gesture bar', (
      tester,
    ) async {
      setUpView(tester);
      await pumpShell(tester);
      final placeholder = tester.getRect(find.byType(TabPlaceholder));
      final bar = tester.getRect(find.byType(GlassNavBar));
      expect(
        NavClearance.of(tester.element(find.byType(TabPlaceholder))),
        NavDimens.contentClearance + 34,
      );
      expect(placeholder.bottom, 844);
      expect(bar.bottom, lessThan(844));
    });
  });

  group('screen readers', () {
    testWidgets('every item has its label in English', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpShell(tester);
      for (final label in ['Home', 'Shorts', 'Create', 'Chat', 'Profile']) {
        expect(inBar(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets('and in Arabic', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpShell(tester, locale: const Locale('ar'));
      for (final label in [
        l10nAr.navHome,
        l10nAr.navShorts,
        l10nAr.navCreate,
        l10nAr.navChat,
        l10nAr.navProfile,
      ]) {
        expect(inBar(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets(
      'the bar is out of the reading order while the keyboard hides it',
      (tester) async {
        await pumpShell(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ExcludeSemantics>(
                find.descendant(
                  of: find.byType(AnimatedSlide),
                  matching: find.byType(ExcludeSemantics),
                ),
              )
              .excluding,
          isTrue,
        );
      },
    );
  });

  group('Arabic (right to left)', () {
    testWidgets('Home is on the right, Profile on the left', (tester) async {
      await pumpShell(tester, locale: const Locale('ar'));
      expect(
        tester.getCenter(item(l10nAr.navHome)).dx,
        greaterThan(tester.getCenter(item(l10nAr.navProfile)).dx),
      );
    });

    testWidgets('the badge mirrors: past the centre of Chat, toward the left', (
      tester,
    ) async {
      await pumpShell(tester, locale: const Locale('ar'));
      final chat = tester.getRect(item(l10nAr.navChat));
      final badge = tester.getCenter(
        find.descendant(
          of: item(l10nAr.navChat),
          matching: find.byType(NavBadge),
        ),
      );
      expect(badge.dx, lessThan(chat.center.dx));
    });

    testWidgets('and in English it sits to the right of the centre', (
      tester,
    ) async {
      await pumpShell(tester);
      final chat = tester.getRect(item('Chat'));
      final badge = tester.getCenter(
        find.descendant(of: item('Chat'), matching: find.byType(NavBadge)),
      );
      expect(badge.dx, greaterThan(chat.center.dx));
    });
  });

  testWidgets(
    'with text at 1.5x the bar and the Create sheet do not overflow',
    (tester) async {
      setUpView(tester, textScale: 1.5, deviceLocale: const Locale('ar'));
      await pumpShell(tester, locale: const Locale('ar'));
      await tester.tap(item(l10nAr.navCreate));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10nAr.createShortSub), findsOneWidget);
    },
  );

  group('reduce motion', () {
    testWidgets('the bubble moves at once, the icons do not cross-fade', (
      tester,
    ) async {
      await pumpShell(tester, reduceMotion: true);
      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .duration,
        Duration.zero,
      );
      expect(
        tester
            .widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher).first)
            .duration,
        Duration.zero,
      );
    });

    testWidgets('the bar does not slide when the keyboard opens', (
      tester,
    ) async {
      await pumpShell(tester, reduceMotion: true);
      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).duration,
        Duration.zero,
      );
    });

    testWidgets('with motion on they take 220 / 150 / 200 ms', (tester) async {
      await pumpShell(tester);
      expect(
        tester
            .widget<AnimatedPositionedDirectional>(
              find.byType(AnimatedPositionedDirectional),
            )
            .duration,
        NavDimens.bubbleDuration,
      );
      expect(
        tester
            .widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher).first)
            .duration,
        NavDimens.iconFadeDuration,
      );
      expect(
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).duration,
        NavDimens.hideDuration,
      );
    });
  });

  testWidgets('on a tablet the bar stays at the shared max width, centered', (
    tester,
  ) async {
    setUpView(tester, size: const Size(1280, 800));
    await pumpShell(tester);
    final bar = tester.getRect(
      find.descendant(
        of: find.byType(GlassNavBar),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(bar.width, lessThanOrEqualTo(AppBreakpoints.maxContentWidth));
    expect(bar.center.dx, closeTo(640, 1));
  });
}
