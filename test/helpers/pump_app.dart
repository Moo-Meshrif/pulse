import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app/app.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/extensions/l10n.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/core/theme/app_scale.dart';
import 'package:pulse/core/theme/app_scroll_behavior.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final l10nEn = lookupAppLocalizations(const Locale('en'));
final l10nAr = lookupAppLocalizations(const Locale('ar'));

/// A phone-like test view: [size] in logical px (1 dp = 1 px), notch-style insets, optional text scale.
void setUpView(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
  Locale? deviceLocale,
}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 47, bottom: 34);
  tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 34);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  if (deviceLocale != null) {
    tester.platformDispatcher.localesTestValue = [deviceLocale];
  }
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
}

extension PumpApp on WidgetTester {
  /// A widget inside the app theme, localization delegates and a [locale].
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = const Locale('en'),
  }) async {
    await pumpWidget(
      AppScaleScope(
        builder: (context) => MaterialApp(
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: AppScale.maxSystemTextScale,
            child: child!,
          ),
          scrollBehavior: const AppScrollBehavior(),
          theme: AppTheme.light,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
    await pumpAndSettle();
  }

  /// The whole app with its real wiring (router, get_it, shared_preferences with [prefs]).
  /// A fresh `App` key forces a new Navigator, i.e. a cold start.
  Future<void> bootApp({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(prefs);
    await getIt.reset();
    await configureDependencies();
    addTearDown(getIt.reset);
    await pumpWidget(App(key: UniqueKey()));
    await pumpAndSettle();
  }
}
