import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/notice/notices.dart';
import 'package:pulse/core/services/connectivity_service.dart';
import 'package:pulse/core/services/location_service.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/places/data/datasource/places_datasource.dart';
import 'package:pulse/features/places/data/enums/place_kind.dart';
import 'package:pulse/features/places/data/model/place_model.dart';
import 'package:pulse/features/places/presentation/screen/add_location_screen.dart';
import 'package:pulse/features/post/data/datasource/post_tags_datasource.dart';
import 'package:pulse/features/post/data/datasource/posts_datasource.dart';
import 'package:pulse/features/post/data/enums/media_type.dart';
import 'package:pulse/features/post/data/enums/mood_kind.dart';
import 'package:pulse/features/post/data/model/feed_page_model.dart';
import 'package:pulse/features/post/data/model/post_media_model.dart';
import 'package:pulse/features/post/data/model/post_model.dart';
import 'package:pulse/features/post/data/model/post_tag_model.dart';
import 'package:pulse/features/post/data/model/tag_person_model.dart';
import 'package:pulse/features/post/presentation/screen/add_edit_post_screen.dart';
import 'package:pulse/features/post/presentation/screen/feeling_screen.dart';
import 'package:pulse/features/post/presentation/screen/tag_in_photo_screen.dart';
import 'package:pulse/features/post/presentation/screen/tag_people_screen.dart';
import 'package:pulse/features/post/presentation/widgets/post_card.dart';
import 'package:pulse/features/post/presentation/widgets/tag_in_photo/tag_photo_canvas.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/shared/content/data/datasource/audience_datasource.dart';
import 'package:pulse/shared/content/data/datasource/media_files_datasource.dart';
import 'package:pulse/shared/content/data/datasource/privacy_datasource.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';
import 'package:pulse/shared/content/data/model/audience_summary_model.dart';
import 'package:pulse/shared/content/data/model/privacy_model.dart';

import '../helpers/png_http_overrides.dart';
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
  late MockMediaFilesDatasource files;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(ContentAudience.public);
    registerFallbackValue(<dynamic>[]);
    registerFallbackValue(MoodKind.feeling);
    registerFallbackValue(const PickedMedia(path: '/x', isVideo: false));
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
    files = MockMediaFilesDatasource();
    when(() => files.listFiles(any())).thenAnswer((_) async => const []);
    when(
      () => files.upload(
        path: any(named: 'path'),
        file: any(named: 'file'),
        contentType: any(named: 'contentType'),
        onBytes: any(named: 'onBytes'),
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
        moodKind: any(named: 'moodKind'),
        moodKey: any(named: 'moodKey'),
        moodText: any(named: 'moodText'),
        tags: any(named: 'tags'),
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
        await getIt.unregister<MediaFilesDatasource>();
        getIt.registerSingleton<MediaFilesDatasource>(files);
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
    expect(find.byType(AddEditPostScreen), findsOneWidget);
  }

  testWidgets('the Create sheet opens New post; X returns to the shell', (
    tester,
  ) async {
    await boot(tester);
    await openNewPost(tester);

    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await settle(tester);
    expect(find.byType(AddEditPostScreen), findsNothing);
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
      expect(find.byType(AddEditPostScreen), findsNothing);
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

  testWidgets(
    'people tagged with spots on a photo and a feeling are sent when the post is shared',
    (tester) async {
      await boot(tester);
      final photo = File('${Directory.systemTemp.path}/pulse_tag_flow.png')
        ..writeAsBytesSync(transparentPng);
      addTearDown(() {
        if (photo.existsSync()) photo.deleteSync();
      });
      when(() => picker.pickMany(limit: any(named: 'limit'))).thenAnswer(
        (_) async => [
          PickedMedia(
            path: photo.path,
            isVideo: false,
            width: 400,
            height: 400,
          ),
        ],
      );
      when(() => picker.describe(any())).thenAnswer(
        (invocation) async =>
            invocation.positionalArguments.first as PickedMedia,
      );
      final tags = getIt<PostTagsDatasource>();
      when(() => tags.searchPeople(any(), limit: any(named: 'limit')))
          .thenAnswer(
            (_) async => const [
              TagPersonModel(
                id: 'u2',
                username: 'omarkh',
                fullName: 'Omar Khaled',
                canTag: true,
              ),
              TagPersonModel(
                id: 'u3',
                username: 'laila',
                fullName: 'Laila Fouad',
                canTag: true,
              ),
              TagPersonModel(
                id: 'u4',
                username: 'sam',
                fullName: 'Sam Private',
                canTag: false,
              ),
            ],
          );
      await openNewPost(tester);
      await tester.enterText(find.byType(TextField), 'Sunset run');
      await tester.pump();
      await tester.tap(find.text(l10nEn.newPostPhotoVideo));
      await settle(tester);

      // S6: two people, one who does not allow tags is dimmed.
      await tester.tap(find.text(l10nEn.newPostTag));
      await settle(tester);
      expect(find.byType(TagPeopleScreen), findsOneWidget);
      expect(find.text(l10nEn.postTagPeopleNoTags), findsOneWidget);
      await tester.tap(find.text('Omar Khaled'));
      await tester.pump();
      await tester.tap(find.text('Laila Fouad'));
      await tester.pump();

      // S7: Omar goes on the photo, Laila stays in the post only.
      await tester.tap(find.text(l10nEn.postTagPeopleInPhoto));
      await settle(tester);
      expect(find.byType(TagInPhotoScreen), findsOneWidget);
      await tester.tapAt(tester.getCenter(find.byType(TagPhotoCanvas)));
      await settle(tester);
      await tester.tap(find.text('@omarkh'));
      await settle(tester);
      expect(find.text('omarkh'), findsOneWidget);
      expect(
        find.text(l10nEn.postTagInPhotoNoSpot('Laila Fouad')),
        findsOneWidget,
      );
      await tester.tap(find.text(l10nEn.postTagPeopleDone));
      await settle(tester);
      expect(find.byType(TagPeopleScreen), findsOneWidget);
      await tester.tap(find.text(l10nEn.postTagPeopleDone));
      await settle(tester);
      expect(find.byType(AddEditPostScreen), findsOneWidget);
      expect(
        find.text(l10nEn.postTagValueTwo('Omar Khaled', 'Laila Fouad')),
        findsOneWidget,
      );

      // S8: a feeling, and the composer previews the headline.
      await tester.tap(find.text(l10nEn.newPostFeeling));
      await settle(tester);
      expect(find.byType(FeelingScreen), findsOneWidget);
      await tester.tap(find.text(l10nEn.postFeelingExcited));
      await settle(tester);
      expect(find.byType(FeelingScreen), findsNothing);
      expect(find.text('🥳feeling excited'), findsOneWidget);

      await tester.tap(find.text(l10nEn.newPostShare));
      await settle(tester);

      final sent =
          verify(
                () => posts.createPost(
                  id: any(named: 'id'),
                  caption: 'Sunset run',
                  location: any(named: 'location'),
                  commentsEnabled: true,
                  visibility: any(named: 'visibility'),
                  media: any(named: 'media'),
                  moodKind: MoodKind.feeling,
                  moodKey: 'excited',
                  moodText: null,
                  tags: captureAny(named: 'tags'),
                ),
              ).captured.single
              as List<PostTagModel>;
      expect(sent.map((t) => t.userId), ['u2', 'u3']);
      expect(sent.first.mediaPosition, 0);
      expect(sent.first.x, closeTo(0.5, 0.05));
      expect(sent.first.y, closeTo(0.5, 0.05));
      expect(sent.last.mediaPosition, isNull);
      expect(find.byType(AddEditPostScreen), findsNothing);
      expect(find.text(l10nEn.newPostShared), findsOneWidget);
    },
  );

  testWidgets(
    'the feed card shows the headline, the badge and labels; you remove your own tag',
    (tester) async {
      final previous = HttpOverrides.current;
      HttpOverrides.global = PngHttpOverrides();
      addTearDown(() => HttpOverrides.global = previous);
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
              caption: 'Race day',
              likeCount: 3,
              commentCount: 1,
              commentsEnabled: false,
              visibility: ContentAudience.public,
              createdAt: DateTime(2026, 10, 14),
              likedByMe: false,
              savedByMe: false,
              media: const [
                PostMediaModel(
                  type: MediaType.image,
                  path: 'someone-else/feed-post/0.jpg',
                  width: 400,
                  height: 400,
                ),
              ],
              moodKind: MoodKind.feeling,
              moodKey: 'happy',
              tagCount: 3,
              iAmTagged: true,
              tags: const [
                PostTagModel(
                  userId: 'u2',
                  username: 'omarkh',
                  fullName: 'Omar Khaled',
                  mediaPosition: 0,
                  x: 0.3,
                  y: 0.5,
                ),
                PostTagModel(
                  userId: 'u3',
                  username: 'laila',
                  fullName: 'Laila Fouad',
                ),
                PostTagModel(
                  userId: 'me',
                  username: 'me',
                  mediaPosition: 0,
                  x: 0.7,
                  y: 0.5,
                ),
              ],
            ),
          ],
        ),
      );
      when(() => posts.signMediaUrls(any())).thenAnswer(
        (_) async => {'someone-else/feed-post/0.jpg': 'https://x.test/0.jpg'},
      );
      await boot(tester);
      final tags = getIt<PostTagsDatasource>();
      when(() => tags.removeMyTag('feed-post')).thenAnswer((_) async => true);

      Finder rich(String text) => find.textContaining(text, findRichText: true);
      expect(
        rich('Nour Adel is feeling 😊happy with Omar Khaled and 2 others'),
        findsOneWidget,
      );

      // The comment button of a post with comments off explains itself.
      await tester.tap(find.bySemanticsLabel(l10nEn.postComment));
      await tester.pump();
      expect(Notices.current.value?.title, l10nEn.postCommentsOffTitle);
      Notices.clear();

      // The badge shows each person where they were tagged; mine is the white card.
      await tester.tap(find.bySemanticsLabel(l10nEn.postTagBadge));
      await tester.pump();
      expect(find.text('omarkh'), findsOneWidget);
      expect(find.text(l10nEn.postTagRemoveLabel), findsOneWidget);

      await tester.tap(find.text(l10nEn.postTagRemoveLabel));
      await settle(tester);
      expect(find.text(l10nEn.postTagRemoveTitle), findsOneWidget);
      await tester.tap(find.text(l10nEn.postTagRemoveConfirm));
      await settle(tester);

      verify(() => tags.removeMyTag('feed-post')).called(1);
      expect(Notices.current.value?.title, l10nEn.postTagRemoved);
      expect(rich('with Omar Khaled and Laila Fouad'), findsOneWidget);
      expect(find.byType(PostCard), findsOneWidget);
      Notices.clear();
    },
  );
}
