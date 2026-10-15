import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/auth/domain/use_case/is_recovery_pending_use_case.dart';
import 'package:pulse/features/control/presentation/cubit/control_cubit.dart';
import 'package:pulse/features/control/presentation/dimens/nav_dimens.dart';
import 'package:pulse/features/control/presentation/utils/enums/main_tab.dart';
import 'package:pulse/features/control/presentation/view/control_view.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/glass_nav_bar.dart';
import 'package:pulse/features/control/presentation/widgets/glass_nav_bar/nav_item.dart';
import 'package:pulse/l10n/app_localizations.dart';

import '../../../../helpers/feed_refresh_mocks.dart';
import '../../../../helpers/pump_app.dart';

class MockIsRecoveryPending extends Mock implements IsRecoveryPendingUseCase {}

/// A tab root with a counter (to see that the tab keeps its state), a button that pushes a sub-page inside
/// the tab and a long list (to scroll).
class _TestRoot extends StatefulWidget {
  const _TestRoot(this.tab);

  final MainTab tab;

  @override
  State<_TestRoot> createState() => _TestRootState();
}

class _TestRootState extends State<_TestRoot> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      children: [
        TextButton(
          onPressed: () => setState(() => _count++),
          child: Text('count ${widget.tab.name}: $_count'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => Scaffold(body: Text('sub ${widget.tab.name}')),
            ),
          ),
          child: Text('push ${widget.tab.name}'),
        ),
        Text('clearance ${NavClearance.of(context)}'),
        for (var i = 0; i < 40; i++)
          SizedBox(height: 60, child: Text('row $i')),
      ],
    ),
  );
}

void main() {
  late ControlCubit cubit;
  late MockRequestFeedRefresh feedRefresh;
  late List<String> platformCalls;

  setUp(() {
    final recovery = MockIsRecoveryPending();
    when(() => recovery()).thenReturn(false);
    feedRefresh = MockRequestFeedRefresh();
    cubit = ControlCubit(recovery, feedRefresh);
    platformCalls = [];
  });

  tearDown(() => cubit.close());

  Future<void> pumpShell(WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call.method);
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    await tester.pumpApp(
      BlocProvider.value(
        value: cubit,
        child: ControlView(rootBuilder: (context, tab) => _TestRoot(tab)),
      ),
    );
  }

  Finder item(String label) =>
      find.byWidgetPredicate((w) => w is NavItem && w.label == label);

  testWidgets(
    'only the Home tab is built at first; a tab is built when opened',
    (tester) async {
      await pumpShell(tester);
      expect(find.text('count home: 0'), findsOneWidget);
      expect(find.text('count shorts: 0', skipOffstage: false), findsNothing);

      await tester.tap(item('Shorts'));
      await tester.pumpAndSettle();
      expect(find.text('count shorts: 0'), findsOneWidget);
      expect(cubit.state.selected, MainTab.shorts);
    },
  );

  testWidgets('a tab keeps its state while another is open', (tester) async {
    await pumpShell(tester);
    await tester.tap(find.text('count home: 0'));
    await tester.pump();
    expect(find.text('count home: 1'), findsOneWidget);

    await tester.tap(item('Chat'));
    await tester.pumpAndSettle();
    await tester.tap(item('Home'));
    await tester.pumpAndSettle();
    expect(find.text('count home: 1'), findsOneWidget);
  });

  testWidgets('a pushed sub-page opens inside the tab and the nav stays', (
    tester,
  ) async {
    await pumpShell(tester);
    await tester.tap(find.text('push home'));
    await tester.pumpAndSettle();
    expect(find.text('sub home'), findsOneWidget);
    expect(find.byType(GlassNavBar), findsOneWidget);
    expect(tester.getRect(find.byType(NavItem).first).bottom, greaterThan(0));
  });

  testWidgets('every tab is told how much room the nav takes', (tester) async {
    await pumpShell(tester);
    expect(
      find.text('clearance ${NavDimens.contentClearance}'),
      findsOneWidget,
    );
  });

  group('system back', () {
    testWidgets('pops the sub-page inside the tab', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.text('push home'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('sub home'), findsNothing);
      expect(find.text('count home: 0'), findsOneWidget);
      expect(platformCalls, isNot(contains('SystemNavigator.pop')));
    });

    testWidgets('on a tab root other than Home goes to Home', (tester) async {
      await pumpShell(tester);
      await tester.tap(item('Shorts'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(cubit.state.selected, MainTab.home);
      expect(platformCalls, isNot(contains('SystemNavigator.pop')));
    });

    testWidgets('on the Home root leaves the app (Android)', (tester) async {
      await pumpShell(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(platformCalls, contains('SystemNavigator.pop'));
    });
  });

  group('re-tapping the selected tab', () {
    testWidgets('pops the tab back to its root', (tester) async {
      await pumpShell(tester);
      await tester.tap(find.text('push home'));
      await tester.pumpAndSettle();
      await tester.tap(item('Home'));
      await tester.pumpAndSettle();
      expect(find.text('sub home'), findsNothing);
      expect(find.text('count home: 0'), findsOneWidget);
    });

    testWidgets('at the root scrolls to the top', (tester) async {
      await pumpShell(tester);
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(find.text('push home'), findsNothing);

      await tester.tap(item('Home'));
      await tester.pumpAndSettle();
      expect(find.text('push home'), findsOneWidget);
    });

    testWidgets('at the root also asks the home feed to load again', (
      tester,
    ) async {
      await pumpShell(tester);
      await tester.tap(item('Home'));
      await tester.pumpAndSettle();
      verify(() => feedRefresh()).called(1);
    });

    testWidgets('going back to the root does not refresh the feed', (
      tester,
    ) async {
      await pumpShell(tester);
      await tester.tap(find.text('push home'));
      await tester.pumpAndSettle();
      await tester.tap(item('Home'));
      await tester.pumpAndSettle();
      verifyNever(() => feedRefresh());
    });

    testWidgets('another tab does not refresh the feed', (tester) async {
      await pumpShell(tester);
      await tester.tap(item('Shorts'));
      await tester.pumpAndSettle();
      await tester.tap(item('Shorts'));
      await tester.pumpAndSettle();
      verifyNever(() => feedRefresh());
    });
  });

  group('the keyboard', () {
    Offset slide(WidgetTester tester) =>
        tester.widget<AnimatedSlide>(find.byType(AnimatedSlide)).offset;

    testWidgets('hides the nav while it is open and brings it back', (
      tester,
    ) async {
      await pumpShell(tester);
      expect(slide(tester), Offset.zero);

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(slide(tester), isNot(Offset.zero));
      expect(
        tester
            .widget<IgnorePointer>(
              find.descendant(
                of: find.byType(AnimatedSlide),
                matching: find.byType(IgnorePointer),
              ),
            )
            .ignoring,
        isTrue,
      );

      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(slide(tester), Offset.zero);
    });
  });

  group('the Create button', () {
    Future<void> pumpShellWithRoutes(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: cubit,
            child: ControlView(rootBuilder: (context, tab) => _TestRoot(tab)),
          ),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Scaffold(body: Text('route ${settings.name}')),
          ),
        ),
      );
    }

    testWidgets('opens the Create sheet and does not change the tab', (
      tester,
    ) async {
      await pumpShell(tester);
      await tester.tap(item('Create'));
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomSheetShell), findsOneWidget);
      expect(find.text(l10nEn.createTitle), findsOneWidget);
      expect(find.text(l10nEn.createPost), findsOneWidget);
      expect(find.text(l10nEn.createShort), findsOneWidget);
      expect(cubit.state.selected, MainTab.home);
    });

    testWidgets('Post opens its flow over the shell, nav hidden', (
      tester,
    ) async {
      await pumpShellWithRoutes(tester);
      await tester.tap(item('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.createPost));
      await tester.pumpAndSettle();
      expect(find.text('route ${AppRoutes.createPost}'), findsOneWidget);
      expect(find.byType(AppBottomSheetShell), findsNothing);
      expect(find.byType(GlassNavBar), findsNothing);
    });

    testWidgets('Short opens its flow over the shell', (tester) async {
      await pumpShellWithRoutes(tester);
      await tester.tap(item('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.createShort));
      await tester.pumpAndSettle();
      expect(find.text('route ${AppRoutes.createShort}'), findsOneWidget);
    });

    testWidgets('from a page inside a tab it still covers the nav bar', (
      tester,
    ) async {
      await pumpShellWithRoutes(tester);
      await tester.tap(find.text('push home'));
      await tester.pumpAndSettle();
      await tester.tap(item('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10nEn.createPost));
      await tester.pumpAndSettle();
      expect(find.text('route ${AppRoutes.createPost}'), findsOneWidget);
      expect(find.byType(GlassNavBar), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('sub home'), findsOneWidget);
      expect(find.byType(GlassNavBar), findsOneWidget);
    });

    testWidgets('closing the sheet opens nothing', (tester) async {
      await pumpShellWithRoutes(tester);
      await tester.tap(item('Create'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.textContaining('route /create'), findsNothing);
      expect(find.byType(GlassNavBar), findsOneWidget);
    });
  });

  testWidgets('Arabic: the shell mirrors the nav order', (tester) async {
    await tester.pumpApp(
      BlocProvider.value(
        value: cubit,
        child: ControlView(rootBuilder: (context, tab) => _TestRoot(tab)),
      ),
      locale: const Locale('ar'),
    );
    expect(
      tester.getCenter(item('الرئيسية')).dx,
      greaterThan(tester.getCenter(item('الملف الشخصي')).dx),
    );
  });
}
