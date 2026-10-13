import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/constants/app_assets.dart';
import 'package:pulse/core/theme/app_breakpoints.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/control/presentation/utils/enums/main_tab.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/glass_nav_bar.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/nav_item.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  final selectedTab = ValueNotifier<MainTab>(MainTab.home);
  final badge = ValueNotifier<int>(0);
  late List<MainTab> tapped;
  late int created;
  late int haptics;

  setUp(() {
    selectedTab.value = MainTab.home;
    badge.value = 0;
    tapped = [];
    created = 0;
    haptics = 0;
  });

  Future<void> pumpBar(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
  }) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') haptics++;
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpApp(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          body: Stack(
            children: [
              ListView(children: [for (var i = 0; i < 30; i++) Text('row $i')]),
              Align(
                alignment: Alignment.bottomCenter,
                child: ValueListenableBuilder<MainTab>(
                  valueListenable: selectedTab,
                  builder: (context, tab, _) => ValueListenableBuilder<int>(
                    valueListenable: badge,
                    builder: (context, count, _) => GlassNavBar(
                      selected: tab,
                      chatBadge: count,
                      onTabSelected: tapped.add,
                      onCreate: () => created++,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      locale: locale,
    );
  }

  Finder icon(String asset) =>
      find.byWidgetPredicate((w) => w is AppSvgIcon && w.asset == asset);
  Finder item(String label) =>
      find.byWidgetPredicate((w) => w is NavItem && w.label == label);

  testWidgets('has five slots: four tabs and the Create button', (
    tester,
  ) async {
    await pumpBar(tester);
    expect(find.byType(NavItem), findsNWidgets(5));
    expect(icon(AppAssets.plus), findsOneWidget);
  });

  testWidgets(
    'the selected tab shows the filled icon, the others the outline',
    (tester) async {
      await pumpBar(tester);
      expect(icon(AppAssets.homeFilled), findsOneWidget);
      expect(icon(AppAssets.home), findsNothing);
      expect(icon(AppAssets.shorts), findsOneWidget);
      expect(icon(AppAssets.shortsFilled), findsNothing);

      selectedTab.value = MainTab.shorts;
      await tester.pumpAndSettle();
      expect(icon(AppAssets.shortsFilled), findsOneWidget);
      expect(icon(AppAssets.home), findsOneWidget);
      expect(icon(AppAssets.homeFilled), findsNothing);
    },
  );

  testWidgets('Create is never selected and does not select a tab', (
    tester,
  ) async {
    await pumpBar(tester);
    await tester.tap(item('Create'));
    await tester.pumpAndSettle();
    expect(created, 1);
    expect(tapped, isEmpty);
    expect(tester.widget<NavItem>(item('Create')).selected, isFalse);
  });

  testWidgets('a tap on a tab reports it, also on the selected one', (
    tester,
  ) async {
    await pumpBar(tester);
    await tester.tap(item('Chat'));
    await tester.tap(item('Home'));
    expect(tapped, [MainTab.chat, MainTab.home]);
  });

  testWidgets('haptic tick on a tab change and on Create, not on a re-tap', (
    tester,
  ) async {
    await pumpBar(tester);
    await tester.tap(item('Shorts'));
    expect(haptics, 1);
    await tester.tap(item('Home')); // already selected
    expect(haptics, 1);
    await tester.tap(item('Create'));
    expect(haptics, 2);
  });

  testWidgets('the Chat badge: hidden at 0, the count, "99+" above 99', (
    tester,
  ) async {
    await pumpBar(tester);
    expect(find.text('4'), findsNothing);

    badge.value = 4;
    await tester.pump();
    expect(find.text('4'), findsOneWidget);

    badge.value = 99;
    await tester.pump();
    expect(find.text('99'), findsOneWidget);

    badge.value = 100;
    await tester.pump();
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets(
    'screen readers get a label, the selected state and the unread count',
    (tester) async {
      final handle = tester.ensureSemantics();
      badge.value = 4;
      await pumpBar(tester);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')),
        matchesSemantics(
          label: 'Home',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
          hasSelectedState: true,
          isEnabled: false,
          hasEnabledState: false,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Chat')).value,
        '4 unread',
      );
      handle.dispose();
    },
  );

  testWidgets('Arabic: the order mirrors, Home on the right', (tester) async {
    await pumpBar(tester, locale: const Locale('ar'));
    final home = tester.getCenter(item('الرئيسية')).dx;
    final profile = tester.getCenter(item('الملف الشخصي')).dx;
    expect(home, greaterThan(profile));
  });

  testWidgets('English: Home on the left, Profile on the right', (
    tester,
  ) async {
    await pumpBar(tester);
    expect(
      tester.getCenter(item('Home')).dx,
      lessThan(tester.getCenter(item('Profile')).dx),
    );
  });

  testWidgets('the badge sits above and past the centre of the Chat item', (
    tester,
  ) async {
    badge.value = 4;
    await pumpBar(tester);
    final chat = tester.getRect(item('Chat'));
    final badgeCenter = tester.getCenter(find.text('4'));
    expect(badgeCenter.dx, greaterThan(chat.center.dx));
    expect(badgeCenter.dy, lessThan(chat.center.dy));
  });

  testWidgets('the bubble slides 220 ms; with reduce motion it moves at once', (
    tester,
  ) async {
    await pumpBar(tester);
    AnimatedPositionedDirectional bubble() =>
        tester.widget(find.byType(AnimatedPositionedDirectional));
    expect(bubble().duration, const Duration(milliseconds: 220));
  });

  testWidgets('reduce motion: no bubble slide', (tester) async {
    await pumpBar(tester, reduceMotion: true);
    final bubble = tester.widget<AnimatedPositionedDirectional>(
      find.byType(AnimatedPositionedDirectional),
    );
    expect(bubble.duration, Duration.zero);
  });

  testWidgets('the bubble moves under the new tab', (tester) async {
    await pumpBar(tester);
    final before = tester
        .widget<AnimatedPositionedDirectional>(
          find.byType(AnimatedPositionedDirectional),
        )
        .start;
    selectedTab.value = MainTab.profile;
    await tester.pumpAndSettle();
    final after = tester
        .widget<AnimatedPositionedDirectional>(
          find.byType(AnimatedPositionedDirectional),
        )
        .start;
    expect(after, greaterThan(before!));
  });

  testWidgets('on a wide window the bar stays at the shared max width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpBar(tester);
    final bar = tester.getRect(find.byType(GlassNavBar));
    final pill = tester.getRect(
      find.descendant(
        of: find.byType(GlassNavBar),
        matching: find.byType(BackdropFilter),
      ),
    );
    expect(bar.width, 1600);
    expect(pill.width, lessThanOrEqualTo(AppBreakpoints.maxContentWidth));
    expect(pill.center.dx, closeTo(800, 1));
  });
}
