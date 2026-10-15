import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/core/services/location_service.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/places/data/datasource/places_datasource.dart';
import 'package:pulse/features/places/data/enums/place_kind.dart';
import 'package:pulse/features/places/data/model/place_model.dart';
import 'package:pulse/features/places/presentation/screen/add_location_screen.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/presentation/screen/new_post_screen.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/shared/content/data/datasource/audience_datasource.dart';
import 'package:pulse/shared/content/data/datasource/privacy_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/model/audience_summary_model.dart';
import 'package:pulse/shared/content/data/model/privacy_model.dart';

import '../helpers/pump_app.dart';

class _Posts extends Mock implements PostsDatasource {}

class _Privacy extends Mock implements PrivacyDatasource {}

class _Places extends Mock implements PlacesDatasource {}

class _Location extends Mock implements LocationService {}

class _Picker extends Mock implements MediaPickerService {}

class _Connectivity extends Mock implements ConnectivityService {}

class _Thumbnails extends Mock implements VideoThumbnailService {}

/// The whole post flow through the real router, DI and cubits over mocked datasources: the nav bar's
/// "+" opens the Create sheet, Post opens New post, the audience and the place are chosen in their
/// own screens, and Share creates the post and closes with the notice.
void main() {
  late MockAuthDatasource auth;
  late MockProfileDatasource profiles;
  late MockAudienceDatasource audience;
  late _Posts posts;
  late _Privacy privacy;
  late _Places places;
  late _Location location;
  late _Picker picker;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(ContentAudience.public);
    registerFallbackValue(<dynamic>[]);
  });

  setUp(() {
    auth = MockAuthDatasource();
    profiles = MockProfileDatasource();
    audience = MockAudienceDatasource();
    posts = _Posts();
    stubOnePostFeed(posts);
    privacy = _Privacy();
    places = _Places();
    location = _Location();
    picker = _Picker();
    when(() => auth.hasSession).thenReturn(true);
    when(() => auth.currentEmail).thenReturn(null);
    when(() => auth.recoveryActive).thenReturn(false);
    when(() => auth.recoverySignals).thenAnswer((_) => const Stream.empty());
    when(() => auth.sessionEnded).thenAnswer((_) => const Stream.empty());
    when(() => profiles.currentUserId).thenReturn('me');
    when(() => profiles.getProfile()).thenAnswer(
      (_) async =>
          const ProfileModel(id: 'me', signupStep: SignupStep.complete),
    );
    when(() => privacy.getPrivacy()).thenAnswer(
      (_) async => const PrivacyModel(
        isPrivate: false,
        defaultAudience: ContentAudience.public,
      ),
    );
    when(() => audience.getSummary()).thenAnswer(
      (_) async =>
          const AudienceSummaryModel(followers: 12, closeFriends: 3, hidden: 0),
    );
    // No location permission, no "Not now" yet: the Add location screen opens on the primer, so the
    // flow picks a place from a search instead of the device position.
    when(() => location.permission())
        .thenAnswer((_) async => PermissionAccess.denied);
    when(
      () => places.searchPlaces(
        any(),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer(
      (_) async => const [
        PlaceModel(
          name: 'Zamalek',
          subtitle: 'Cairo, Egypt',
          kind: PlaceKind.neighborhood,
        ),
      ],
    );
    when(() => posts.currentUserId).thenReturn('me');
    when(() => posts.listFiles(any())).thenAnswer((_) async => const []);
    when(
      () => posts.uploadFile(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => posts.createPost(
        id: any(named: 'id'),
        caption: any(named: 'caption'),
        location: any(named: 'location'),
        commentsEnabled: any(named: 'commentsEnabled'),
        visibility: any(named: 'visibility'),
        media: any(named: 'media'),
      ),
    ).thenAnswer((_) async {});
  });

  Future<void> boot(WidgetTester tester) async {
    setUpView(tester);
    final connectivity = _Connectivity();
    when(connectivity.isOffline).thenAnswer((_) async => false);
    when(() => connectivity.connectionHints)
        .thenAnswer((_) => const Stream<void>.empty());
    await tester.bootApp(
      prefs: {'onboarding_seen': true},
      auth: auth,
      profiles: profiles,
      configure: () async {
        await getIt.unregister<http.Client>();
        getIt.registerSingleton<http.Client>(
          http_testing.MockClient((_) async => http.Response('', 200)),
        );
        await getIt.unregister<PostsDatasource>();
        getIt.registerSingleton<PostsDatasource>(posts);
        await getIt.unregister<PrivacyDatasource>();
        getIt.registerSingleton<PrivacyDatasource>(privacy);
        await getIt.unregister<AudienceDatasource>();
        getIt.registerSingleton<AudienceDatasource>(audience);
        await getIt.unregister<PlacesDatasource>();
        getIt.registerSingleton<PlacesDatasource>(places);
        await getIt.unregister<LocationService>();
        getIt.registerSingleton<LocationService>(location);
        await getIt.unregister<MediaPickerService>();
        getIt.registerSingleton<MediaPickerService>(picker);
        await getIt.unregister<ConnectivityService>();
        getIt.registerSingleton<ConnectivityService>(connectivity);
        await getIt.unregister<VideoThumbnailService>();
        getIt.registerSingleton<VideoThumbnailService>(_Thumbnails());
      },
    );
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    expect(find.byType(ControlScreen), findsOneWidget);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> openNewPost(WidgetTester tester) async {
    await tester.tap(find.bySemanticsLabel(l10nEn.navCreate));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(RegExp('^${l10nEn.createPost}\\.')));
    await settle(tester);
    expect(find.byType(NewPostScreen), findsOneWidget);
  }

  testWidgets('the Create sheet opens New post; X returns to the shell', (
    tester,
  ) async {
    await boot(tester);
    await openNewPost(tester);

    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await settle(tester);
    expect(find.byType(NewPostScreen), findsNothing);
    expect(find.byType(ControlScreen), findsOneWidget);
  });

  testWidgets(
    'audience and place chosen in their screens are sent when the post is shared',
    (tester) async {
      await boot(tester);
      await openNewPost(tester);

      await tester.enterText(find.byType(TextField), 'Hello Cairo');
      await tester.pump();

      // S4: the chip opens the picker; Followers, then Done.
      await tester.tap(
        find.bySemanticsLabel(
          l10nEn.newPostVisibilityLabel(l10nEn.postAudiencePublic),
        ),
      );
      await settle(tester);
      await tester.tap(
        find.bySemanticsLabel(RegExp('^${l10nEn.postAudienceFollowers}')),
      );
      await tester.pump();
      await tester.tap(find.text(l10nEn.postVisibilityDone));
      await settle(tester);
      expect(
        find.bySemanticsLabel(
          l10nEn.newPostVisibilityLabel(l10nEn.postAudienceFollowers),
        ),
        findsOneWidget,
      );

      // S3: Location row opens the screen; a search result goes back as the row's value.
      await tester.tap(find.text(l10nEn.newPostLocation));
      await settle(tester);
      expect(find.byType(AddLocationScreen), findsOneWidget);
      await tester.tap(find.text(l10nEn.locationNotNow));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'zam');
      await tester.pump(const Duration(milliseconds: 400));
      await settle(tester);
      await tester.tap(find.textContaining('Zamalek'));
      await settle(tester);
      expect(find.byType(AddLocationScreen), findsNothing);
      expect(find.text('Zamalek, Cairo'), findsOneWidget);

      await tester.tap(find.text(l10nEn.newPostShare));
      await settle(tester);

      verify(
        () => posts.createPost(
          id: any(named: 'id'),
          caption: 'Hello Cairo',
          location: 'Zamalek, Cairo',
          commentsEnabled: true,
          visibility: ContentAudience.followers,
          media: any(named: 'media'),
        ),
      ).called(1);
      expect(find.byType(NewPostScreen), findsNothing);
      expect(find.text(l10nEn.newPostShared), findsOneWidget);

      // Home, under New post, loaded its feed on open and loads it again for the new post.
      verify(
        () => posts.getHomeFeed(
          limit: any(named: 'limit'),
          beforeCreated: any(named: 'beforeCreated'),
          beforeId: any(named: 'beforeId'),
        ),
      ).called(2);
    },
  );
}
