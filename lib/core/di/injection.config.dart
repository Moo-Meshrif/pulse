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
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart'
    as _i104;
import '../../features/auth/presentation/cubit/reset_password_cubit.dart'
    as _i476;
import '../../features/auth/presentation/cubit/sign_in_cubit.dart' as _i329;
import '../../features/auth/presentation/cubit/sign_up_cubit.dart' as _i102;
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
import '../../features/home/presentation/cubit/bell_dot_cubit.dart' as _i472;
import '../../features/home/presentation/cubit/feed_cubit.dart' as _i646;
import '../../features/home/presentation/cubit/post_publish_cubit.dart'
    as _i704;
import '../../features/home/presentation/cubit/story_rail_cubit.dart' as _i363;
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
import '../../features/post/data/datasource/post_tags_datasource.dart' as _i518;
import '../../features/post/data/datasource/posts_datasource.dart' as _i141;
import '../../features/post/data/datasource/visibility_notice_datasource.dart'
    as _i722;
import '../../features/post/domain/entity/post_entity.dart' as _i569;
import '../../features/post/domain/use_case/create_post_use_case.dart' as _i592;
import '../../features/post/domain/use_case/delete_post_use_case.dart' as _i898;
import '../../features/post/domain/use_case/get_home_feed_use_case.dart'
    as _i280;
import '../../features/post/domain/use_case/get_tagged_people_use_case.dart'
    as _i846;
import '../../features/post/domain/use_case/hide_post_use_case.dart' as _i856;
import '../../features/post/domain/use_case/remove_my_tag_use_case.dart'
    as _i491;
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
import '../../features/post/presentation/cubit/add_edit_post_cubit.dart'
    as _i897;
import '../../features/post/presentation/cubit/post_actions_cubit.dart' as _i72;
import '../../features/post/presentation/cubit/post_visibility_cubit.dart'
    as _i264;
import '../../features/post/presentation/cubit/tag_in_photo_cubit.dart'
    as _i962;
import '../../features/post/presentation/cubit/tag_people_cubit.dart' as _i442;
import '../../features/post/presentation/cubit/tagged_people_cubit.dart'
    as _i932;
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
    as _i849;
import '../../features/story/presentation/cubit/audience_list_cubit.dart'
    as _i117;
import '../../features/story/presentation/cubit/story_audience_cubit.dart'
    as _i219;
import '../../features/story/presentation/cubit/story_camera_cubit.dart'
    as _i507;
import '../../features/story/presentation/cubit/story_edit_cubit.dart' as _i144;
import '../../features/story/presentation/cubit/story_viewer_cubit.dart'
    as _i125;
import '../../features/story/presentation/cubit/story_viewers_cubit.dart'
    as _i56;
import '../../shared/content/data/datasource/audience_datasource.dart' as _i61;
import '../../shared/content/data/datasource/content_actions_datasource.dart'
    as _i719;
import '../../shared/content/data/datasource/media_files_datasource.dart'
    as _i285;
import '../../shared/content/data/datasource/privacy_datasource.dart' as _i885;
import '../../shared/content/data/enums/content_audience.dart' as _i248;
import '../../shared/content/data/repository/content_media_repository.dart'
    as _i463;
import '../../shared/content/data/repository/content_publish_repository.dart'
    as _i999;
import '../../shared/content/domain/use_case/discard_publish_use_case.dart'
    as _i453;
import '../../shared/content/domain/use_case/get_audience_summary_use_case.dart'
    as _i77;
import '../../shared/content/domain/use_case/get_privacy_use_case.dart'
    as _i660;
import '../../shared/content/domain/use_case/get_publish_status_use_case.dart'
    as _i541;
import '../../shared/content/domain/use_case/publish_content_use_case.dart'
    as _i1032;
import '../../shared/content/domain/use_case/remove_media_files_use_case.dart'
    as _i76;
import '../../shared/content/domain/use_case/report_content_use_case.dart'
    as _i1021;
import '../../shared/content/domain/use_case/retry_publish_use_case.dart'
    as _i108;
import '../../shared/content/domain/use_case/save_default_audience_use_case.dart'
    as _i1035;
import '../../shared/content/domain/use_case/set_content_audience_use_case.dart'
    as _i998;
import '../../shared/content/domain/use_case/set_mute_use_case.dart' as _i71;
import '../events/event_bus.dart' as _i557;
import '../router/recovery_link_handler.dart' as _i358;
import '../router/session_guard.dart' as _i96;
import '../services/camera_device.dart' as _i64;
import '../services/camera_permission_service.dart' as _i754;
import '../services/connectivity_service.dart' as _i47;
import '../services/gallery_service.dart' as _i841;
import '../services/launch_service.dart' as _i1016;
import '../services/local_storage_service.dart' as _i527;
import '../services/location_service.dart' as _i669;
import '../services/media_picker_service.dart' as _i715;
import '../services/photo_picker_service.dart' as _i94;
import '../services/session_events.dart' as _i815;
import '../services/video_compress_service.dart' as _i794;
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
    gh.factoryParam<_i962.TagInPhotoCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) => _i962.TagInPhotoCubit(args),
    );
    gh.lazySingleton<_i794.VideoCompressService>(
      () => _i794.PackageVideoCompressService(),
    );
    gh.lazySingleton<_i94.PhotoPickerService>(
      () => _i94.ImagePickerPhotoPickerService(),
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
    gh.lazySingleton<_i719.ContentActionsDatasource>(
      () => _i719.SupabaseContentActionsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i320.ProfileDatasource>(
      () => _i320.SupabaseProfileDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i849.GetStoryRailUseCase>(
      () => _i849.GetStoryRailUseCase(gh<_i474.StoriesDatasource>()),
    );
    gh.factory<_i56.StoryViewersCubit>(
      () => _i56.StoryViewersCubit(gh<_i474.StoriesDatasource>()),
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
    gh.lazySingleton<_i999.ContentPublishRepository>(
      () => _i999.ContentPublishRepositoryImpl(gh<_i557.EventBus>()),
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
    gh.factoryParam<_i117.AudienceListCubit, _i338.AudienceList, dynamic>(
      (list, _) => _i117.AudienceListCubit(
        gh<_i474.StoriesDatasource>(),
        gh<_i77.GetAudienceSummaryUseCase>(),
        list,
      ),
    );
    gh.factory<_i453.DiscardPublishUseCase>(
      () => _i453.DiscardPublishUseCase(gh<_i999.ContentPublishRepository>()),
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
    gh.factory<_i898.DeletePostUseCase>(
      () => _i898.DeletePostUseCase(
        gh<_i512.PostActionsDatasource>(),
        gh<_i285.MediaFilesDatasource>(),
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
    gh.factory<_i91.GetCurrentUserIdUseCase>(
      () => _i91.GetCurrentUserIdUseCase(gh<_i320.ProfileDatasource>()),
    );
    gh.lazySingleton<_i618.StoryUploadRepository>(
      () => _i618.StoryUploadRepositoryImpl(
        gh<_i474.StoriesDatasource>(),
        gh<_i463.ContentMediaRepository>(),
        gh<_i999.ContentPublishRepository>(),
      ),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i834.OnboardingDatasource>()),
    );
    gh.factoryParam<_i442.TagPeopleCubit, _i425.TagPeopleArgs, dynamic>(
      (args, _) =>
          _i442.TagPeopleCubit(gh<_i983.SearchTagPeopleUseCase>(), args),
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
    gh.factory<_i592.CreatePostUseCase>(
      () => _i592.CreatePostUseCase(
        gh<_i141.PostsDatasource>(),
        gh<_i463.ContentMediaRepository>(),
      ),
    );
    gh.factory<_i72.PostActionsCubit>(
      () => _i72.PostActionsCubit(
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
    gh.lazySingleton<_i43.AuthDatasource>(
      () => _i43.SupabaseAuthDatasource(
        gh<_i454.SupabaseClient>(),
        gh<_i236.PasswordRecoveryTracker>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i704.PostPublishCubit>(
      () => _i704.PostPublishCubit(
        gh<_i557.EventBus>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i108.RetryPublishUseCase>(),
        gh<_i453.DiscardPublishUseCase>(),
      ),
    );
    gh.factory<_i363.StoryRailCubit>(
      () => _i363.StoryRailCubit(
        gh<_i849.GetStoryRailUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i541.GetPublishStatusUseCase>(),
        gh<_i108.RetryPublishUseCase>(),
      ),
    );
    gh.factory<_i646.FeedCubit>(
      () => _i646.FeedCubit(
        gh<_i280.GetHomeFeedUseCase>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i91.GetCurrentUserIdUseCase>(),
      ),
    );
    gh.factory<_i104.ForgotPasswordCubit>(
      () => _i104.ForgotPasswordCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
    );
    gh.factory<_i507.StoryCameraCubit>(
      () => _i507.StoryCameraCubit(
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
    gh.factoryParam<_i219.StoryAudienceCubit, String, _i248.ContentAudience>(
      (storyId, audience) => _i219.StoryAudienceCubit(
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
    gh.factory<_i125.StoryViewerCubit>(
      () => _i125.StoryViewerCubit(
        gh<_i849.GetStoryRailUseCase>(),
        gh<_i474.StoriesDatasource>(),
        gh<_i841.GalleryService>(),
        gh<_i71.SetMuteUseCase>(),
        gh<_i1021.ReportContentUseCase>(),
        gh<_i76.RemoveMediaFilesUseCase>(),
        gh<_i557.EventBus>(),
      ),
    );
    gh.factoryParam<_i932.TaggedPeopleCubit, String, dynamic>(
      (postId, _) => _i932.TaggedPeopleCubit(
        gh<_i846.GetTaggedPeopleUseCase>(),
        gh<_i130.ToggleFollowUseCase>(),
        postId,
      ),
    );
    gh.factoryParam<_i264.PostVisibilityCubit, String?, _i248.ContentAudience>(
      (postId, audience) => _i264.PostVisibilityCubit(
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
    gh.factoryParam<_i490.AddLocationCubit, String?, dynamic>(
      (current, _) => _i490.AddLocationCubit(
        gh<_i974.PlacesRepository>(),
        gh<_i669.LocationService>(),
        gh<_i47.ConnectivityService>(),
        gh<_i234.LocationPrimerDatasource>(),
        current,
      ),
    );
    gh.factory<_i472.BellDotCubit>(
      () => _i472.BellDotCubit(
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
    gh.factory<_i329.SignInCubit>(
      () => _i329.SignInCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i727.GetLastAccountUseCase>(),
        gh<_i1067.ForgetLastAccountUseCase>(),
      ),
    );
    gh.factoryParam<_i144.StoryEditCubit, _i2.CapturedStoryMedia, dynamic>(
      (media, _) => _i144.StoryEditCubit(
        gh<_i618.StoryUploadRepository>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i841.GalleryService>(),
        gh<_i727.GetLastAccountUseCase>(),
        media,
      ),
    );
    gh.lazySingleton<_i96.SessionGuard>(
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
    gh.factory<_i476.ResetPasswordCubit>(
      () => _i476.ResetPasswordCubit(gh<_i43.AuthDatasource>()),
    );
    gh.factoryParam<_i897.AddEditPostCubit, _i569.PostEntity?, dynamic>(
      (post, _) => _i897.AddEditPostCubit(
        gh<_i592.CreatePostUseCase>(),
        gh<_i908.UpdatePostUseCase>(),
        gh<_i1032.PublishContentUseCase>(),
        gh<_i557.EventBus>(),
        gh<_i599.SignPostMediaUrlsUseCase>(),
        gh<_i715.MediaPickerService>(),
        gh<_i660.GetPrivacyUseCase>(),
        gh<_i143.VideoThumbnailService>(),
        gh<_i727.GetLastAccountUseCase>(),
        post,
      ),
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
    gh.factory<_i102.SignUpCubit>(
      () => _i102.SignUpCubit(
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
    gh.lazySingleton<_i358.RecoveryLinkHandler>(
      () => appModule.recoveryLinkHandler(
        gh<_i718.GlobalKey<_i718.NavigatorState>>(),
        gh<_i121.WatchPasswordRecoveryUseCase>(),
      ),
      dispose: _i431.disposeRecoveryLinkHandler,
    );
    return this;
  }
}

class _$AppModule extends _i431.AppModule {}
