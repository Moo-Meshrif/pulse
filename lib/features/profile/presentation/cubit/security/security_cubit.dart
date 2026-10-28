import 'package:injectable/injectable.dart';

import '../../../../../core/enums/auth_failure_reason.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/device_name_service.dart';
import '../../../../../core/state/base_cubit.dart';
import '../../../../auth/domain/use_case/change_password_use_case.dart';
import '../../../../auth/domain/use_case/send_own_password_reset_use_case.dart';
import '../../../../auth/domain/use_case/sign_out_others_use_case.dart';
import '../../utils/enums/security_notice.dart';
import 'security_state.dart';

/// Settings > Password & security (docs/specs/profile/screens/s4-password-security.md): change the
/// password, email a reset link, log out the other devices.
@injectable
class SecurityCubit extends BaseCubit<SecurityState> {
  SecurityCubit(
    this._changePassword,
    this._sendReset,
    this._signOutOthers,
    this._deviceName,
  ) : super(const SecurityState());

  final ChangePasswordUseCase _changePassword;
  final SendOwnPasswordResetUseCase _sendReset;
  final SignOutOthersUseCase _signOutOthers;
  final DeviceNameService _deviceName;

  Future<void> load() => run(
    _deviceName.name,
    onSuccess: (name) => state.copyWith(deviceName: name),
    onFailure: (_) => null,
  );

  void currentChanged(String value) =>
      emit(state.copyWith(current: value, currentWrong: false));

  void nextChanged(String value) => emit(state.copyWith(next: value));

  void confirmChanged(String value) => emit(state.copyWith(confirm: value));

  Future<void> update() => run(
    () => _changePassword(current: state.current, next: state.next),
    prevent: !state.canUpdate,
    loading: state.copyWith(
      isUpdating: true,
      currentWrong: false,
      failure: null,
      notice: null,
    ),
    onSuccess: (_) => SecurityState(
      deviceName: state.deviceName,
      notice: SecurityNotice.passwordUpdated,
    ),
    onFailure: (failure) =>
        failure is AuthFailure &&
            failure.reason == AuthFailureReason.invalidCredentials
        ? state.copyWith(isUpdating: false, currentWrong: true)
        : state.copyWith(isUpdating: false, failure: failure),
  );

  Future<void> sendReset() => run(
    _sendReset.call,
    loading: state.copyWith(failure: null, notice: null),
    onSuccess: (_) => state.copyWith(notice: SecurityNotice.resetEmailSent),
    onFailure: (failure) => state.copyWith(failure: failure),
  );

  Future<void> logOutOthers() => run(
    _signOutOthers.call,
    prevent: state.isLoggingOutOthers,
    loading: state.copyWith(
      isLoggingOutOthers: true,
      failure: null,
      notice: null,
    ),
    onSuccess: (_) => state.copyWith(
      isLoggingOutOthers: false,
      notice: SecurityNotice.othersLoggedOut,
    ),
    onFailure: (failure) =>
        state.copyWith(isLoggingOutOthers: false, failure: failure),
  );
}
