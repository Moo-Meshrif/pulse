import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/core/router/app_router.dart';
import 'package:pulse/core/router/app_routes.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/model/story_model.dart';
import 'package:pulse/features/story/domain/entity/story_rail_item_entity.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer_cubit.dart';
import 'package:pulse/features/story/domain/entity/story_viewer_args.dart';
import 'package:pulse/features/story/presentation/screen/story_viewer_screen.dart';
import 'package:pulse/features/story/presentation/utils/story_page_route.dart';
import 'package:pulse/features/story/presentation/view/story_viewer_view.dart';

import '../../../../helpers/png_http_overrides.dart';
import '../../../../helpers/pump_app.dart';

class _Rail implements GetStoryRailUseCase {
  @override
  Future<List<StoryRailItemEntity>> call() async => const [
    StoryRailItemEntity(
      authorId: 'a',
      username: 'nour',
      isMe: false,
      storyCount: 1,
      allSeen: false,
    ),
  ];
}

class _Stories extends Fake implements StoriesDatasource {
  @override
  Future<List<StoryModel>> getAuthorStories(String authorId) async => const [
    StoryModel(
      id: 'a1',
      type: StoryMediaType.image,
      seenByMe: true,
      mediaUrl: 'https://test.local/a1.jpg',
    ),
  ];

  @override
  Future<void> markViewed(String storyId) async {}
}

class _Gallery extends Fake implements GalleryService {}

void main() {
  HttpOverrides? previous;
  setUpAll(() {
    previous = HttpOverrides.current;
    HttpOverrides.global = PngHttpOverrides();
  });
  tearDownAll(() => HttpOverrides.global = previous);

  setUp(() async {
    await getIt.reset();
    getIt.registerFactory<StoryViewerCubit>(
      () => StoryViewerCubit(_Rail(), _Stories(), _Gallery()),
    );
  });

  tearDown(getIt.reset);

  test('/story/:authorId resolves to the viewer with that author', () {
    final route = AppRouter.onGenerateRoute(
      RouteSettings(name: AppRoutes.storyOf('abc-123')),
    );
    expect(route, isA<StoryPageRoute<dynamic>>());
    expect(route.settings.name, '/story/abc-123');
    expect((route as StoryPageRoute<dynamic>).origin, isNull);
  });

  test('the rail arguments give the route its origin', () {
    final route = AppRouter.onGenerateRoute(
      RouteSettings(
        name: AppRoutes.storyOf('abc-123'),
        arguments: const StoryViewerArgs(origin: Offset(40, 120)),
      ),
    ) as StoryPageRoute<dynamic>;
    expect(route.origin, const Offset(40, 120));
  });

  testWidgets('the viewer closes itself when the last story is passed', (
    tester,
  ) async {
    setUpView(tester);
    var popped = false;
    await tester.pumpApp(const Scaffold(body: Text('home')), settle: false);
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const StoryViewerScreen(authorId: 'a'),
          ),
        )
        .then((_) => popped = true);
    await tester.pump(); // starts the route transition
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(StoryViewerView), findsOneWidget);

    // The only story: a tap on the right ends the viewer.
    await tester.tapAt(const Offset(300, 400));
    await tester.pump(); // starts the route transition back
    await tester.pump(const Duration(milliseconds: 500));
    expect(popped, isTrue);
  });
}
