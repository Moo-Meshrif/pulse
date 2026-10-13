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
import '../../features/auth/data/datasource/auth_datasource.dart' as _i43;
import '../../features/auth/data/datasource/password_recovery_tracker.dart'
    as _i236;
import '../../features/auth/domain/use_case/is_recovery_pending_use_case.dart'
    as _i730;
import '../../features/auth/domain/use_case/is_signed_in_use_case.dart'
    as _i710;
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
import '../../features/legal/data/datasource/legal_datasource.dart' as _i604;
import '../../features/legal/presentation/cubit/legal_cubit.dart' as _i736;
import '../../features/onboarding/data/datasource/onboarding_datasource.dart'
    as _i834;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
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
import '../../features/story/data/datasource/story_media_uploader.dart'
    as _i967;
import '../../features/story/data/enums/audience_list.dart' as _i338;
import '../../features/story/data/enums/story_audience.dart' as _i1071;
import '../../features/story/data/repository/story_upload_repository.dart'
    as _i618;
import '../../features/story/domain/entity/captured_story_media.dart' as _i2;
import '../../features/story/domain/use_case/get_story_rail_use_case.dart'
    as _i849;
import '../../features/story/domain/use_case/retry_story_upload_use_case.dart'
    as _i850;
import '../../features/story/domain/use_case/watch_story_rail_changes_use_case.dart'
    as _i544;
import '../../features/story/domain/use_case/watch_story_upload_use_case.dart'
    as _i139;
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
import '../router/recovery_link_handler.dart' as _i358;
import '../router/session_guard.dart' as _i96;
import '../services/camera_device.dart' as _i64;
import '../services/camera_permission_service.dart' as _i754;
import '../services/connectivity_service.dart' as _i47;
import '../services/gallery_service.dart' as _i841;
import '../services/launch_service.dart' as _i1016;
import '../services/local_storage_service.dart' as _i527;
import '../services/media_picker_service.dart' as _i715;
import '../services/photo_picker_service.dart' as _i94;
import '../services/session_events.dart' as _i815;
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
    gh.lazySingleton<_i815.SessionEvents>(
      () => _i815.SessionEvents(),
      dispose: (i) => i.dispose(),
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
    gh.lazySingleton<_i1016.LaunchService>(
      () => _i1016.UrlLauncherLaunchService(),
    );
    gh.factory<_i64.CameraDevice>(() => _i64.PackageCameraDevice());
    gh.lazySingleton<_i841.GalleryService>(
      () => _i841.GalGalleryService(gh<_i519.Client>()),
    );
    gh.lazySingleton<_i967.StoryMediaUploader>(
      () => _i967.HttpStoryMediaUploader(
        gh<_i454.SupabaseClient>(),
        gh<_i519.Client>(),
      ),
    );
    gh.lazySingleton<_i754.CameraPermissionService>(
      () => _i754.HandlerCameraPermissionService(),
    );
    gh.factory<_i721.CameraPermissionCubit>(
      () => _i721.CameraPermissionCubit(gh<_i754.CameraPermissionService>()),
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
    gh.lazySingleton<_i527.LocalStorageService>(
      () => _i527.SharedPrefsStorageService(gh<_i460.SharedPreferences>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i320.ProfileDatasource>(
      () => _i320.SupabaseProfileDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.factoryParam<_i117.AudienceListCubit, _i338.AudienceList, dynamic>(
      (list, _) => _i117.AudienceListCubit(gh<_i474.StoriesDatasource>(), list),
    );
    gh.factory<_i849.GetStoryRailUseCase>(
      () => _i849.GetStoryRailUseCase(gh<_i474.StoriesDatasource>()),
    );
    gh.factory<_i544.WatchStoryRailChangesUseCase>(
      () => _i544.WatchStoryRailChangesUseCase(gh<_i474.StoriesDatasource>()),
    );
    gh.factory<_i56.StoryViewersCubit>(
      () => _i56.StoryViewersCubit(gh<_i474.StoriesDatasource>()),
    );
    gh.factoryParam<_i219.StoryAudienceCubit, String, _i1071.StoryAudience>(
      (storyId, audience) => _i219.StoryAudienceCubit(
        gh<_i474.StoriesDatasource>(),
        storyId,
        audience,
      ),
    );
    gh.lazySingleton<_i1001.FollowsDatasource>(
      () => _i1001.SupabaseFollowsDatasource(gh<_i454.SupabaseClient>()),
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
    gh.factory<_i736.LegalCubit>(
      () => _i736.LegalCubit(
        gh<_i604.LegalDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
    );
    gh.lazySingleton<_i618.StoryUploadRepository>(
      () => _i618.StoryUploadRepositoryImpl(
        gh<_i474.StoriesDatasource>(),
        gh<_i967.StoryMediaUploader>(),
      ),
    );
    gh.factory<_i850.RetryStoryUploadUseCase>(
      () => _i850.RetryStoryUploadUseCase(gh<_i618.StoryUploadRepository>()),
    );
    gh.factory<_i139.WatchStoryUploadUseCase>(
      () => _i139.WatchStoryUploadUseCase(gh<_i618.StoryUploadRepository>()),
    );
    gh.factory<_i125.StoryViewerCubit>(
      () => _i125.StoryViewerCubit(
        gh<_i849.GetStoryRailUseCase>(),
        gh<_i474.StoriesDatasource>(),
        gh<_i841.GalleryService>(),
      ),
    );
    gh.factory<_i586.GetInterestsUseCase>(
      () => _i586.GetInterestsUseCase(gh<_i152.InterestsDatasource>()),
    );
    gh.lazySingleton<_i236.PasswordRecoveryTracker>(
      () => _i236.PasswordRecoveryTracker(gh<_i527.LocalStorageService>()),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i834.OnboardingDatasource>(
      () => _i834.OnboardingDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i126.ProfileLocalDatasource>(
      () => _i126.ProfileLocalDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i996.StoryCameraHintDatasource>(
      () => _i996.StoryCameraHintDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i834.OnboardingDatasource>()),
    );
    gh.lazySingleton<_i43.AuthDatasource>(
      () => _i43.SupabaseAuthDatasource(
        gh<_i454.SupabaseClient>(),
        gh<_i236.PasswordRecoveryTracker>(),
      ),
      dispose: (i) => i.dispose(),
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
    gh.factory<_i597.SaveInterestsUseCase>(
      () => _i597.SaveInterestsUseCase(
        gh<_i152.InterestsDatasource>(),
        gh<_i508.ProfileRepository>(),
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
    gh.factory<_i121.WatchPasswordRecoveryUseCase>(
      () => _i121.WatchPasswordRecoveryUseCase(gh<_i43.AuthDatasource>()),
    );
    gh.factory<_i476.ResetPasswordCubit>(
      () => _i476.ResetPasswordCubit(gh<_i43.AuthDatasource>()),
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
    gh.factory<_i127.SplashCubit>(
      () => _i127.SplashCubit(
        gh<_i710.IsSignedInUseCase>(),
        gh<_i730.IsRecoveryPendingUseCase>(),
        gh<_i697.GetSignupStepUseCase>(),
        gh<_i47.ConnectivityService>(),
      ),
    );
    gh.factory<_i598.ControlCubit>(
      () => _i598.ControlCubit(gh<_i730.IsRecoveryPendingUseCase>()),
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
