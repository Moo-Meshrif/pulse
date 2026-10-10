// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../app/app_module.dart' as _i431;
import '../../features/auth/data/datasource/auth_datasource.dart' as _i43;
import '../../features/auth/domain/use_case/is_signed_in_use_case.dart'
    as _i710;
import '../../features/auth/domain/use_case/watch_password_recovery_use_case.dart'
    as _i121;
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart'
    as _i104;
import '../../features/auth/presentation/cubit/reset_password_cubit.dart'
    as _i476;
import '../../features/auth/presentation/cubit/sign_in_cubit.dart' as _i329;
import '../../features/auth/presentation/cubit/sign_up_cubit.dart' as _i102;
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
import '../../features/profile/domain/use_case/get_interests_use_case.dart'
    as _i586;
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
import '../../features/splash/presentation/cubit/splash_cubit.dart' as _i125;
import '../services/launch_service.dart' as _i1016;
import '../services/local_storage_service.dart' as _i527;
import '../services/photo_picker_service.dart' as _i94;

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
    gh.lazySingleton<_i94.PhotoPickerService>(
      () => _i94.ImagePickerPhotoPickerService(),
    );
    gh.lazySingleton<_i1016.LaunchService>(
      () => _i1016.UrlLauncherLaunchService(),
    );
    gh.lazySingleton<_i43.AuthDatasource>(
      () => _i43.SupabaseAuthDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i152.InterestsDatasource>(
      () => _i152.SupabaseInterestsDatasource(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i527.LocalStorageService>(
      () => _i527.SharedPrefsStorageService(gh<_i460.SharedPreferences>()),
      dispose: (i) => i.dispose(),
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
    gh.lazySingleton<_i320.ProfileDatasource>(
      () => _i320.SupabaseProfileDatasource(gh<_i454.SupabaseClient>()),
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
    gh.factory<_i104.ForgotPasswordCubit>(
      () => _i104.ForgotPasswordCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i1016.LaunchService>(),
      ),
    );
    gh.factory<_i586.GetInterestsUseCase>(
      () => _i586.GetInterestsUseCase(gh<_i152.InterestsDatasource>()),
    );
    gh.lazySingleton<_i834.OnboardingDatasource>(
      () => _i834.OnboardingDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.lazySingleton<_i126.ProfileLocalDatasource>(
      () => _i126.ProfileLocalDatasource(gh<_i527.LocalStorageService>()),
    );
    gh.factory<_i807.OnboardingCubit>(
      () => _i807.OnboardingCubit(gh<_i834.OnboardingDatasource>()),
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
    gh.factory<_i125.SplashCubit>(
      () => _i125.SplashCubit(
        gh<_i710.IsSignedInUseCase>(),
        gh<_i697.GetSignupStepUseCase>(),
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
    gh.factory<_i329.SignInCubit>(
      () => _i329.SignInCubit(
        gh<_i43.AuthDatasource>(),
        gh<_i697.GetSignupStepUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i431.AppModule {}
