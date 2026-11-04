import 'package:injectable/injectable.dart';

import '../../../../../core/enums/auth_failure_reason.dart';
import '../../../../../core/error/error_reporter.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/app_version_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../auth/domain/use_case/sign_out_use_case.dart';
import '../../../../auth/domain/use_case/verify_password_use_case.dart';
import '../../../data/datasource/app_preferences_datasource.dart';
import '../../../data/datasource/settings_datasource.dart';
import '../../../domain/use_case/clear_local_profile_use_case.dart';
import 'settings_state.dart';

/// The Settings home (docs/specs/profile/screens/s2-settings.md): the values beside the rows, the two
/// switches kept on this phone, Log out and Delete account.
@injectable
class SettingsCubit extends BaseCubit<SettingsState> {
  SettingsCubit(
    this._settings,
    this._preferences,
    this._clearLocalProfile,
    this._signOut,
    this._verifyPassword,
    this._appVersion,
  ) : super(
        SettingsState(
          autoplayShorts: _preferences.autoplayShorts,
          dataSaver: _preferences.dataSaver,
        ),
      );

  final SettingsDatasource _settings;
  final AppPreferencesDatasource _preferences;
  final ClearLocalProfileUseCase _clearLocalProfile;
  final SignOutUseCase _signOut;
  final VerifyPasswordUseCase _verifyPassword;
  final AppVersionService _appVersion;

  bool get _busy => state.isLoggingOut || state.isDeleting;

  /// Reads the values beside the rows and the version; a failure leaves the rows without a value.
  Future<void> load() async {
    await Future.wait([
      run(
        _settings.getSummary,
        onSuccess: (summary) => state.copyWith(summary: summary),
        onFailure: (_) => null,
      ),
      run(
        _appVersion.version,
        onSuccess: (version) => state.copyWith(version: version),
        onFailure: (_) => null,
      ),
    ]);
  }

  void setAutoplayShorts(bool value) {
    emit(state.copyWith(autoplayShorts: value));
    _preferences.setAutoplayShorts(value);
  }

  void setDataSaver(bool value) {
    emit(state.copyWith(dataSaver: value));
    _preferences.setDataSaver(value);
  }

  Future<void> logOut() => run(
    () async {
      await _clearLocalProfile();
      await _signOut();
    },
    prevent: _busy,
    loading: state.copyWith(isLoggingOut: true, failure: null),
    onSuccess: (_) => state.copyWith(isLoggingOut: false, signedOut: true),
    onFailure: (failure) =>
        state.copyWith(isLoggingOut: false, failure: failure),
  );

  /// Checks [password], deletes the account on the server, then clears this phone and ends the session.
  /// A wrong password only sets [SettingsState.passwordWrong].
  Future<void> deleteAccount(String password) => run(
    () async {
      await _verifyPassword(password);
      await _settings.deleteAccount();
      await _leaveDeletedAccount();
    },
    prevent: _busy || password.isEmpty,
    loading: state.copyWith(
      isDeleting: true,
      passwordWrong: false,
      failure: null,
    ),
    onSuccess: (_) => state.copyWith(isDeleting: false, signedOut: true),
    onFailure: (failure) =>
        failure is AuthFailure &&
            failure.reason == AuthFailureReason.invalidCredentials
        ? state.copyWith(isDeleting: false, passwordWrong: true)
        : state.copyWith(isDeleting: false, failure: failure),
  );

  void passwordEdited() {
    if (state.passwordWrong) emit(state.copyWith(passwordWrong: false));
  }

  /// The account is already gone on the server: a clean-up that fails must not look like a failed delete.
  Future<void> _leaveDeletedAccount() async {
    try {
      await _clearLocalProfile();
      await _signOut();
    } catch (error, stackTrace) {
      ErrorReporter.report(error, stackTrace);
    }
  }
}
