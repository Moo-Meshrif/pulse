// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter/widgets.dart' as _i718;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../app/app_module.dart' as _i431;
import '../../features/activity/data/datasource/activity_datasource.dart'
    as _i568;
import '../../features/activity/domain/use_case/get_unread_activity_count_use_case.dart'
    as _i575;
import '../../features/auth/data/datasource/auth_datasource.dart' as _i43;
import '../../features/auth/data/datasource/password_recovery_tracker.dart'
    as _i236;
import '../../features/auth/domain/use_case/is_recovery_pending_use_case.dart'
    as _i730;
import '../../features/auth/domain/use_case/is_signed_in_use_case.dart'
    as _i710;
import '../../features/auth/domain/use_case/sign_out_use_case.dart' as _i1036;
import '../../features/auth/domain/use_case/verify_password_use_case.dart'
    as _i602;
import '../../features/auth/domain/use_case/watch_password_recovery_use_case.dart'
    as _i121;
import '../../features/auth/domain/use_case/watch_session_ended_use_case.dart'
    as _i793;
import '../../features/auth/presentation/cubit/forgot_password/forgot_password_cubit.dart'
    as _i344;
import '../../features/auth/presentation/cubit/reset_password/reset_password_cubit.dart'
    as _i260;
import '../../features/auth/presentation/cubit/sign_in/sign_in_cubit.dart'
    as _i302;
import '../../features/auth/presentation/cubit/sign_up/sign_up_cubit.dart'
    as _i782;
import '../../features/control/presentation/cubit/control_cubit.dart' as _i598;
import '../../features/follow/data/datasource/follows_datasource.dart'
    as _i1001;
import '../../features/follow/domain/use_case/follow_all_use_case.dart'
    as _i740;
import '../../features/follow/domain/use_case/get_follow_request_count_use_case.dart'
    as _i608;
import '../../features/follow/domain/use_case/get_follow_requests_use_case.dart'
    as _i171;
import '../../features/follow/domain/use_case/get_follow_status_use_case.dart'
    as _i689;
import '../../features/follow/domain/use_case/get_suggested_profiles_use_case.dart'
    as _i250;
import '../../features/follow/domain/use_case/respond_to_follow_request_use_case.dart'
    as _i534;
import '../../features/follow/domain/use_case/toggle_follow_use_case.dart'
    as _i130;
import '../../features/home/presentation/cubit/bell_dot/bell_dot_cubit.dart'
    as _i639;
import '../../features/home/presentation/cubit/feed/feed_cubit.dart' as _i592;
import '../../features/home/presentation/cubit/post_publish/post_line_cubit.dart'
    as _i803;
import '../../features/home/presentation/cubit/post_publish/post_publish_cubit.dart'
    as _i613;
import '../../features/home/presentation/cubit/story_rail/story_rail_cubit.dart'
    as _i308;
import '../../features/legal/data/datasource/legal_datasource.dart' as _i604;
import '../../features/legal/presentation/cubit/legal_cubit.dart' as _i736;
import '../../features/onboarding/data/datasource/onboarding_datasource.dart'
    as _i834;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
import '../../features/places/data/datasource/location_primer_datasource.dart'
    as _i234;
import '../../features/places/data/datasource/places_datasource.dart' as _i438;
import '../../features/places/data/datasource/recent_places_datasource.dart'
    as _i366;
import '../../features/places/data/repository/places_repository.dart' as _i974;
import '../../features/places/presentation/cubit/add_location_cubit.dart'
    as _i490;
import '../../features/post/data/datasource/comments_datasource.dart' as _i781;
import '../../features/post/data/datasource/comments_local_datasource.dart'
    as _i603;
import '../../features/post/data/datasource/feed_local_datasource.dart' as _i35;
import '../../features/post/data/datasource/post_actions_datasource.dart'
    as _i512;
import '../../features/post/data/datasource/post_draft_datasource.dart'
    as _i1007;
import '../../features/post/data/datasource/post_likes_datasource.dart'
    as _i634;
import '../../features/post/data/datasource/post_tags_datasource.dart' as _i518;
import '../../features/post/data/datasource/posts_datasource.dart' as _i141;
import '../../features/post/data/datasource/visibility_notice_datasource.dart'
    as _i722;
import '../../features/post/data/repository/feed_repository.dart' as _i280;
import '../../features/post/data/repository/post_draft_repository.dart'
    as _i1017;
import '../../features/post/data/repository/post_publishing_repository.dart'
    as _i845;
import '../../features/post/data/repository/post_repository.dart' as _i699;
import '../../features/post/domain/entity/post_entity.dart' as _i570;
import '../../features/post/domain/use_case/get_home_feed_use_case.dart'
    as _i281;
import '../../features/post/domain/use_case/get_liked_by_previews_use_case.dart'
    as _i1044;
import '../../features/post/domain/use_case/get_posts_by_ids_use_case.dart'
    as _i1014;
import '../../features/post/domain/use_case/has_open_post_draft_use_case.dart'
    as _i371;
import '../../features/post/domain/use_case/resume_shared_posts_use_case.dart'
    as _i401;
import '../../features/post/domain/use_case/save_home_feed_use_case.dart'
    as _i341;
import '../../features/post/domain/use_case/sign_post_media_urls_use_case.dart'
    as _i599;
import '../../features/post/presentation/cubit/add_edit_post/add_edit_post_cubit.dart'
    as _i80;
import '../../features/post/presentation/cubit/comment_mentions/comment_mentions_cubit.dart'
    as _i356;
import '../../features/post/presentation/cubit/comments/comments_cubit.dart'
    as _i804;
import '../../features/post/presentation/cubit/post_actions/post_actions_cubit.dart'
    as _i238;
import '../../features/post/presentation/cubit/post_likes/post_likes_cubit.dart'
    as _i195;
import '../../features/post/presentation/cubit/post_page/post_page_cubit.dart'
    as _i410;
import '../../features/post/presentation/cubit/post_visibility/post_visibility_cubit.dart'
    as _i922;
import '../../features/post/presentation/cubit/share_sheet/share_sheet_cubit.dart'
    as _i1066;
import '../../features/post/presentation/cubit/tag_in_photo/tag_in_photo_cubit.dart'
    as _i125;
import '../../features/post/presentation/cubit/tag_people/tag_people_cubit.dart'
    as _i97;
import '../../features/post/presentation/cubit/tagged_people/tagged_people_cubit.dart'
    as _i118;
import '../../features/post/presentation/utils/comment_drafts.dart' as _i277;
import '../../features/post/presentation/utils/feed_post.dart' as _i992;
import '../../features/post/presentation/utils/tag_people_args.dart' as _i425;
import '../../features/profile/data/datasource/app_preferences_datasource.dart'
    as _i875;
import '../../features/profile/data/datasource/blocks_datasource.dart' as _i4;
import '../../features/profile/data/datasource/interests_datasource.dart'
    as _i152;
import '../../features/profile/data/datasource/notification_prefs_datasource.dart'
    as _i309;
import '../../features/profile/data/datasource/people_datasource.dart' as _i784;
import '../../features/profile/data/datasource/privacy_settings_datasource.dart'
    as _i200;
import '../../features/profile/data/datasource/profile_datasource.dart'
    as _i320;
import '../../features/profile/data/datasource/profile_local_datasource.dart'
    as _i126;
import '../../features/profile/data/datasource/profile_page_datasource.dart'
    as _i874;
import '../../features/profile/data/datasource/settings_datasource.dart'
    as _i388;
import '../../features/profile/data/enums/people_kind.dart' as _i509;
import '../../features/profile/data/repository/profile_repository.dart'
    as _i508;
import '../../features/profile/domain/use_case/clear_local_profile_use_case.dart'
    as _i428;
import '../../features/profile/domain/use_case/complete_signup_use_case.dart'
    as _i890;
import '../../features/profile/domain/use_case/forget_last_account_use_case.dart'
    as _i1067;
import '../../features/profile/domain/use_case/get_current_user_id_use_case.dart'
    as _i91;
import '../../features/profile/domain/use_case/get_interests_use_case.dart'
    as _i586;
import '../../features/profile/domain/use_case/get_last_account_use_case.dart'
    as _i727;
import '../../features/profile/domain/use_case/get_signup_draft_use_case.dart'
    as _i199;
import '../../features/profile/domain/use_case/get_signup_step_use_case.dart'
    as _i697;
import '../../features/profile/domain/use_case/is_signup_done_on_device_use_case.dart'
    as _i422;
import '../../features/profile/domain/use_case/save_about_you_use_case.dart'
    as _i357;
import '../../features/profile/domain/use_case/save_interests_use_case.dart'
    as _i597;
import '../../features/profile/domain/use_case/save_profile_details_use_case.dart'
    as _i255;
import '../../features/profile/presentation/cubit/blocked/blocked_cubit.dart'
    as _i321;
import '../../features/profile/presentation/cubit/notifications/notifications_cubit.dart'
    as _i1000;
import '../../features/profile/presentation/cubit/own_author/own_author_cubit.dart'
    as _i378;
import '../../features/profile/presentation/cubit/people/people_cubit.dart'
    as _i264;
import '../../features/profile/presentation/cubit/personal_info/personal_info_cubit.dart'
    as _i919;
import '../../features/profile/presentation/cubit/privacy/privacy_cubit.dart'
    as _i300;
import '../../features/profile/presentation/cubit/profile/profile_cubit.dart'
    as _i771;
import '../../features/profile/presentation/cubit/settings/settings_cubit.dart'
    as _i75;
import '../../features/splash/presentation/cubit/splash_cubit.dart' as _i127;
import '../../features/story/data/datasource/stories_datasource.dart' as _i474;
import '../../features/story/data/datasource/story_camera_hint_datasource.dart'
    as _i996;
import '../../features/story/data/datasource/story_rail_local_datasource.dart'
    as _i434;
import '../../features/story/data/enums/audience_list.dart' as _i338;
import '../../features/story/data/repository/story_rail_repository.dart'
    as _i942;
import '../../features/story/data/repository/story_upload_repository.dart'
    as _i618;
import '../../features/story/domain/entity/captured_story_media.dart' as _i2;
import '../../features/story/domain/use_case/get_story_rail_use_case.dart'
    as _i849;
import '../../features/story/presentation/cubit/audience_list/audience_list_cubit.dart'
    as _i133;
import '../../features/story/presentation/cubit/story_audience/story_audience_cubit.dart'
    as _i376;
import '../../features/story/presentation/cubit/story_camera/story_camera_cubit.dart'
    as _i569;
import '../../features/story/presentation/cubit/story_edit/story_edit_cubit.dart'
    as _i379;
import '../../features/story/presentation/cubit/story_post_edit/story_post_edit_cubit.dart'
    as _i305;
import '../../features/story/presentation/cubit/story_viewer/story_viewer_cubit.dart'
    as _i465;
import '../../features/story/presentation/cubit/story_viewers/story_viewers_cubit.dart'
    as _i427;
import '../../shared/content/data/datasource/audience_datasource.dart' as _i61;
import '../../shared/content/data/datasource/content_actions_datasource.dart'
    as _i719;
import '../../shared/content/data/datasource/content_changes_datasource.dart'
    as _i420;
import '../../shared/content/data/datasource/content_changes_point_datasource.dart'
    as _i686;
import '../../shared/content/data/datasource/content_discards_datasource.dart'
    as _i142;
import '../../shared/content/data/datasource/content_live_datasource.dart'
    as _i1024;
import '../../shared/content/data/datasource/media_files_datasource.dart'
    as _i285;
import '../../shared/content/data/datasource/pending_content_datasource.dart'
    as _i591;
import '../../shared/content/data/datasource/privacy_datasource.dart' as _i885;
import '../../shared/content/data/enums/content_audience.dart' as _i248;
import '../../shared/content/data/repository/content_changes_repository.dart'
    as _i424;
import '../../shared/content/data/repository/content_discard_repository.dart'
    as _i1034;
import '../../shared/content/data/repository/content_media_repository.dart'
    as _i463;
import '../../shared/content/data/repository/content_publish_repository.dart'
    as _i999;
import '../../shared/content/data/repository/media_upload_queue.dart' as _i148;
import '../../shared/content/domain/use_case/check_content_changes_use_case.dart'
    as _i673;
import '../../shared/content/domain/use_case/discard_publish_use_case.dart'
    as _i453;
import '../../shared/content/domain/use_case/get_audience_summary_use_case.dart'
    as _i77;
import '../../shared/content/domain/use_case/get_post_counts_use_case.dart'
    as _i20;
import '../../shared/content/domain/use_case/get_privacy_use_case.dart'
    as _i660;
import '../../shared/content/domain/use_case/get_publish_line_use_case.dart'
    as _i46;
import '../../shared/content/domain/use_case/get_publish_status_use_case.dart'
    as _i541;
import '../../shared/content/domain/use_case/publish_content_use_case.dart'
    as _i1032;
import '../../shared/content/domain/use_case/remove_media_files_use_case.dart'
    as _i76;
import '../../shared/content/domain/use_case/report_content_use_case.dart'
    as _i1021;
import '../../shared/content/domain/use_case/resume_content_use_case.dart'
    as _i1013;
import '../../shared/content/domain/use_case/retry_publish_use_case.dart'
    as _i108;
import '../../shared/content/domain/use_case/save_default_audience_use_case.dart'
    as _i1035;
import '../../shared/content/domain/use_case/set_content_audience_use_case.dart'
    as _i998;
import '../../shared/content/domain/use_case/set_mute_use_case.dart' as _i71;
import '../../shared/content/domain/use_case/start_content_live_use_case.dart'
    as _i78;
import '../../shared/content/domain/use_case/stop_content_live_use_case.dart'
    as _i429;
import '../events/event_bus.dart' as _i557;
import '../router/recovery_link_handler.dart' as _i358;
import '../router/session_guard.dart' as _i96;
import '../services/app_version_service.dart' as _i212;
import '../services/blurhash_service.dart' as _i905;
import '../services/camera_device.dart' as _i64;
import '../services/camera_permission_service.dart' as _i754;
import '../services/connectivity_service.dart' as _i47;
import '../services/device_tier.dart' as _i876;
import '../services/gallery_service.dart' as _i841;
import '../services/launch_service.dart' as _i1016;
import '../services/locale_service.dart' as _i729;
import '../services/location_service.dart' as _i669;
import '../services/media_picker_service.dart' as _i715;
import '../services/palette_service.dart' as _i886;
import '../services/photo_picker_service.dart' as _i94;
import '../services/session_events.dart' as _i815;
import '../services/storage/app_folders.dart' as _i393;
import '../services/storage/backup_exclusion.dart' as _i920;
import '../services/storage/local_storage.dart' as _i201;
import '../services/storage/snapshot_storage.dart' as _i261;
import '../services/video_compress_service.dart' as _i794;
import '../services/video_overlay_service.dart' as _i327;
import '../services/video_thumbnail_service.dart' as _i143;
import '../state/camera_permission_cubit.dart' as _i721;
import '../utils/story_post_args.dart' as _i439;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i876.DeviceTier>(
      () => appModule.deviceTier,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i393.AppFolders>(
      () => appModule.appFolders,
      preResolve: true,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => appModule.supabaseClient);
    gh.lazySingleton<_i519.Client>(() => appModule.httpClient);
    gh.lazySingleton<_i895.Connectivity>(() => appModule.connectivity);
    gh.lazySingleton<_i718.GlobalKey<_i718.NavigatorState>>(
      () => appModule.navigatorKey,
    );
    gh.lazySingleton<_i557.EventBus>(
      () => _i557.EventBus(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i815.SessionEvents>(
      () => _i815.SessionEvents(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i277.CommentDrafts>(() => _i277.CommentDrafts());
    gh.lazySingleton<_i920.BackupExclusionService>(
      () => _i920.PlatformBackupExclusionService(),
    );
    gh.lazySingleton<_i905.BlurhashService>(
      () => _i905.PackageBlurhashService(),
    );
    gh.lazySingleton<_i886.PaletteService>(() => _i886.PixelPaletteService());
    gh.factoryParam<_i125.TagInPhotoCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) => _i125.TagInPhotoCubit(args),
    );
    gh.lazySingleton<_i794.VideoCompressService>(
      () => _i794.PackageVideoCompressService(),
    );
    gh.lazySingleton<_i94.PhotoPickerService>(
      () => _i94.ImagePickerPhotoPickerService(),
    );
    gh.lazySingleton<_i212.AppVersionService>(
      () => _i212.PackageInfoVersionService(),
    );
    gh.lazySingleton<_i327.VideoOverlayService>(
      () => _i327.ChannelVideoOverlayService(),
    );
    gh.lazySingleton<_i143.VideoThumbnailService>(
      () => _i143.PackageVideoThumbnailService(),
    );
    gh.lazySingleton<_i715.MediaPickerService>(
      () => _i715.ImagePickerMediaPickerService(),
    );
    await gh.lazySingletonAsync<_i261.SnapshotStorage>(
      () => appModule.cacheStorage(gh<_i393.AppFolders>()),
      preResolve: true,
      dispose: _i431.disposeSnapshotStorage,
    );
    gh.lazySingleton<_i669.LocationService>(
      () => _i669.GeolocatorLocationService(),
    );
    gh.lazySingleton<_i285.MediaFilesDatasource>(
      () => _i285.SupabaseMediaFilesDatasource(
        gh<_i454.SupabaseClient>(),
        gh<_i519.Client>(),
      ),
    );
    gh.lazySingleton<_i1016.LaunchService>(
      () => _i1016.UrlLauncherLaunchService(),
    );
    gh.factory<_i64.CameraDevice>(() => _i64.PackageCameraDevice());
    gh.lazySingleton<_i841.GalleryService>(
      () => _i841.GalGalleryService(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i754.CameraPermissionService>(
      () => _i754.HandlerCameraPermissionService(),
    );
    gh.factory<_i721.CameraPermissionCubit>(
      () => _i721.CameraPermissionCubit(gh<_i754.CameraPermissionService>()),
    );
    gh.lazySingleton<_i512.PostActionsDatasource>(
      () => _i512.SupabasePostActionsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i76.RemoveMediaFilesUseCase>(
      () => _i76.RemoveMediaFilesUseCase(gh<_i285.MediaFilesDatasource>()),
    );
    gh.lazySingleton<_i874.ProfilePageDatasource>(
      () => _i874.SupabaseProfilePageDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i141.PostsDatasource>(
      () => _i141.SupabasePostsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i474.StoriesDatasource>(
      () => _i474.SupabaseStoriesDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i201.LocalStorageService>(
      () => _i201.SharedPrefsStorageService(gh<_i460.SharedPreferences>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i634.PostLikesDatasource>(
      () => _i634.SupabasePostLikesDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i152.InterestsDatasource>(
      () => _i152.SupabaseInterestsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i142.ContentDiscardsDatasource>(
      () => _i142.LocalContentDiscardsDatasource(
        gh<_i201.LocalStorageService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.lazySingleton<_i686.ContentChangesPointDatasource>(
      () => _i686.LocalContentChangesPointDatasource(
        gh<_i201.LocalStorageService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.lazySingleton<_i604.LegalDatasource>(
      () => _i604.SupabaseLegalDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i388.SettingsDatasource>(
      () => _i388.SupabaseSettingsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i4.BlocksDatasource>(
      () => _i4.SupabaseBlocksDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i784.PeopleDatasource>(
      () => _i784.SupabasePeopleDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i568.ActivityDatasource>(
      () => _i568.SupabaseActivityDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i603.CommentsLocalDatasource>(
      () => _i603.CommentsLocalDatasource(gh<_i261.SnapshotStorage>()),
    );
    gh.lazySingleton<_i35.FeedLocalDatasource>(
      () => _i35.FeedLocalDatasource(gh<_i261.SnapshotStorage>()),
    );
    gh.lazySingleton<_i434.StoryRailLocalDatasource>(
      () => _i434.StoryRailLocalDatasource(gh<_i261.SnapshotStorage>()),
    );
    gh.lazySingleton<_i591.PendingContentDatasource>(
      () => _i591.SupabasePendingContentDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i719.ContentActionsDatasource>(
      () => _i719.SupabaseContentActionsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i320.ProfileDatasource>(
      () => _i320.SupabaseProfileDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i309.NotificationPrefsDatasource>(
      () =>
          _i309.SupabaseNotificationPrefsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i427.StoryViewersCubit>(
      () => _i427.StoryViewersCubit(gh<_i474.StoriesDatasource>()),
    );
    gh.lazySingleton<_i420.ContentChangesDatasource>(
      () => _i420.SupabaseContentChangesDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i942.StoryRailRepository>(
      () => _i942.StoryRailRepositoryImpl(
        gh<_i474.StoriesDatasource>(),
        gh<_i434.StoryRailLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i1001.FollowsDatasource>(
      () => _i1001.SupabaseFollowsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i463.ContentMediaRepository>(
      () => _i463.ContentMediaRepository(
        gh<_i285.MediaFilesDatasource>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i794.VideoCompressService>(),
      ),
    );
    gh.lazySingleton<_i200.PrivacySettingsDatasource>(
      () => _i200.SupabasePrivacySettingsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i740.FollowAllUseCase>(
      () => _i740.FollowAllUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i608.GetFollowRequestCountUseCase>(
      () => _i608.GetFollowRequestCountUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i171.GetFollowRequestsUseCase>(
      () => _i171.GetFollowRequestsUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i689.GetFollowStatusUseCase>(
      () => _i689.GetFollowStatusUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i250.GetSuggestedProfilesUseCase>(
      () => _i250.GetSuggestedProfilesUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i534.RespondToFollowRequestUseCase>(
      () => _i534.RespondToFollowRequestUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i130.ToggleFollowUseCase>(
      () => _i130.ToggleFollowUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.lazySingleton<_i781.CommentsDatasource>(
      () => _i781.SupabaseCommentsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i47.ConnectivityService>(
      () => _i47.PlusConnectivityService(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i438.PlacesDatasource>(
      () => _i438.SupabasePlacesDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i1024.ContentLiveDatasource>(
      () => _i1024.SupabaseContentLiveDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i885.PrivacyDatasource>(
      () => _i885.SupabasePrivacyDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i518.PostTagsDatasource>(
      () => _i518.SupabasePostTagsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i61.AudienceDatasource>(
      () => _i61.SupabaseAudienceDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i736.LegalCubit>(
      () => _i736.LegalCubit(
        gh<_i604.LegalDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
    );
    gh.lazySingleton<_i1007.PostDraftDatasource>(
      () => _i1007.LocalPostDraftDatasource(
        gh<_i201.LocalStorageService>(),
        gh<_i393.AppFolders>(),
        gh<_i920.BackupExclusionService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.lazySingleton<_i280.FeedRepository>(
      () => _i280.FeedRepositoryImpl(
        gh<_i141.PostsDatasource>(),
        gh<_i35.FeedLocalDatasource>(),
      ),
    );
    gh.factory<_i77.GetAudienceSummaryUseCase>(
      () => _i77.GetAudienceSummaryUseCase(gh<_i61.AudienceDatasource>()),
    );
    gh.factory<_i849.GetStoryRailUseCase>(
      () => _i849.GetStoryRailUseCase(gh<_i942.StoryRailRepository>()),
    );
    gh.factory<_i281.GetHomeFeedUseCase>(
      () => _i281.GetHomeFeedUseCase(gh<_i280.FeedRepository>()),
    );
    gh.factory<_i341.SaveHomeFeedUseCase>(
      () => _i341.SaveHomeFeedUseCase(gh<_i280.FeedRepository>()),
    );
    gh.factory<_i300.PrivacyCubit>(
      () => _i300.PrivacyCubit(
        gh<_i200.PrivacySettingsDatasource>(),
        gh<_i4.BlocksDatasource>(),
      ),
    );
    gh.lazySingleton<_i236.PasswordRecoveryTracker>(
      () => _i236.PasswordRecoveryTracker(gh<_i201.LocalStorageService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i834.OnboardingDatasource>(
      () => _i834.OnboardingDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i234.LocationPrimerDatasource>(
      () => _i234.LocationPrimerDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i366.RecentPlacesDatasource>(
      () => _i366.RecentPlacesDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i722.VisibilityNoticeDatasource>(
      () => _i722.VisibilityNoticeDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i875.AppPreferencesDatasource>(
      () => _i875.AppPreferencesDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i126.ProfileLocalDatasource>(
      () => _i126.ProfileLocalDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.lazySingleton<_i996.StoryCameraHintDatasource>(
      () => _i996.StoryCameraHintDatasource(gh<_i201.LocalStorageService>()),
    );
    gh.factory<_i569.StoryCameraCubit>(
      () => _i569.StoryCameraCubit(
        gh<_i64.CameraDevice>(),
        gh<_i715.MediaPickerService>(),
        gh<_i996.StoryCameraHintDatasource>(),
      ),
    );
    gh.lazySingleton<_i508.ProfileRepository>(
      () => _i508.ProfileRepositoryImpl(
        gh<_i320.ProfileDatasource>(),
        gh<_i126.ProfileLocalDatasource>(),
      ),
    );
    gh.factoryParam<_i133.AudienceListCubit, _i338.AudienceList, dynamic>(
      (list, _) => _i133.AudienceListCubit(
        gh<_i474.StoriesDatasource>(),
        gh<_i77.GetAudienceSummaryUseCase>(),
        list,
      ),
    );
    gh.factory<_i321.BlockedCubit>(
      () => _i321.BlockedCubit(gh<_i4.BlocksDatasource>()),
    );
    gh.factory<_i919.PersonalInfoCubit>(
      () => _i919.PersonalInfoCubit(
        gh<_i508.ProfileRepository>(),
        gh<_i94.PhotoPickerService>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i1000.NotificationsCubit>(
      () => _i1000.NotificationsCubit(gh<_i309.NotificationPrefsDatasource>()),
    );
    gh.lazySingleton<_i974.PlacesRepository>(
      () => _i974.PlacesRepositoryImpl(
        gh<_i438.PlacesDatasource>(),
        gh<_i366.RecentPlacesDatasource>(),
      ),
    );
    gh.factory<_i586.GetInterestsUseCase>(
      () => _i586.GetInterestsUseCase(gh<_i152.InterestsDatasource>()),
    );
    gh.lazySingleton<_i729.LocaleService>(
      () => _i729.StoredLocaleService(gh<_i201.LocalStorageService>()),
    );
    gh.factory<_i597.SaveInterestsUseCase>(
      () => _i597.SaveInterestsUseCase(
        gh<_i152.InterestsDatasource>(),
        gh<_i508.ProfileRepository>(),
      ),
    );
    gh.factoryParam<_i490.AddLocationCubit, String?, dynamic>(
      (current, _) => _i490.AddLocationCubit(
        gh<_i974.PlacesRepository>(),
        gh<_i669.LocationService>(),
        gh<_i47.ConnectivityService>(),
        gh<_i234.LocationPrimerDatasource>(),
        current,
      ),
    );
    gh.factory<_i428.ClearLocalProfileUseCase>(
      () => _i428.ClearLocalProfileUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i890.CompleteSignupUseCase>(
      () => _i890.CompleteSignupUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i1067.ForgetLastAccountUseCase>(
      () => _i1067.ForgetLastAccountUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i727.GetLastAccountUseCase>(
      () => _i727.GetLastAccountUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i199.GetSignupDraftUseCase>(
      () => _i199.GetSignupDraftUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i697.GetSignupStepUseCase>(
      () => _i697.GetSignupStepUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i422.IsSignupDoneOnDeviceUseCase>(
      () => _i422.IsSignupDoneOnDeviceUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i357.SaveAboutYouUseCase>(
      () => _i357.SaveAboutYouUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i255.SaveProfileDetailsUseCase>(
      () => _i255.SaveProfileDetailsUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.lazySingleton<_i43.AuthDatasource>(
      () => _i43.SupabaseAuthDatasource(
        gh<_i454.SupabaseClient>(),
        gh<_i236.PasswordRecoveryTracker>(),
        gh<_i261.SnapshotStorage>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i424.ContentChangesRepository>(
      () => _i424.ContentChangesRepositoryImpl(
        gh<_i420.ContentChangesDatasource>(),
        gh<_i686.ContentChangesPointDatasource>(),
        gh<_i557.EventBus>(),
        gh<_i1024.ContentLiveDatasource>(),
      ),
    );
    gh.factory<_i91.GetCurrentUserIdUseCase>(
      () => _i91.GetCurrentUserIdUseCase(gh<_i320.ProfileDatasource>()),
    );
    gh.factory<_i378.OwnAuthorCubit>(
      () => _i378.OwnAuthorCubit(
        gh<_i508.ProfileRepository>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i302.SignInCubit>(
      () => _i302.SignInCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i727.GetLastAccountUseCase>(),
        gh<_i1067.ForgetLastAccountUseCase>(),
      ),
    );
    gh.factory<_i148.MediaUploadQueue>(
      () => _i148.MediaUploadQueue(gh<_i463.ContentMediaRepository>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i834.OnboardingDatasource>()),
    );
    gh.factory<_i1021.ReportContentUseCase>(
      () => _i1021.ReportContentUseCase(gh<_i719.ContentActionsDatasource>()),
    );
    gh.factory<_i998.SetContentAudienceUseCase>(
      () =>
          _i998.SetContentAudienceUseCase(gh<_i719.ContentActionsDatasource>()),
    );
    gh.factory<_i71.SetMuteUseCase>(
      () => _i71.SetMuteUseCase(gh<_i719.ContentActionsDatasource>()),
    );
    gh.factory<_i575.GetUnreadActivityCountUseCase>(
      () => _i575.GetUnreadActivityCountUseCase(gh<_i568.ActivityDatasource>()),
    );
    gh.factory<_i673.CheckContentChangesUseCase>(
      () => _i673.CheckContentChangesUseCase(
        gh<_i424.ContentChangesRepository>(),
      ),
    );
    gh.factory<_i20.GetPostCountsUseCase>(
      () => _i20.GetPostCountsUseCase(gh<_i424.ContentChangesRepository>()),
    );
    gh.factory<_i78.StartContentLiveUseCase>(
      () => _i78.StartContentLiveUseCase(gh<_i424.ContentChangesRepository>()),
    );
    gh.factory<_i429.StopContentLiveUseCase>(
      () => _i429.StopContentLiveUseCase(gh<_i424.ContentChangesRepository>()),
    );
    gh.factory<_i660.GetPrivacyUseCase>(
      () => _i660.GetPrivacyUseCase(gh<_i885.PrivacyDatasource>()),
    );
    gh.factory<_i1035.SaveDefaultAudienceUseCase>(
      () => _i1035.SaveDefaultAudienceUseCase(gh<_i885.PrivacyDatasource>()),
    );
    gh.lazySingleton<_i1034.ContentDiscardRepository>(
      () => _i1034.ContentDiscardRepositoryImpl(
        gh<_i142.ContentDiscardsDatasource>(),
        gh<_i591.PendingContentDatasource>(),
        gh<_i285.MediaFilesDatasource>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.factory<_i730.IsRecoveryPendingUseCase>(
      () => _i730.IsRecoveryPendingUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i710.IsSignedInUseCase>(
      () => _i710.IsSignedInUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i1036.SignOutUseCase>(
      () => _i1036.SignOutUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i602.VerifyPasswordUseCase>(
      () => _i602.VerifyPasswordUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i121.WatchPasswordRecoveryUseCase>(
      () => _i121.WatchPasswordRecoveryUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i260.ResetPasswordCubit>(
      () => _i260.ResetPasswordCubit(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i75.SettingsCubit>(
      () => _i75.SettingsCubit(
        gh<_i388.SettingsDatasource>(),
        gh<_i875.AppPreferencesDatasource>(),
        gh<_i428.ClearLocalProfileUseCase>(),
        gh<_i1036.SignOutUseCase>(),
        gh<_i602.VerifyPasswordUseCase>(),
        gh<_i212.AppVersionService>(),
      ),
    );
    gh.factory<_i465.StoryViewerCubit>(
      () => _i465.StoryViewerCubit(
        gh<_i849.GetStoryRailUseCase>(),
        gh<_i474.StoriesDatasource>(),
        gh<_i841.GalleryService>(),
        gh<_i327.VideoOverlayService>(),
        gh<_i71.SetMuteUseCase>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i76.RemoveMediaFilesUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.lazySingleton<_i999.ContentPublishRepository>(
      () => _i999.ContentPublishRepositoryImpl(
        gh<_i557.EventBus>(),
        gh<_i1034.ContentDiscardRepository>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.factory<_i782.SignUpCubit>(
      () => _i782.SignUpCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i357.SaveAboutYouUseCase>(),
        gh<_i255.SaveProfileDetailsUseCase>(),
        gh<_i94.PhotoPickerService>(),
        gh<_i586.GetInterestsUseCase>(),
        gh<_i597.SaveInterestsUseCase>(),
        gh<_i250.GetSuggestedProfilesUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i740.FollowAllUseCase>(),
        gh<_i890.CompleteSignupUseCase>(),
        gh<_i428.ClearLocalProfileUseCase>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i199.GetSignupDraftUseCase>(),
      ),
    );
    gh.factory<_i598.ControlCubit>(
      () => _i598.ControlCubit(
        gh<_i730.IsRecoveryPendingUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i344.ForgotPasswordCubit>(
      () => _i344.ForgotPasswordCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
    );
    gh.factory<_i453.DiscardPublishUseCase>(
      () => _i453.DiscardPublishUseCase(gh<_i999.ContentPublishRepository>()),
    );
    gh.factory<_i46.GetPublishLineUseCase>(
      () => _i46.GetPublishLineUseCase(gh<_i999.ContentPublishRepository>()),
    );
    gh.factory<_i541.GetPublishStatusUseCase>(
      () => _i541.GetPublishStatusUseCase(gh<_i999.ContentPublishRepository>()),
    );
    gh.factory<_i1032.PublishContentUseCase>(
      () => _i1032.PublishContentUseCase(gh<_i999.ContentPublishRepository>()),
    );
    gh.factory<_i108.RetryPublishUseCase>(
      () => _i108.RetryPublishUseCase(gh<_i999.ContentPublishRepository>()),
    );
    gh.factoryParam<_i376.StoryAudienceCubit, String, _i248.ContentAudience>(
      (storyId, audience) => _i376.StoryAudienceCubit(
        gh<_i77.GetAudienceSummaryUseCase>(),
        gh<_i998.SetContentAudienceUseCase>(),
        storyId,
        audience,
      ),
    );
    gh.lazySingleton<_i618.StoryUploadRepository>(
      () => _i618.StoryUploadRepositoryImpl(
        gh<_i474.StoriesDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i999.ContentPublishRepository>(),
        gh<_i591.PendingContentDatasource>(),
      ),
    );
    gh.factoryParam<_i264.PeopleCubit, _i509.PeopleKind, String>(
      (kind, userId) => _i264.PeopleCubit(
        gh<_i784.PeopleDatasource>(),
        gh<_i874.ProfilePageDatasource>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        kind,
        userId,
      ),
    );
    gh.factory<_i308.StoryRailCubit>(
      () => _i308.StoryRailCubit(
        gh<_i849.GetStoryRailUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i108.RetryPublishUseCase>(),
        gh<_i727.GetLastAccountUseCase>(),
        gh<_i673.CheckContentChangesUseCase>(),
      ),
    );
    gh.factoryParam<_i379.StoryEditCubit, _i2.CapturedStoryMedia, dynamic>(
      (media, _) => _i379.StoryEditCubit(
        gh<_i618.StoryUploadRepository>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i905.BlurhashService>(),
        gh<_i841.GalleryService>(),
        gh<_i327.VideoOverlayService>(),
        gh<_i794.VideoCompressService>(),
        gh<_i727.GetLastAccountUseCase>(),
        media,
      ),
    );
    gh.factoryParam<_i922.PostVisibilityCubit, String?, _i248.ContentAudience>(
      (postId, audience) => _i922.PostVisibilityCubit(
        gh<_i660.GetPrivacyUseCase>(),
        gh<_i77.GetAudienceSummaryUseCase>(),
        gh<_i1035.SaveDefaultAudienceUseCase>(),
        gh<_i998.SetContentAudienceUseCase>(),
        gh<_i722.VisibilityNoticeDatasource>(),
        postId,
        audience,
      ),
    );
    gh.factory<_i639.BellDotCubit>(
      () => _i639.BellDotCubit(
        gh<_i575.GetUnreadActivityCountUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i793.WatchSessionEndedUseCase>(
      () => _i793.WatchSessionEndedUseCase(
        gh<_i43.AuthDatasource>(),
        gh<_i815.SessionEvents>(),
      ),
    );
    gh.factory<_i127.SplashCubit>(
      () => _i127.SplashCubit(
        gh<_i710.IsSignedInUseCase>(),
        gh<_i730.IsRecoveryPendingUseCase>(),
        gh<_i422.IsSignupDoneOnDeviceUseCase>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i1036.SignOutUseCase>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i845.PostPublishingRepository>(
      () => _i845.PostPublishingRepositoryImpl(
        gh<_i1007.PostDraftDatasource>(),
        gh<_i591.PendingContentDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i141.PostsDatasource>(),
        gh<_i999.ContentPublishRepository>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i1017.PostDraftRepository>(
      () => _i1017.PostDraftRepositoryImpl(
        gh<_i1007.PostDraftDatasource>(),
        gh<_i148.MediaUploadQueue>(),
        gh<_i591.PendingContentDatasource>(),
        gh<_i845.PostPublishingRepository>(),
        gh<_i1034.ContentDiscardRepository>(),
      ),
    );
    gh.lazySingleton<_i358.RecoveryLinkHandler>(
      () => appModule.recoveryLinkHandler(
        gh<_i718.GlobalKey<_i718.NavigatorState>>(),
        gh<_i121.WatchPasswordRecoveryUseCase>(),
      ),
      dispose: _i431.disposeRecoveryLinkHandler,
    );
    gh.factory<_i401.ResumeSharedPostsUseCase>(
      () =>
          _i401.ResumeSharedPostsUseCase(gh<_i845.PostPublishingRepository>()),
    );
    gh.lazySingleton<_i699.PostRepository>(
      () => _i699.PostRepositoryImpl(
        gh<_i141.PostsDatasource>(),
        gh<_i512.PostActionsDatasource>(),
        gh<_i781.CommentsDatasource>(),
        gh<_i603.CommentsLocalDatasource>(),
        gh<_i634.PostLikesDatasource>(),
        gh<_i518.PostTagsDatasource>(),
        gh<_i285.MediaFilesDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i999.ContentPublishRepository>(),
        gh<_i424.ContentChangesRepository>(),
      ),
    );
    gh.lazySingleton<_i96.SessionGuard>(
      () => appModule.sessionGuard(
        gh<_i718.GlobalKey<_i718.NavigatorState>>(),
        gh<_i793.WatchSessionEndedUseCase>(),
      ),
      dispose: _i431.disposeSessionGuard,
    );
    gh.factory<_i238.PostActionsCubit>(
      () => _i238.PostActionsCubit(
        gh<_i699.PostRepository>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i71.SetMuteUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i1013.ResumeContentUseCase>(
      () => _i1013.ResumeContentUseCase(
        gh<_i999.ContentPublishRepository>(),
        gh<_i1034.ContentDiscardRepository>(),
      ),
    );
    gh.factory<_i803.PostLineCubit>(
      () => _i803.PostLineCubit(
        gh<_i557.EventBus>(),
        gh<_i46.GetPublishLineUseCase>(),
      ),
    );
    gh.factory<_i371.HasOpenPostDraftUseCase>(
      () => _i371.HasOpenPostDraftUseCase(gh<_i1017.PostDraftRepository>()),
    );
    gh.factoryParam<_i118.TaggedPeopleCubit, String, dynamic>(
      (postId, _) => _i118.TaggedPeopleCubit(
        gh<_i699.PostRepository>(),
        gh<_i130.ToggleFollowUseCase>(),
        postId,
      ),
    );
    gh.factoryParam<_i804.CommentsCubit, String, String?>(
      (postId, focusCommentId) => _i804.CommentsCubit(
        gh<_i699.PostRepository>(),
        gh<_i781.CommentsDatasource>(),
        gh<_i277.CommentDrafts>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i727.GetLastAccountUseCase>(),
        postId,
        focusCommentId,
      ),
    );
    gh.factoryParam<_i305.StoryPostEditCubit, _i439.StoryPostArgs, dynamic>(
      (post, _) => _i305.StoryPostEditCubit(
        gh<_i618.StoryUploadRepository>(),
        gh<_i905.BlurhashService>(),
        gh<_i841.GalleryService>(),
        gh<_i886.PaletteService>(),
        gh<_i727.GetLastAccountUseCase>(),
        post,
      ),
    );
    gh.factoryParam<_i356.CommentMentionsCubit, String, dynamic>(
      (postId, _) =>
          _i356.CommentMentionsCubit(gh<_i699.PostRepository>(), postId),
    );
    gh.factory<_i1044.GetLikedByPreviewsUseCase>(
      () => _i1044.GetLikedByPreviewsUseCase(gh<_i699.PostRepository>()),
    );
    gh.factory<_i1014.GetPostsByIdsUseCase>(
      () => _i1014.GetPostsByIdsUseCase(gh<_i699.PostRepository>()),
    );
    gh.factory<_i599.SignPostMediaUrlsUseCase>(
      () => _i599.SignPostMediaUrlsUseCase(gh<_i699.PostRepository>()),
    );
    gh.factory<_i771.ProfileCubit>(
      () => _i771.ProfileCubit(
        gh<_i874.ProfilePageDatasource>(),
        gh<_i508.ProfileRepository>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i1016.LaunchService>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factoryParam<_i195.PostLikesCubit, String, dynamic>(
      (postId, _) => _i195.PostLikesCubit(
        gh<_i699.PostRepository>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        postId,
      ),
    );
    gh.factoryParam<_i1066.ShareSheetCubit, String, dynamic>(
      (postId, _) => _i1066.ShareSheetCubit(
        gh<_i699.PostRepository>(),
        gh<_i660.GetPrivacyUseCase>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i727.GetLastAccountUseCase>(),
        postId,
      ),
    );
    gh.factoryParam<_i97.TagPeopleCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) => _i97.TagPeopleCubit(gh<_i699.PostRepository>(), args),
    );
    gh.factory<_i592.FeedCubit>(
      () => _i592.FeedCubit(
        gh<_i281.GetHomeFeedUseCase>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        gh<_i673.CheckContentChangesUseCase>(),
        gh<_i1014.GetPostsByIdsUseCase>(),
        gh<_i20.GetPostCountsUseCase>(),
        gh<_i78.StartContentLiveUseCase>(),
        gh<_i429.StopContentLiveUseCase>(),
        gh<_i341.SaveHomeFeedUseCase>(),
        gh<_i1044.GetLikedByPreviewsUseCase>(),
      ),
    );
    gh.factory<_i613.PostPublishCubit>(
      () => _i613.PostPublishCubit(
        gh<_i557.EventBus>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i108.RetryPublishUseCase>(),
        gh<_i453.DiscardPublishUseCase>(),
        gh<_i1013.ResumeContentUseCase>(),
        gh<_i401.ResumeSharedPostsUseCase>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        gh<_i371.HasOpenPostDraftUseCase>(),
      ),
    );
    gh.factoryParam<
      _i80.AddEditPostCubit,
      _i570.PostEntity?,
      Map<String, String>?
    >(
      (post, signedUrls) => _i80.AddEditPostCubit(
        gh<_i699.PostRepository>(),
        gh<_i1032.PublishContentUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i715.MediaPickerService>(),
        gh<_i660.GetPrivacyUseCase>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i727.GetLastAccountUseCase>(),
        gh<_i1017.PostDraftRepository>(),
        post,
        signedUrls,
      ),
    );
    gh.factoryParam<_i410.PostPageCubit, String, _i992.FeedPost?>(
      (postId, passed) => _i410.PostPageCubit(
        gh<_i699.PostRepository>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i689.GetFollowStatusUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
        postId,
        passed,
      ),
    );
    return this;
  }
}

class _$AppModule extends _i431.AppModule {}
