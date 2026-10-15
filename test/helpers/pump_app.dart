import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pulse/app/app.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/extensions/l10n.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/core/services/photo_picker_service.dart';
import 'package:pulse/core/theme/app_scale.dart';
import 'package:pulse/core/theme/app_scroll_behavior.dart';
import 'package:pulse/core/theme/app_theme.dart';
import 'package:pulse/core/utils/country_names_delegate.dart';
import 'package:pulse/core/widgets/widgets.dart';
import 'package:pulse/features/activity/data/datasource/activity_datasource.dart';
import 'package:pulse/features/auth/data/datasource/auth_datasource.dart';
import 'package:pulse/features/follow/data/datasource/follows_datasource.dart';
import 'package:pulse/features/follow/domain/use_case/follow_all_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/get_suggested_profiles_use_case.dart';
import 'package:pulse/features/follow/domain/use_case/toggle_follow_use_case.dart';
import 'package:pulse/features/legal/data/datasource/legal_datasource.dart';
import 'package:pulse/features/post/data/datasource/post_actions_datasource.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/model/feed_page_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/profile/data/datasource/interests_datasource.dart';
import 'package:pulse/features/profile/data/datasource/profile_datasource.dart';
import 'package:pulse/features/profile/data/repository/profile_repository.dart';
import 'package:pulse/features/profile/domain/use_case/clear_local_profile_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/complete_signup_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/forget_last_account_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_interests_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_last_account_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/get_signup_draft_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_about_you_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_interests_use_case.dart';
import 'package:pulse/features/profile/domain/use_case/save_profile_details_use_case.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/datasource/story_media_uploader.dart';
import 'package:pulse/shared/content/data/datasource/audience_datasource.dart';
import 'package:pulse/shared/content/data/datasource/content_actions_datasource.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockActivityDatasource extends Mock implements ActivityDatasource {}

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

class MockGetLastAccountUseCase extends Mock implements GetLastAccountUseCase {}

class MockForgetLastAccountUseCase extends Mock
    implements ForgetLastAccountUseCase {}

class MockProfileDatasource extends Mock implements ProfileDatasource {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockInterestsDatasource extends Mock implements InterestsDatasource {}

class MockLegalDatasource extends Mock implements LegalDatasource {}

class MockFollowsDatasource extends Mock implements FollowsDatasource {}

class MockStoriesDatasource extends Mock implements StoriesDatasource {}

class MockPostsDatasource extends Mock implements PostsDatasource {}

class MockPostActionsDatasource extends Mock implements PostActionsDatasource {}

class MockStoryMediaUploader extends Mock implements StoryMediaUploader {}

class MockContentActionsDatasource extends Mock
    implements ContentActionsDatasource {}

class MockAudienceDatasource extends Mock implements AudienceDatasource {}

class MockMediaFilesDatasource extends Mock implements MediaFilesDatasource {}

/// `MaterialApp.builder` for a test that builds its own app: hosts the notice card and keeps it up.
Widget noticeBuilder(BuildContext context, Widget? child) {
  Notices.autoDismiss = false;
  return NoticeHost(child: child!);
}

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

    /// Resolves the named routes the widget pushes.
    RouteFactory? onGenerateRoute,
  }) async {
    Notices.autoDismiss = false;
    await pumpWidget(
      AppScaleScope(
        builder: (context) => MaterialApp(
          builder: (context, child) => MediaQuery.withClampedTextScaling(
            maxScaleFactor: AppScale.maxSystemTextScale,
            child: NoticeHost(child: child!),
          ),
          scrollBehavior: const AppScrollBehavior(),
          theme: AppTheme.light,
          locale: locale,
          onGenerateRoute: onGenerateRoute,
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
  /// A fresh `App` key forces a new Navigator, i.e. a cold start. [configure] runs once the wiring is
  /// ready and before the app starts: replace a service (the camera permissions) there.
  Future<void> bootApp({
    Map<String, Object> prefs = const {},
    AuthDatasource? auth,
    ProfileDatasource? profiles,
    LegalDatasource? legal,
    StoriesDatasource? stories,
    Future<void> Function()? configure,
  }) async {
    await setUpRealWiring(
      prefs: prefs,
      auth: auth,
      profiles: profiles,
      legal: legal,
      stories: stories,
    );
    addTearDown(getIt.reset);
    await configure?.call();
    Notices.autoDismiss = false;
    await pumpWidget(App(key: UniqueKey()));
    await pumpAndSettle();
  }
}

/// The app's real get_it wiring with every Supabase-backed datasource replaced by [auth], [profiles],
/// [legal], [stories] or a mock: tests get signed-out, empty doubles unless they pass their own.
Future<void> setUpRealWiring({
  Map<String, Object> prefs = const {},
  AuthDatasource? auth,
  ProfileDatasource? profiles,
  LegalDatasource? legal,
  StoriesDatasource? stories,
}) async {
  SharedPreferences.resetStatic();
  SharedPreferences.setMockInitialValues(prefs);
  await getIt.reset();
  await configureDependencies();
  // The Supabase adapters need a Supabase session: tests get signed-out mocks unless they pass their own.
  final signedOut = MockAuthDatasource();
  when(() => signedOut.hasSession).thenReturn(false);
  when(() => signedOut.recoverySignals).thenAnswer((_) => const Stream.empty());
  when(() => signedOut.recoveryActive).thenReturn(false);
  when(() => signedOut.sessionEnded).thenAnswer((_) => const Stream.empty());
  await getIt.unregister<ActivityDatasource>();
  await getIt.unregister<AuthDatasource>();
  await getIt.unregister<ProfileDatasource>();
  await getIt.unregister<InterestsDatasource>();
  await getIt.unregister<FollowsDatasource>();
  await getIt.unregister<LegalDatasource>();
  await getIt.unregister<StoriesDatasource>();
  await getIt.unregister<PostsDatasource>();
  await getIt.unregister<PostActionsDatasource>();
  await getIt.unregister<StoryMediaUploader>();
  await getIt.unregister<ContentActionsDatasource>();
  await getIt.unregister<MediaFilesDatasource>();
  await getIt.unregister<AudienceDatasource>();
  getIt.registerSingleton<ActivityDatasource>(MockActivityDatasource());
  getIt.registerSingleton<AuthDatasource>(auth ?? signedOut);
  getIt.registerSingleton<ProfileDatasource>(
    profiles ?? MockProfileDatasource(),
  );
  getIt.registerSingleton<InterestsDatasource>(MockInterestsDatasource());
  getIt.registerSingleton<FollowsDatasource>(MockFollowsDatasource());
  getIt.registerSingleton<LegalDatasource>(legal ?? MockLegalDatasource());
  // Home's story rail loads on open: an empty rail.
  final emptyRail = MockStoriesDatasource();
  when(() => emptyRail.getStoryRail(limit: any(named: 'limit')))
      .thenAnswer((_) async => []);
  getIt.registerSingleton<StoriesDatasource>(stories ?? emptyRail);
  // Home loads its feed on open: one plain post (the empty page floats forever and would never settle).
  final emptyFeed = MockPostsDatasource();
  stubOnePostFeed(emptyFeed);
  getIt.registerSingleton<PostsDatasource>(emptyFeed);
  getIt.registerSingleton<PostActionsDatasource>(MockPostActionsDatasource());
  getIt.registerSingleton<StoryMediaUploader>(MockStoryMediaUploader());
  getIt.registerSingleton<ContentActionsDatasource>(
    MockContentActionsDatasource(),
  );
  getIt.registerSingleton<MediaFilesDatasource>(MockMediaFilesDatasource());
  getIt.registerSingleton<AudienceDatasource>(MockAudienceDatasource());
}

/// Makes [posts] answer a feed of one plain post: Home loads its feed on open, and its empty page floats
/// forever, so a test that settles needs a post to show.
void stubOnePostFeed(PostsDatasource posts) {
  when(
    () => posts.getHomeFeed(
      limit: any(named: 'limit'),
      beforeCreated: any(named: 'beforeCreated'),
      beforeId: any(named: 'beforeId'),
    ),
  ).thenAnswer(
    (_) async => FeedPageModel(
      posts: [
        PostModel(
          id: 'feed-post',
          authorId: 'someone-else',
          username: 'nour.adel',
          fullName: 'Nour Adel',
          caption: 'Hello',
          likeCount: 3,
          commentCount: 1,
          commentsEnabled: true,
          visibility: ContentAudience.public,
          createdAt: DateTime(2026, 10, 14),
          likedByMe: false,
          savedByMe: false,
          media: const [],
        ),
      ],
    ),
  );
}
