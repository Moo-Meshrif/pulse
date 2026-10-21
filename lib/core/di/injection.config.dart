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
    as _i781;
import '../../features/control/presentation/cubit/control_cubit.dart' as _i598;
import '../../features/follow/data/datasource/follows_datasource.dart'
    as _i1001;
import '../../features/follow/domain/use_case/follow_all_use_case.dart'
    as _i740;
import '../../features/follow/domain/use_case/get_follow_request_count_use_case.dart'
    as _i608;
import '../../features/follow/domain/use_case/get_follow_requests_use_case.dart'
    as _i171;
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
import '../../features/post/data/datasource/post_actions_datasource.dart'
    as _i512;
import '../../features/post/data/datasource/post_draft_datasource.dart'
    as _i1007;
import '../../features/post/data/datasource/post_tags_datasource.dart' as _i518;
import '../../features/post/data/datasource/posts_datasource.dart' as _i141;
import '../../features/post/data/datasource/visibility_notice_datasource.dart'
    as _i722;
import '../../features/post/data/repository/post_draft_repository.dart'
    as _i1017;
import '../../features/post/data/repository/post_share_repository.dart'
    as _i837;
import '../../features/post/data/repository/shared_posts_repository.dart'
    as _i749;
import '../../features/post/domain/entity/post_entity.dart' as _i570;
import '../../features/post/domain/use_case/delete_post_use_case.dart' as _i898;
import '../../features/post/domain/use_case/get_home_feed_use_case.dart'
    as _i280;
import '../../features/post/domain/use_case/get_tagged_people_use_case.dart'
    as _i846;
import '../../features/post/domain/use_case/has_open_post_draft_use_case.dart'
    as _i371;
import '../../features/post/domain/use_case/hide_post_use_case.dart' as _i856;
import '../../features/post/domain/use_case/remove_my_tag_use_case.dart'
    as _i491;
import '../../features/post/domain/use_case/resume_shared_posts_use_case.dart'
    as _i401;
import '../../features/post/domain/use_case/search_tag_people_use_case.dart'
    as _i983;
import '../../features/post/domain/use_case/set_comments_enabled_use_case.dart'
    as _i246;
import '../../features/post/domain/use_case/set_post_like_use_case.dart'
    as _i804;
import '../../features/post/domain/use_case/set_post_save_use_case.dart'
    as _i520;
import '../../features/post/domain/use_case/sign_post_media_urls_use_case.dart'
    as _i599;
import '../../features/post/domain/use_case/update_post_use_case.dart' as _i908;
import '../../features/post/presentation/cubit/add_edit_post/add_edit_post_cubit.dart'
    as _i80;
import '../../features/post/presentation/cubit/post_actions/post_actions_cubit.dart'
    as _i238;
import '../../features/post/presentation/cubit/post_visibility/post_visibility_cubit.dart'
    as _i922;
import '../../features/post/presentation/cubit/tag_in_photo/tag_in_photo_cubit.dart'
    as _i125;
import '../../features/post/presentation/cubit/tag_people/tag_people_cubit.dart'
    as _i96;
import '../../features/post/presentation/cubit/tagged_people/tagged_people_cubit.dart'
    as _i118;
import '../../features/post/presentation/utils/tag_people_args.dart' as _i425;
import '../../features/profile/data/datasource/interests_datasource.dart'
    as _i152;
import '../../features/profile/data/datasource/profile_datasource.dart'
    as _i320;
import '../../features/profile/data/datasource/profile_local_datasource.dart'
    as _i126;
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
import '../../features/profile/domain/use_case/save_about_you_use_case.dart'
    as _i357;
import '../../features/profile/domain/use_case/save_interests_use_case.dart'
    as _i597;
import '../../features/profile/domain/use_case/save_profile_details_use_case.dart'
    as _i255;
import '../../features/splash/presentation/cubit/splash_cubit.dart' as _i127;
import '../../features/story/data/datasource/stories_datasource.dart' as _i474;
import '../../features/story/data/datasource/story_camera_hint_datasource.dart'
    as _i996;
import '../../features/story/data/enums/audience_list.dart' as _i338;
import '../../features/story/data/repository/story_upload_repository.dart'
    as _i618;
import '../../features/story/domain/entity/captured_story_media.dart' as _i2;
import '../../features/story/domain/use_case/get_story_rail_use_case.dart'
    as _i850;
import '../../features/story/presentation/cubit/audience_list/audience_list_cubit.dart'
    as _i133;
import '../../features/story/presentation/cubit/story_audience/story_audience_cubit.dart'
    as _i376;
import '../../features/story/presentation/cubit/story_camera/story_camera_cubit.dart'
    as _i569;
import '../../features/story/presentation/cubit/story_edit/story_edit_cubit.dart'
    as _i378;
import '../../features/story/presentation/cubit/story_viewer/story_viewer_cubit.dart'
    as _i465;
import '../../features/story/presentation/cubit/story_viewers/story_viewers_cubit.dart'
    as _i427;
import '../../shared/content/data/datasource/audience_datasource.dart' as _i61;
import '../../shared/content/data/datasource/content_actions_datasource.dart'
    as _i719;
import '../../shared/content/data/datasource/content_discards_datasource.dart'
    as _i142;
import '../../shared/content/data/datasource/media_files_datasource.dart'
    as _i285;
import '../../shared/content/data/datasource/pending_content_datasource.dart'
    as _i591;
import '../../shared/content/data/datasource/privacy_datasource.dart' as _i885;
import '../../shared/content/data/enums/content_audience.dart' as _i248;
import '../../shared/content/data/repository/content_discard_repository.dart'
    as _i1034;
import '../../shared/content/data/repository/content_media_repository.dart'
    as _i463;
import '../../shared/content/data/repository/content_publish_repository.dart'
    as _i999;
import '../../shared/content/data/repository/media_upload_queue.dart' as _i148;
import '../../shared/content/domain/use_case/discard_publish_use_case.dart'
    as _i453;
import '../../shared/content/domain/use_case/get_audience_summary_use_case.dart'
    as _i77;
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
import '../events/event_bus.dart' as _i557;
import '../router/recovery_link_handler.dart' as _i358;
import '../router/session_guard.dart' as _i97;
import '../services/app_folders.dart' as _i849;
import '../services/backup_exclusion_service.dart' as _i690;
import '../services/blurhash_service.dart' as _i905;
import '../services/camera_device.dart' as _i64;
import '../services/camera_permission_service.dart' as _i754;
import '../services/connectivity_service.dart' as _i47;
import '../services/device_tier.dart' as _i876;
import '../services/gallery_service.dart' as _i841;
import '../services/launch_service.dart' as _i1016;
import '../services/local_storage_service.dart' as _i527;
import '../services/location_service.dart' as _i669;
import '../services/media_picker_service.dart' as _i715;
import '../services/photo_picker_service.dart' as _i94;
import '../services/session_events.dart' as _i815;
import '../services/video_compress_service.dart' as _i794;
import '../services/video_overlay_service.dart' as _i327;
import '../services/video_thumbnail_service.dart' as _i143;
import '../state/camera_permission_cubit.dart' as _i721;

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
    await gh.lazySingletonAsync<_i849.AppFolders>(
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
    gh.lazySingleton<_i905.BlurhashService>(
      () => _i905.PackageBlurhashService(),
    );
    gh.factoryParam<_i125.TagInPhotoCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) => _i125.TagInPhotoCubit(args),
    );
    gh.lazySingleton<_i794.VideoCompressService>(
      () => _i794.PackageVideoCompressService(),
    );
    gh.lazySingleton<_i94.PhotoPickerService>(
      () => _i94.ImagePickerPhotoPickerService(),
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
    gh.lazySingleton<_i690.BackupExclusionService>(
      () => _i690.PlatformBackupExclusionService(),
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
    gh.lazySingleton<_i141.PostsDatasource>(
      () => _i141.SupabasePostsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i474.StoriesDatasource>(
      () => _i474.SupabaseStoriesDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i152.InterestsDatasource>(
      () => _i152.SupabaseInterestsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i604.LegalDatasource>(
      () => _i604.SupabaseLegalDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i568.ActivityDatasource>(
      () => _i568.SupabaseActivityDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i527.LocalStorageService>(
      () => _i527.SharedPrefsStorageService(gh<_i460.SharedPreferences>()),
      dispose: (i) => i.dispose(),
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
    gh.factory<_i850.GetStoryRailUseCase>(
      () => _i850.GetStoryRailUseCase(gh<_i474.StoriesDatasource>()),
    );
    gh.factory<_i427.StoryViewersCubit>(
      () => _i427.StoryViewersCubit(gh<_i474.StoriesDatasource>()),
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
    gh.factory<_i740.FollowAllUseCase>(
      () => _i740.FollowAllUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i608.GetFollowRequestCountUseCase>(
      () => _i608.GetFollowRequestCountUseCase(gh<_i1001.FollowsDatasource>()),
    );
    gh.factory<_i171.GetFollowRequestsUseCase>(
      () => _i171.GetFollowRequestsUseCase(gh<_i1001.FollowsDatasource>()),
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
    gh.lazySingleton<_i47.ConnectivityService>(
      () => _i47.PlusConnectivityService(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i438.PlacesDatasource>(
      () => _i438.SupabasePlacesDatasource(gh<_i454.SupabaseClient>()),
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
    gh.factory<_i77.GetAudienceSummaryUseCase>(
      () => _i77.GetAudienceSummaryUseCase(gh<_i61.AudienceDatasource>()),
    );
    gh.factory<_i856.HidePostUseCase>(
      () => _i856.HidePostUseCase(gh<_i512.PostActionsDatasource>()),
    );
    gh.factory<_i246.SetCommentsEnabledUseCase>(
      () => _i246.SetCommentsEnabledUseCase(gh<_i512.PostActionsDatasource>()),
    );
    gh.factory<_i804.SetPostLikeUseCase>(
      () => _i804.SetPostLikeUseCase(gh<_i512.PostActionsDatasource>()),
    );
    gh.factory<_i520.SetPostSaveUseCase>(
      () => _i520.SetPostSaveUseCase(gh<_i512.PostActionsDatasource>()),
    );
    gh.factoryParam<_i133.AudienceListCubit, _i338.AudienceList, dynamic>(
      (list, _) => _i133.AudienceListCubit(
        gh<_i474.StoriesDatasource>(),
        gh<_i77.GetAudienceSummaryUseCase>(),
        list,
      ),
    );
    gh.factory<_i898.DeletePostUseCase>(
      () => _i898.DeletePostUseCase(
        gh<_i512.PostActionsDatasource>(),
        gh<_i285.MediaFilesDatasource>(),
      ),
    );
    gh.lazySingleton<_i1007.PostDraftDatasource>(
      () => _i1007.LocalPostDraftDatasource(
        gh<_i527.LocalStorageService>(),
        gh<_i849.AppFolders>(),
        gh<_i690.BackupExclusionService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i586.GetInterestsUseCase>(
      () => _i586.GetInterestsUseCase(gh<_i152.InterestsDatasource>()),
    );
    gh.factory<_i280.GetHomeFeedUseCase>(
      () => _i280.GetHomeFeedUseCase(gh<_i141.PostsDatasource>()),
    );
    gh.factory<_i599.SignPostMediaUrlsUseCase>(
      () => _i599.SignPostMediaUrlsUseCase(gh<_i141.PostsDatasource>()),
    );
    gh.lazySingleton<_i236.PasswordRecoveryTracker>(
      () => _i236.PasswordRecoveryTracker(gh<_i527.LocalStorageService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i834.OnboardingDatasource>(
      () => _i834.OnboardingDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i234.LocationPrimerDatasource>(
      () => _i234.LocationPrimerDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i366.RecentPlacesDatasource>(
      () => _i366.RecentPlacesDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i722.VisibilityNoticeDatasource>(
      () => _i722.VisibilityNoticeDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i126.ProfileLocalDatasource>(
      () => _i126.ProfileLocalDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i996.StoryCameraHintDatasource>(
      () => _i996.StoryCameraHintDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.factory<_i846.GetTaggedPeopleUseCase>(
      () => _i846.GetTaggedPeopleUseCase(gh<_i518.PostTagsDatasource>()),
    );
    gh.factory<_i491.RemoveMyTagUseCase>(
      () => _i491.RemoveMyTagUseCase(gh<_i518.PostTagsDatasource>()),
    );
    gh.factory<_i983.SearchTagPeopleUseCase>(
      () => _i983.SearchTagPeopleUseCase(gh<_i518.PostTagsDatasource>()),
    );
    gh.lazySingleton<_i142.ContentDiscardsDatasource>(
      () => _i142.LocalContentDiscardsDatasource(
        gh<_i527.LocalStorageService>(),
        gh<_i454.SupabaseClient>(),
      ),
    );
    gh.factory<_i91.GetCurrentUserIdUseCase>(
      () => _i91.GetCurrentUserIdUseCase(gh<_i320.ProfileDatasource>()),
    );
    gh.factory<_i837.PostShareRepository>(
      () => _i837.PostShareRepository(
        gh<_i591.PendingContentDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i141.PostsDatasource>(),
      ),
    );
    gh.factory<_i148.MediaUploadQueue>(
      () => _i148.MediaUploadQueue(gh<_i463.ContentMediaRepository>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i834.OnboardingDatasource>()),
    );
    gh.factoryParam<_i96.TagPeopleCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) =>
          _i96.TagPeopleCubit(gh<_i983.SearchTagPeopleUseCase>(), args),
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
    gh.factory<_i238.PostActionsCubit>(
      () => _i238.PostActionsCubit(
        gh<_i804.SetPostLikeUseCase>(),
        gh<_i520.SetPostSaveUseCase>(),
        gh<_i856.HidePostUseCase>(),
        gh<_i246.SetCommentsEnabledUseCase>(),
        gh<_i898.DeletePostUseCase>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i71.SetMuteUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        gh<_i491.RemoveMyTagUseCase>(),
      ),
    );
    gh.factory<_i465.StoryViewerCubit>(
      () => _i465.StoryViewerCubit(
        gh<_i850.GetStoryRailUseCase>(),
        gh<_i474.StoriesDatasource>(),
        gh<_i841.GalleryService>(),
        gh<_i327.VideoOverlayService>(),
        gh<_i71.SetMuteUseCase>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i76.RemoveMediaFilesUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i592.FeedCubit>(
      () => _i592.FeedCubit(
        gh<_i280.GetHomeFeedUseCase>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
      ),
    );
    gh.lazySingleton<_i999.ContentPublishRepository>(
      () => _i999.ContentPublishRepositoryImpl(
        gh<_i557.EventBus>(),
        gh<_i1034.ContentDiscardRepository>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i43.AuthDatasource>(
      () => _i43.SupabaseAuthDatasource(
        gh<_i454.SupabaseClient>(),
        gh<_i236.PasswordRecoveryTracker>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i749.SharedPostsRepository>(
      () => _i749.SharedPostsRepository(
        gh<_i1007.PostDraftDatasource>(),
        gh<_i591.PendingContentDatasource>(),
        gh<_i837.PostShareRepository>(),
        gh<_i999.ContentPublishRepository>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factory<_i344.ForgotPasswordCubit>(
      () => _i344.ForgotPasswordCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
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
    gh.lazySingleton<_i974.PlacesRepository>(
      () => _i974.PlacesRepositoryImpl(
        gh<_i438.PlacesDatasource>(),
        gh<_i366.RecentPlacesDatasource>(),
      ),
    );
    gh.factory<_i908.UpdatePostUseCase>(
      () => _i908.UpdatePostUseCase(
        gh<_i141.PostsDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i246.SetCommentsEnabledUseCase>(),
        gh<_i998.SetContentAudienceUseCase>(),
      ),
    );
    gh.factoryParam<_i118.TaggedPeopleCubit, String, dynamic>(
      (postId, _) => _i118.TaggedPeopleCubit(
        gh<_i846.GetTaggedPeopleUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        postId,
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
    gh.factory<_i597.SaveInterestsUseCase>(
      () => _i597.SaveInterestsUseCase(
        gh<_i152.InterestsDatasource>(),
        gh<_i508.ProfileRepository>(),
      ),
    );
    gh.factory<_i401.ResumeSharedPostsUseCase>(
      () => _i401.ResumeSharedPostsUseCase(gh<_i749.SharedPostsRepository>()),
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
    gh.factory<_i639.BellDotCubit>(
      () => _i639.BellDotCubit(
        gh<_i575.GetUnreadActivityCountUseCase>(),
        gh<_i557.EventBus>(),
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
    gh.factory<_i357.SaveAboutYouUseCase>(
      () => _i357.SaveAboutYouUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i255.SaveProfileDetailsUseCase>(
      () => _i255.SaveProfileDetailsUseCase(gh<_i508.ProfileRepository>()),
    );
    gh.factory<_i793.WatchSessionEndedUseCase>(
      () => _i793.WatchSessionEndedUseCase(
        gh<_i43.AuthDatasource>(),
        gh<_i815.SessionEvents>(),
      ),
    );
    gh.lazySingleton<_i618.StoryUploadRepository>(
      () => _i618.StoryUploadRepositoryImpl(
        gh<_i474.StoriesDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i999.ContentPublishRepository>(),
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
    gh.lazySingleton<_i97.SessionGuard>(
      () => appModule.sessionGuard(
        gh<_i718.GlobalKey<_i718.NavigatorState>>(),
        gh<_i793.WatchSessionEndedUseCase>(),
      ),
      dispose: _i431.disposeSessionGuard,
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
    gh.factory<_i121.WatchPasswordRecoveryUseCase>(
      () => _i121.WatchPasswordRecoveryUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i260.ResetPasswordCubit>(
      () => _i260.ResetPasswordCubit(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i1017.PostDraftRepository>(
      () => _i1017.PostDraftRepository(
        gh<_i1007.PostDraftDatasource>(),
        gh<_i148.MediaUploadQueue>(),
        gh<_i591.PendingContentDatasource>(),
        gh<_i749.SharedPostsRepository>(),
        gh<_i1034.ContentDiscardRepository>(),
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
    gh.factory<_i127.SplashCubit>(
      () => _i127.SplashCubit(
        gh<_i710.IsSignedInUseCase>(),
        gh<_i730.IsRecoveryPendingUseCase>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i1036.SignOutUseCase>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.factoryParam<_i378.StoryEditCubit, _i2.CapturedStoryMedia, dynamic>(
      (media, _) => _i378.StoryEditCubit(
        gh<_i618.StoryUploadRepository>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i905.BlurhashService>(),
        gh<_i841.GalleryService>(),
        gh<_i327.VideoOverlayService>(),
        gh<_i727.GetLastAccountUseCase>(),
        media,
      ),
    );
    gh.factory<_i781.SignUpCubit>(
      () => _i781.SignUpCubit(
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
    gh.factory<_i308.StoryRailCubit>(
      () => _i308.StoryRailCubit(
        gh<_i850.GetStoryRailUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i108.RetryPublishUseCase>(),
      ),
    );
    gh.factoryParam<
      _i80.AddEditPostCubit,
      _i570.PostEntity?,
      Map<String, String>?
    >(
      (post, signedUrls) => _i80.AddEditPostCubit(
        gh<_i908.UpdatePostUseCase>(),
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
    gh.lazySingleton<_i358.RecoveryLinkHandler>(
      () => appModule.recoveryLinkHandler(
        gh<_i718.GlobalKey<_i718.NavigatorState>>(),
        gh<_i121.WatchPasswordRecoveryUseCase>(),
      ),
      dispose: _i431.disposeRecoveryLinkHandler,
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
    return this;
  }
}

class _$AppModule extends _i431.AppModule {}
