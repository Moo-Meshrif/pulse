import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/app/app.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/extensions/l10n.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/core/theme/app_scale.dart';
import 'package:pulse/core/theme/app_scroll_behavior.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/profile/data/datasource/follows_datasource.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';
import 'package:pulse/features/profile/data/datasource/profile_datasource.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

class MockProfileDatasource extends Mock implements ProfileDatasource {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockInterestsDatasource extends Mock implements InterestsDatasource {}

class MockFollowsDatasource extends Mock implements FollowsDatasource {}

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

/// A widget test at the 390 x 844 design frame (scale factor 1), so spec values compare exactly.
void testView(
  String description,
  Future<void> Function(WidgetTester tester) body,
) => testWidgets(description, (tester) async {
  setUpView(tester);
  await body(tester);
});

extension PumpApp on WidgetTester {
  /// A widget inside the app theme, localization delegates and a [locale].
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = const Locale('en'),

    /// Pass false for a widget with an endless animation (a spinner).
    bool settle = true,
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
    if (settle) {
      await pumpAndSettle();
    } else {
      await pump();
    }
  }

  /// The whole app with its real wiring (router, get_it, shared_preferences with [prefs]).
  /// A fresh `App` key forces a new Navigator, i.e. a cold start.
  Future<void> bootApp({
    Map<String, Object> prefs = const {},
    AuthDatasource? auth,
    ProfileDatasource? profiles,
  }) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues(prefs);
    await getIt.reset();
    await configureDependencies();
    // The Supabase adapters need a Supabase session: tests get signed-out mocks unless they pass their own.
    final signedOut = MockAuthDatasource();
    when(() => signedOut.hasSession).thenReturn(false);
    await getIt.unregister<AuthDatasource>();
    await getIt.unregister<ProfileDatasource>();
    getIt.registerSingleton<AuthDatasource>(auth ?? signedOut);
    getIt.registerSingleton<ProfileDatasource>(
      profiles ?? MockProfileDatasource(),
    );
    addTearDown(getIt.reset);
    await pumpWidget(App(key: UniqueKey()));
    await pumpAndSettle();
  }
}
