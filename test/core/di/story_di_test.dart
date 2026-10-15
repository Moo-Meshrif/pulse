import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/di/injection.dart';
import 'package:pulse/core/services/camera_device.dart';
import 'package:pulse/core/services/camera_permission_service.dart';
import 'package:pulse/core/services/gallery_service.dart';
import 'package:pulse/core/services/media_picker_service.dart';
import 'package:pulse/core/services/video_thumbnail_service.dart';
import 'package:pulse/core/state/camera_permission_cubit.dart';
import 'package:pulse/features/story/data/datasource/stories_datasource.dart';
import 'package:pulse/features/story/data/datasource/story_camera_hint_datasource.dart';
import 'package:pulse/features/story/data/enums/audience_list.dart';
import 'package:pulse/features/story/data/enums/story_media_type.dart';
import 'package:pulse/features/story/data/repository/story_upload_repository.dart';
import 'package:pulse/features/story/domain/entity/captured_story_media.dart';
import 'package:pulse/features/story/domain/use_case/get_story_rail_use_case.dart';
import 'package:pulse/features/story/domain/use_case/retry_story_upload_use_case.dart';
import 'package:pulse/features/story/presentation/cubit/audience_list_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_audience_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_camera_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_edit_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewer_cubit.dart';
import 'package:pulse/features/story/presentation/cubit/story_viewers_cubit.dart';
import 'package:pulse/shared/content/data/enums/content_audience.dart';

import '../../helpers/pump_app.dart';

/// Everything the story feature asks get_it for resolves through the generated config (a missing
/// `build_runner` run, or a dependency nobody registered, fails here and not at the first tap).
void main() {
  setUp(() async {
    await setUpRealWiring();
    addTearDown(getIt.reset);
  });

  test('the story Cubits resolve', () {
    expect(getIt<StoryViewerCubit>(), isA<StoryViewerCubit>());
    expect(getIt<StoryViewersCubit>(), isA<StoryViewersCubit>());
    expect(getIt<StoryCameraCubit>(), isA<StoryCameraCubit>());
    expect(getIt<CameraPermissionCubit>(), isA<CameraPermissionCubit>());
    expect(
      getIt<StoryAudienceCubit>(
        param1: 's1',
        param2: ContentAudience.followers,
      ),
      isA<StoryAudienceCubit>(),
    );
    expect(
      getIt<AudienceListCubit>(param1: AudienceList.closeFriends),
      isA<AudienceListCubit>(),
    );
    expect(
      getIt<StoryEditCubit>(
        param1: const CapturedStoryMedia(
          path: '/p.jpg',
          type: StoryMediaType.image,
        ),
      ),
      isA<StoryEditCubit>(),
    );
  });

  test('the use cases other features call resolve (the rest of the story feature talks to its datasource)', () {
    expect(getIt<GetStoryRailUseCase>(), isNotNull);
    expect(getIt<RetryStoryUploadUseCase>(), isNotNull);
  });

  test('the services behind them resolve; the upload is one shared state', () {
    expect(getIt<StoriesDatasource>(), isNotNull);
    expect(getIt<CameraDevice>(), isNotNull);
    expect(getIt<CameraPermissionService>(), isNotNull);
    expect(getIt<MediaPickerService>(), isNotNull);
    expect(getIt<VideoThumbnailService>(), isNotNull);
    expect(getIt<GalleryService>(), isNotNull);
    expect(getIt<StoryCameraHintDatasource>(), isNotNull);
    // Home's rail and the edit screen's Share talk to the same upload.
    expect(
      identical(getIt<StoryUploadRepository>(), getIt<StoryUploadRepository>()),
      isTrue,
    );
  });
}
