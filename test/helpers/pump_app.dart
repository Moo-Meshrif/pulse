import 'package:pulse/core/utils/country_names_delegate.dart';
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
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/features/follow/data/datasource/follows_datasource.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';
import 'package:pulse/features/profile/data/datasource/profile_datasource.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/use_case/clear_local_profile_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_draft_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/complete_signup_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_interests_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/get_suggested_profiles_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_interests_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/follow_all_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_about_you_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_profile_details_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthDatasource extends Mock implements AuthDatasource {}

class MockSaveAboutYouUseCase extends Mock implements SaveAboutYouUseCase {}

class MockSaveProfileDetailsUseCase extends Mock
    implements SaveProfileDetailsUseCase {}

class MockGetInterestsUseCase extends Mock implements GetInterestsUseCase {}

class MockSaveInterestsUseCase extends Mock implements SaveInterestsUseCase {}

class MockGetSuggestedProfilesUseCase extends Mock
    implements GetSuggestedProfilesUseCase {}

class MockToggleFollowUseCase extends Mock implements ToggleFollowUseCase {}

class MockFollowAllUseCase extends Mock implements FollowAllUseCase {}

class MockCompleteSignupUseCase extends Mock implements CompleteSignupUseCase {}

class MockClearLocalProfileUseCase extends Mock
    implements ClearLocalProfileUseCase {}

class MockGetSignupDraftUseCase extends Mock implements GetSignupDraftUseCase {}

class MockPhotoPickerService extends Mock implements PhotoPickerService {}

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
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            CountryNamesDelegate(),
          ],
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
    when(() => signedOut.passwordRecovery)
        .thenAnswer((_) => const Stream.empty());
    await getIt.unregister<AuthDatasource>();
    await getIt.unregister<ProfileDatasource>();
    await getIt.unregister<InterestsDatasource>();
    await getIt.unregister<FollowsDatasource>();
    getIt.registerSingleton<AuthDatasource>(auth ?? signedOut);
    getIt.registerSingleton<ProfileDatasource>(
      profiles ?? MockProfileDatasource(),
    );
    getIt.registerSingleton<InterestsDatasource>(MockInterestsDatasource());
    getIt.registerSingleton<FollowsDatasource>(MockFollowsDatasource());
    addTearDown(getIt.reset);
    await pumpWidget(App(key: UniqueKey()));
    await pumpAndSettle();
  }
}
