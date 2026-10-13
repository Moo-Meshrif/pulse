import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:mocktail/mocktail.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/enums/permission_access.dart';
import 'package:pulse/core/services/camera_device.dart';
import 'package:pulse/core/services/camera_permission_service.dart';
import 'package:pulse/features/control/presentation/screen/control_screen.dart';
import 'package:pulse/features/profile/data/enums/signup_step.dart';
import 'package:pulse/features/profile/data/model/profile_model.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/new_story_model.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/data/model/story_rail_item_model.dart';
import 'package:pulse/features/story/data/model/story_viewer_model.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/entity/story_upload_status.dart';
import 'package:pulse/features/story/domain/entity/story_viewer_args.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/story/presentation/screen/story_camera_screen.dart';
import 'package:pulse/features/story/presentation/screen/story_edit_screen.dart';
import 'package:pulse/features/story/presentation/screen/story_viewer_screen.dart';

import '../helpers/pump_app.dart';

/// A stories datasource whose viewers list is fixed; everything else is stubbed per test.
class _Stories extends MockStoriesDatasource {
  @override
  Future<List<StoryViewerModel>> getViewers(
    String storyId, {
    required int limit,
    DateTime? before,
  }) async => [
    StoryViewerModel(
      userId: 'u1',
      username: 'sara',
      fullName: 'Sara Ali',
      viewedAt: DateTime(2026, 10, 13),
      liked: true,
      total: 2,
    ),
  ];
}

class _Permissions extends Mock implements CameraPermissionService {}

class _Device extends Mock implements CameraDevice {}

/// The upload as the app sees it: records what was posted, and lets the test drive the status.
class _Uploads implements StoryUploadRepository {
  final posted = <NewStoryModel>[];
  final changes = StreamController<StoryUploadStatus>.broadcast();
  StoryUploadStatus current = const StoryUploadIdle();

  @override
  Stream<StoryUploadStatus> get status async* {
    yield current;
    yield* changes.stream;
  }

  @override
  bool enqueue(NewStoryModel story) {
    posted.add(story);
    return true;
  }

  @override
  void retry() {}

  void emit(StoryUploadStatus status) {
    current = status;
    changes.add(status);
  }
}

/// The whole story flow through the real router, DI and cubits over mocked datasources: Home's rail opens
/// the viewer and the camera, a capture is edited and shared, and the rail shows the upload.
void main() {
  late MockAuthDatasource auth;
  late MockProfileDatasource profiles;
  late _Stories stories;
  late _Permissions permissions;
  late _Device device;
  late _Uploads uploads;
  var rail = <StoryRailItemModel>[];

  setUpAll(() {
    registerFallbackValue(CameraLens.back);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    rail = const [
      StoryRailItemModel(
        authorId: 'nour',
        username: 'nour.adel',
        fullName: 'Nour Adel',
        isMe: false,
        storyCount: 1,
        allSeen: false,
      ),
    ];
    auth = MockAuthDatasource();
    profiles = MockProfileDatasource();
    stories = _Stories();
    when(() => stories.railChanges)
        .thenAnswer((_) => const Stream<void>.empty());
    permissions = _Permissions();
    device = _Device();
    uploads = _Uploads();
    when(() => device.close()).thenAnswer((_) async {});
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
    when(() => stories.getStoryRail(limit: any(named: 'limit')))
        .thenAnswer((_) async => rail);
    when(() => stories.getAuthorStories(any())).thenAnswer(
      (i) async => [
        StoryModel(
          id: '${i.positionalArguments.first}-1',
          type: StoryMediaType.image,
          mediaUrl: 'https://test.local/s.jpg',
          seenByMe: true,
          likedByMe: false,
          viewCount: 2,
        ),
      ],
    );
    when(() => permissions.camera())
        .thenAnswer((_) async => PermissionAccess.denied);
    when(() => permissions.microphone())
        .thenAnswer((_) async => PermissionAccess.denied);
  });

  Future<void> boot(WidgetTester tester) async {
    setUpView(tester);
    await tester.bootApp(
      prefs: {'onboarding_seen': true},
      auth: auth,
      profiles: profiles,
      stories: stories,
      configure: () async {
        // No real HTTP client: the one the app builds would be made over the test's image overrides.
        await getIt.unregister<http.Client>();
        getIt.registerSingleton<http.Client>(
          http_testing.MockClient((_) async => http.Response('', 200)),
        );
        await getIt.unregister<CameraPermissionService>();
        getIt.registerSingleton<CameraPermissionService>(permissions);
        await getIt.unregister<CameraDevice>();
        getIt.registerFactory<CameraDevice>(() => device);
        await getIt.unregister<StoryUploadRepository>();
        getIt.registerSingleton<StoryUploadRepository>(uploads);
      },
    );
    // Take the app down with the test: its timers must not outlive it.
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    expect(find.byType(ControlScreen), findsOneWidget);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  void allowCamera() {
    when(() => permissions.camera())
        .thenAnswer((_) async => PermissionAccess.granted);
    when(() => permissions.microphone())
        .thenAnswer((_) async => PermissionAccess.granted);
    when(
      () => device.open(
        lens: any(named: 'lens'),
        withAudio: any(named: 'withAudio'),
      ),
    ).thenAnswer((_) async {});
    when(() => device.close()).thenAnswer((_) async {});
    when(() => device.hasFlash).thenReturn(true);
    when(() => device.preview())
        .thenReturn(const ColoredBox(color: Colors.grey));
    when(() => device.takePhoto()).thenAnswer(
      (_) async =>
          const CapturedFile(path: '/cap/p.jpg', width: 1080, height: 1920),
    );
  }

  /// Opens a route the way the app does: pushed on the root Navigator, over the shell.
  void go(String route, {Object? arguments}) =>
      getIt<GlobalKey<NavigatorState>>().currentState!.pushNamed<Object?>(
        route,
        arguments: arguments,
      );

  testWidgets('a story opens over the shell with the person shown; X returns', (
    tester,
  ) async {
    await boot(tester);
    go(
      AppRoutes.storyOf('nour'),
      arguments: const StoryViewerArgs(
        person: StoryRailItemEntity(
          authorId: 'nour',
          username: 'nour.adel',
          isMe: false,
          storyCount: 1,
          allSeen: false,
        ),
      ),
    );
    await settle(tester);
    expect(find.byType(StoryViewerScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(l10nEn.close));
    await settle(tester);
    expect(find.byType(StoryViewerScreen), findsNothing);
    expect(find.byType(ControlScreen), findsOneWidget);
  });

  testWidgets('your own story opens the viewer and its viewers', (
    tester,
  ) async {
    rail = const [
      StoryRailItemModel(
        authorId: 'me',
        username: 'me.user',
        fullName: 'Me',
        isMe: true,
        storyCount: 1,
        allSeen: true,
      ),
    ];
    await boot(tester);
    go(AppRoutes.storyOf('me'));
    await settle(tester);
    expect(find.byType(StoryViewerScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(l10nEn.storyViewers(2)));
    await settle(tester);
    expect(find.text('Sara Ali'), findsOneWidget);
  });

  testWidgets('the camera opens on the permission panel; Not now returns', (
    tester,
  ) async {
    await boot(tester);
    go(AppRoutes.createStory);
    await settle(tester);
    expect(find.byType(StoryCameraScreen), findsOneWidget);
    expect(find.text(l10nEn.permAllowTitle), findsOneWidget);

    await tester.tap(find.text(l10nEn.permNotNow));
    await settle(tester);
    expect(find.byType(StoryCameraScreen), findsNothing);
    expect(find.byType(ControlScreen), findsOneWidget);
  });

  testWidgets('camera -> edit -> Share hands the story to the upload and goes '
      'back', (tester) async {
    allowCamera();
    await boot(tester);
    go(AppRoutes.createStory);
    await settle(tester);
    expect(find.text(l10nEn.storyCameraTitle), findsOneWidget);

    // A tap on the shutter takes a photo and opens the edit screen.
    await tester.tap(find.bySemanticsLabel(l10nEn.storyShutter));
    await settle(tester);
    expect(find.byType(StoryEditScreen), findsOneWidget);

    await tester.tap(find.text(l10nEn.storyShare));
    await settle(tester);
    expect(uploads.posted, hasLength(1));
    expect(uploads.posted.single.filePath, '/cap/p.jpg');
    expect(uploads.posted.single.type, StoryMediaType.image);
    expect(find.byType(StoryEditScreen), findsNothing);
    expect(find.byType(StoryCameraScreen), findsNothing);
    expect(find.byType(ControlScreen), findsOneWidget);
  });
}
